import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account_role.dart';
import '../models/church_registry_person.dart';

class AuthState {
  final bool isLoggedIn;
  final AccountRole role;

  // 가입 계정 정보
  final String? userId;
  final String? name;
  final String? phone; // 숫자만
  final String? address;

  // 교적 매칭 결과(성도일 때 주입)
  final ChurchRegistryPerson? registry;

  const AuthState({
    required this.isLoggedIn,
    required this.role,
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
    String? userId,
    String? name,
    String? phone,
    String? address,
    ChurchRegistryPerson? registry,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
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

  void logout() {
    state = AuthState.guest;
  }

  /// 로그인(지금은 임시). 실제로는 서버 인증 후 role/registry를 받아오면 됨.
  void login({
    required String name,
    required String userId,
    required String phone,
    AccountRole role = AccountRole.pending,
    String? address,
    ChurchRegistryPerson? registry,
  }) {
    state = AuthState(
      isLoggedIn: true,
      role: role,
      name: name,
      userId: userId,
      phone: phone,
      address: address,
      registry: registry,
    );
  }

  /// 가입 완료 후, 교적 매칭 결과에 따라 role을 member/pending으로 확정
  void applySignupResult({
    required String name,
    required String userId,
    required String phone,
    required String address,
    required bool agreedPrivacy,
    required ChurchRegistryPerson? matchedRegistry,
    bool isAdmin = false,
    bool isStaff = false,
  }) {
    // 관리자/교역자는 “수동 부여”가 원칙이라 여기서는 기본 false로 두고,
    // 추후 관리자 화면에서 role을 승격시키면 됨.
    final role = isAdmin
        ? AccountRole.admin
        : isStaff
        ? AccountRole.staff
        : (matchedRegistry != null ? AccountRole.member : AccountRole.pending);

    state = AuthState(
      isLoggedIn: true,
      role: role,
      name: name,
      userId: userId,
      phone: phone,
      address: address,
      registry: matchedRegistry,
    );
  }

  /// 추후 관리자 기능: 교역자 권한 부여 등
  void setRole(AccountRole role) {
    if (!state.isLoggedIn) return;
    state = state.copyWith(role: role);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
