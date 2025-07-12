import 'request.dart';

class Camera extends Request {
  final CameraCommand command;

  Camera(super.type, {required this.command});

  Map<String, dynamic> toJson() {
    return {
      'command': command.name,
    };
  }

  factory Camera.fromJson(Map<String, dynamic> json) {
    final commandString = json['command'] as String;
    final command = CameraCommand.values.firstWhere(
      (c) => c.name == commandString,
      orElse: () => CameraCommand.frame,
    );

    return Camera(
      'camera',
      command: command,
    );
  }

  @override
  String get toExternalAction => 'camera ${command.name}';
}

enum CameraCommand {
  start('start'),
  stop('stop'),
  frame('frame');

  final String name;
  const CameraCommand(this.name);
}