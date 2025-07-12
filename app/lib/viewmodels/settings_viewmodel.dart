import '../services/robot_api_service.dart';
import 'base_viewmodel.dart';

/// Setting information
class SettingInfo {
  final String name;
  final String displayName;
  final dynamic value;
  final dynamic minValue;
  final dynamic maxValue;
  final String description;

  const SettingInfo({
    required this.name,
    required this.displayName,
    required this.value,
    this.minValue,
    this.maxValue,
    required this.description,
  });

  SettingInfo copyWith({
    String? name,
    String? displayName,
    dynamic value,
    dynamic minValue,
    dynamic maxValue,
    String? description,
  }) {
    return SettingInfo(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      value: value ?? this.value,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      description: description ?? this.description,
    );
  }
}

/// State for settings control
class SettingsState extends BaseViewState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<SettingInfo> settings;

  const SettingsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.settings = const [],
  });

  SettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<SettingInfo>? settings,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        settings,
      ];
}

/// ViewModel for settings control
class SettingsViewModel extends BaseViewModel<SettingsState> {
  final RobotAPIService _robotAPIService;

  static const List<SettingInfo> _defaultSettings = [
    SettingInfo(
      name: 'steering_offset',
      displayName: 'Steering Offset',
      value: 0,
      minValue: -100,
      maxValue: 100,
      description: 'Adjust steering calibration (-100 to 100)',
    ),
    SettingInfo(
      name: 'motor_deadzone',
      displayName: 'Motor Deadzone',
      value: 25,
      minValue: 0,
      maxValue: 250,
      description: 'Motor deadzone value (0 to 250)',
    ),
    SettingInfo(
      name: 'auto_mode',
      displayName: 'Auto Mode',
      value: false,
      description: 'Enable automatic mode',
    ),
  ];

  SettingsViewModel({
    required RobotAPIService robotAPIService,
  })  : _robotAPIService = robotAPIService,
        super(const SettingsState(settings: _defaultSettings));

  /// Update a setting value
  Future<void> updateSetting(String settingName, dynamic value) async {
    // Update setting value in state immediately for responsive UI
    final updatedSettings = state.settings.map((setting) {
      if (setting.name == settingName) {
        return setting.copyWith(value: value);
      }
      return setting;
    }).toList();

    setState(state.copyWith(
      settings: updatedSettings,
      errorMessage: null,
      successMessage: null,
    ));

    await executeWithLoading(
      () => _robotAPIService.updateSetting(settingName, value),
      (response) => state.copyWith(
        successMessage: 'Setting ${_getDisplayName(settingName)} updated successfully',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to update setting: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Update steering offset
  Future<void> updateSteeringOffset(int offset) async {
    if (offset < -100 || offset > 100) {
      setState(state.copyWith(
        errorMessage: 'Steering offset must be between -100 and 100',
      ));
      return;
    }
    await updateSetting('steering_offset', offset);
  }

  /// Update motor deadzone
  Future<void> updateMotorDeadzone(int deadzone) async {
    if (deadzone < 0 || deadzone > 250) {
      setState(state.copyWith(
        errorMessage: 'Motor deadzone must be between 0 and 250',
      ));
      return;
    }
    await updateSetting('motor_deadzone', deadzone);
  }

  /// Update auto mode
  Future<void> updateAutoMode(bool enabled) async {
    await updateSetting('auto_mode', enabled);
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    setState(state.copyWith(
      settings: _defaultSettings,
      errorMessage: null,
      successMessage: 'Settings reset to defaults',
    ));

    // Send updates to server
    for (final setting in _defaultSettings) {
      try {
        await _robotAPIService.updateSetting(setting.name, setting.value);
      } catch (e) {
        // Continue with other settings even if one fails
      }
    }
  }

  /// Get setting by name
  SettingInfo? getSetting(String settingName) {
    try {
      return state.settings.firstWhere((s) => s.name == settingName);
    } catch (e) {
      return null;
    }
  }

  /// Get display name for setting
  String _getDisplayName(String settingName) {
    final setting = state.settings.firstWhere(
      (s) => s.name == settingName,
      orElse: () => const SettingInfo(
        name: '',
        displayName: 'Unknown',
        value: null,
        description: '',
      ),
    );
    return setting.displayName;
  }

  /// Clear messages
  void clearMessages() {
    setState(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}