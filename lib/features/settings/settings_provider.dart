import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ v4 추가
enum DrawerVersion { v1Simple, v2Panel, v3PanelSections, v4PanelDropdown }

class AppSettingsState {
  final double fontScale;
  final bool pushEnabled;
  final bool hydrated;

  final DrawerVersion drawerVersion;

  const AppSettingsState({
    required this.fontScale,
    required this.pushEnabled,
    required this.hydrated,
    required this.drawerVersion,
  });

  AppSettingsState copyWith({
    double? fontScale,
    bool? pushEnabled,
    bool? hydrated,
    DrawerVersion? drawerVersion,
  }) {
    return AppSettingsState(
      fontScale: fontScale ?? this.fontScale,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      hydrated: hydrated ?? this.hydrated,
      drawerVersion: drawerVersion ?? this.drawerVersion,
    );
  }

  static const initial = AppSettingsState(
    fontScale: 1.0,
    pushEnabled: true,
    hydrated: false,
    drawerVersion: DrawerVersion.v2Panel,
  );
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(AppSettingsState.initial) {
    _load();
  }

  static const _kFontScale = 'settings.fontScale';
  static const _kPushEnabled = 'settings.pushEnabled';
  static const _kDrawerVersion = 'settings.drawerVersion';

  SharedPreferences? _prefs;

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();

    final fontScale = _prefs!.getDouble(_kFontScale) ?? 1.0;
    final pushEnabled = _prefs!.getBool(_kPushEnabled) ?? true;

    final drawerRaw = _prefs!.getString(_kDrawerVersion);

    // ✅ v4 포함 로드
    final drawerVersion = DrawerVersion.values.firstWhere(
          (e) => e.name == drawerRaw,
      orElse: () => DrawerVersion.v2Panel,
    );

    final bounded = fontScale.clamp(0.85, 1.25).toDouble();

    state = state.copyWith(
      fontScale: bounded,
      pushEnabled: pushEnabled,
      drawerVersion: drawerVersion,
      hydrated: true,
    );
  }

  Future<void> setFontScale(double v) async {
    final bounded = v.clamp(0.85, 1.25).toDouble();
    state = state.copyWith(fontScale: bounded);

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setDouble(_kFontScale, bounded);
  }

  Future<void> setPushEnabled(bool v) async {
    state = state.copyWith(pushEnabled: v);

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool(_kPushEnabled, v);
  }

  Future<void> setDrawerVersion(DrawerVersion v) async {
    state = state.copyWith(drawerVersion: v);

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(_kDrawerVersion, v.name);
  }
}

final appSettingsProvider =
StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier();
});
