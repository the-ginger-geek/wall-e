import 'request.dart';

class Setting extends Request {
  final SettingType settingType;
  final double value;

  Setting(super.type, {required this.settingType, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = SettingType.values.firstWhere(
      (t) => t.name == typeString,
      orElse: () => SettingType.steeringOffset, // Default to steeringOffset if not found
    );

    return Setting(
      'setting',
      settingType: type,
      value: json['value'] as double? ?? 0.0, // Default value to 0.0 if not provided
    );
  }

  @override
  String get toExternalAction => '${settingType.name}{$value}';
}

enum SettingType {
  steeringOffset('steering_offset', 'S'),
  motorDeadzone('motor_deadzone', 'O'),
  autoMode('auto_mode', 'M');

  final String name;
  final String code;

  const SettingType(this.name, this.code);
}