import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark } // Renamed to AppTheme to avoid clashing with Flutter's Theme widget

class Settings {
  final bool enableTimetableAlarms;
  final AppTheme appTheme;

  Settings({this.enableTimetableAlarms = false, this.appTheme = AppTheme.dark});

  Settings copyWith({bool? enableTimetableAlarms, AppTheme? appTheme}){
    return Settings(
      enableTimetableAlarms: enableTimetableAlarms ?? this.enableTimetableAlarms,
      appTheme: appTheme ?? this.appTheme,
    );
  }
}

// 1. Change Notifier to AsyncNotifier
class SettingsNotifier extends AsyncNotifier<Settings> {
  late final SharedPreferences _prefs;

  @override
  Future<Settings> build() async {
    // 2. Fetch SharedPreferences directly inside the async build pipeline
    _prefs = await SharedPreferences.getInstance();

    final themeString = _prefs.getString('appTheme');
    final enableAlarms = _prefs.getBool('enableAlarms') ?? false; // Fallback to false if null

    AppTheme appTheme = AppTheme.dark;
    if (themeString == 'light') {
      appTheme = AppTheme.light;
    }

    return Settings(enableTimetableAlarms: enableAlarms, appTheme: appTheme);
  }

  // 3. Update both the local state and state persistence on disk
  Future<void> updateAlarms(bool alarms) async {
    // Standard pattern to update local state while preserving previous settings data
    final currentSettings = state.value ?? Settings();
    state = AsyncData(currentSettings.copyWith(enableTimetableAlarms: alarms));
    await _prefs.setBool('enableAlarms', alarms);
  }

  Future<void> updateTheme(AppTheme theme) async {
    final currentSettings = state.value ?? Settings();
    state = AsyncData(currentSettings.copyWith(appTheme: theme));
    await _prefs.setString('appTheme', theme.name); // Using .name yields 'light' or 'dark'
  }
}

// 4. Update the provider definition type
final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);