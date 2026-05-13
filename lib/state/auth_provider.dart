import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/token_storage.dart';
import '../models/account_role.dart';
import '../models/church_registry_person.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isLoggedIn;
  final AccountRole role;
  final String? token;

  final String? userId;
  final String? name;
  final String? phone;
  final String? address;

  final ChurchRegistryPerson? registry;

  const AuthState({
    required this.isLoggedIn,
    required this.role,
    this.token,
    this.userId,
    this.name,
    this.phone,
    this.address,
    this.registry,
  });

  bool get isGuest => role == AccountRole.guest;
  bool get isAdmin => role == AccountRole.admin;
  bool get isStaff => role == AccountRole.staff;
  bool get isMember => role == AccountRole.member;
  bool get isPending => role == AccountRole.pending;
  bool get isDistrictLeader => registry?.isDistrictLeader == true;

  AuthState copyWith({
    bool? isLoggedIn,
    AccountRole? role,
    String? token,
    String? userId,
    String? name,
    String? phone,
    String? address,
    ChurchRegistryPerson? registry,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      registry: registry ?? this.registry,
    );
  }

  static const guest = AuthState(isLoggedIn: false, role: AccountRole.guest);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.guest);

  /// main()에서 받은 FCM 토큰 — 로그인 시점에 백엔드에 자동 등록되도록 캐시.
  static String? cachedFcmToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 토큰: secure storage 우선, 없으면 SP에서 1회 이전
    String? token = await TokenStorage.read();
    if (token == null || token.isEmpty) {
      final legacy = prefs.getString('auth_token');
      if (legacy != null && legacy.isNotEmpty) {
        await TokenStorage.write(legacy);
        await prefs.remove('auth_token');
        token = legacy;
      }
    }
    if (token == null || token.isEmpty) return;

    final name = prefs.getString('auth_name') ?? '';
    final userId = prefs.getString('auth_userId') ?? '';
    final phone = prefs.getString('auth_phone');
    final roleStr = prefs.getString('auth_role') ?? '';
    final zone = prefs.getString('auth_zone');
    final parish = prefs.getString('auth_parish');
    final position = prefs.getString('auth_position');
    final isLeader = prefs.getBool('auth_isLeader') ?? false;

    final role = AccountRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => AccountRole.pending,
    );

    // 직분/교구/구역/구역장 중 하나라도 있으면 registry 객체 생성
    ChurchRegistryPerson? registry;
    final hasAnyRegistry = (position?.isNotEmpty == true) ||
        (parish?.isNotEmpty == true) ||
        (zone?.isNotEmpty == true) ||
        isLeader;
    if (hasAnyRegistry) {
      registry = ChurchRegistryPerson(
        name: name,
        phone: phone ?? '',
        position: position ?? '',
        parish: parish ?? '',
        district: zone ?? '',
        isDistrictLeader: isLeader,
      );
    }

    state = AuthState(
      isLoggedIn: true,
      role: role,
      token: token,
      name: name,
      userId: userId,
      phone: phone,
      registry: registry,
    );

    // 서버에서 최신 정보 백그라운드 갱신
    refreshFromServer();
  }

  Future<void> refreshFromServer() async {
    final token = state.token;
    if (token == null || !state.isLoggedIn) return;
    try {
      final data = await ApiService().get('/api/v1/users/me');
      final u = data['user'] as Map<String, dynamic>?;
      if (u == null) return;

      final roleStr = (u['role'] as String?) ?? '';
      final role = AccountRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => state.role,
      );

      final rm = u['registryMember'] as Map<String, dynamic>?;
      ChurchRegistryPerson? registry;
      final zone = (u['zone'] as String?) ?? '';
      final parish = (u['parish'] as String?) ?? '';
      final position = (u['position'] as String?) ?? '';
      final isLeader = rm?['isLeader'] as bool? ?? false;
      final hasAnyRegistry = position.isNotEmpty ||
          parish.isNotEmpty ||
          zone.isNotEmpty ||
          isLeader;
      if (hasAnyRegistry) {
        registry = ChurchRegistryPerson(
          name: u['name'] as String? ?? state.name ?? '',
          phone: u['phone'] as String? ?? state.phone ?? '',
          position: position,
          parish: parish,
          district: zone,
          isDistrictLeader: isLeader,
        );
      }

      state = state.copyWith(
        name: u['name'] as String?,
        role: role,
        address: u['address'] as String?,
        registry: registry,
      );
      await _persist();
    } catch (_) {
      // 네트워크 오류 시 캐시 유지
    }
  }

  Future<void> updateProfile({String? name, String? address}) async {
    final token = state.token;
    if (token == null) return;
    await ApiService().put('/api/v1/users/me', {
      if (name != null) 'name': name,
      if (address != null) 'address': address,
    });
    state = state.copyWith(
      name: name ?? state.name,
      address: address ?? state.address,
    );
    await _persist();
  }

  Future<void> _persist() async {
    // storage 쓰기 실패해도 로그인 자체는 유지(메모리 상태)
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state.isLoggedIn && state.token != null) {
        await TokenStorage.write(state.token!);
        await prefs.setString('auth_name', state.name ?? '');
        await prefs.setString('auth_userId', state.userId ?? '');
        await prefs.setString('auth_role', state.role.name);
        if (state.phone != null) await prefs.setString('auth_phone', state.phone!);
        final r = state.registry;
        if (r != null) {
          await prefs.setString('auth_zone', r.district);
          await prefs.setString('auth_parish', r.parish);
          await prefs.setString('auth_position', r.position);
          await prefs.setBool('auth_isLeader', r.isDistrictLeader);
        }
      } else {
        await TokenStorage.clear();
        for (final key in [
          'auth_token', 'auth_name', 'auth_userId', 'auth_phone',
          'auth_role', 'auth_zone', 'auth_parish', 'auth_position',
        ]) {
          await prefs.remove(key);
        }
        await prefs.remove('auth_isLeader');
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[auth._persist] storage write failed: $e\n$st');
    }
  }

  void logout() {
    state = AuthState.guest;
    _persist();
  }

  Future<void> login({
    required String name,
    required String userId,
    required String phone,
    AccountRole role = AccountRole.pending,
    String? token,
    String? address,
    ChurchRegistryPerson? registry,
  }) async {
    state = AuthState(
      isLoggedIn: true,
      role: role,
      token: token,
      name: name,
      userId: userId,
      phone: phone,
      address: address,
      registry: registry,
    );
    // secure storage 쓰기가 끝난 뒤 다음 페이지로 가도록 await.
    // 미 await 시 race condition 으로 다음 API 호출이 Authorization 헤더 없이 발사 → 401 자동 로그아웃.
    await _persist();
    _maybeRegisterCachedFcm();
  }

  /// main에서 캐시해둔 FCM 토큰이 있으면 로그인 직후 백엔드에 등록.
  void _maybeRegisterCachedFcm() {
    final t = cachedFcmToken;
    if (t != null && t.isNotEmpty && state.token != null) {
      registerDeviceToken(t);
    }
  }

  Future<void> applySignupResult({
    required String name,
    required String userId,
    required String phone,
    required String address,
    required bool agreedPrivacy,
    required ChurchRegistryPerson? matchedRegistry,
    String? token,
    bool isAdmin = false,
    bool isStaff = false,
  }) async {
    final role = isAdmin
        ? AccountRole.admin
        : isStaff
            ? AccountRole.staff
            : (matchedRegistry != null ? AccountRole.member : AccountRole.pending);

    state = AuthState(
      isLoggedIn: true,
      role: role,
      token: token,
      name: name,
      userId: userId,
      phone: phone,
      address: address,
      registry: matchedRegistry,
    );
    await _persist();
    _maybeRegisterCachedFcm();
  }

  void setRole(AccountRole role) {
    if (!state.isLoggedIn) return;
    state = state.copyWith(role: role);
    _persist();
  }

  Future<void> registerDeviceToken(String fcmToken) async {
    final token = state.token;
    if (token == null || fcmToken.isEmpty) return;
    try {
      await ApiService().post('/api/v1/devices/token', {
        'token': fcmToken,
        'platform': 'flutter',
      });
    } catch (_) {}
  }

  Future<void> withdraw() async {
    final token = state.token;
    if (token == null) return;
    try {
      await ApiService().delete('/api/v1/users/me');
    } finally {
      state = AuthState.guest;
      _persist();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
