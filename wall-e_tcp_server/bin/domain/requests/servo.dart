import 'request.dart';

class Servo extends Request {
  // Servo name
  final ServoName name;

  // Value from 0 to 100
  final double value;

  Servo(super.type, {required this.name, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'name': name.name,
      'value': value,
    };
  }

  factory Servo.fromJson(Map<String, dynamic> json) {
    final nameString = json['name'] as String;
    final name = ServoName.values.firstWhere(
          (d) => d.name == nameString,
      orElse: () => ServoName.neckBottom,
    );

    return Servo(
      'servo',
      name: name,
      value: json['value'] as double? ?? 0.0, // Default speed to 0.0 if not provided
    );
  }

  @override
  String get toExternalAction => '${name.code} ${value.toStringAsFixed(2)}';
}

enum ServoName {
  headRotation('head_rotation', 'G'), // Head rotation servo
  neckTop('neck_top', 'T'), // Neck top servo
  neckBottom('neck_bottom', 'B'), // Neck bottom servo
  armLeft('arm_left', 'L'), // Left arm servo
  armRight('arm_right', 'R'), // Right arm servo
  eyeLeft('eye_left', 'E'), // Left eye servo
  eyeRight('eye_right', 'U'); // Right eye servo

  final String name;
  final String code;

  const ServoName(this.name, this.code);
}