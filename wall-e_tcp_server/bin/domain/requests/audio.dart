import 'request.dart';

class Audio extends Request {
  final AudioCommand command;
  final String? argument;

  Audio(super.type, {required this.command, this.argument});

  Map<String, dynamic> toJson() {
    return {
      'command': command.name,
      if (argument != null) 'argument': argument,
    };
  }

  factory Audio.fromJson(Map<String, dynamic> json) {
    final commandString = json['command'] as String;
    final command = AudioCommand.values.firstWhere(
      (c) => c.name == commandString,
      orElse: () => AudioCommand.list,
    );

    return Audio(
      'audio',
      command: command,
      argument: json['argument'] as String?,
    );
  }

  @override
  String get toExternalAction {
    if (argument != null) {
      return 'audio ${command.name} $argument';
    }
    return 'audio ${command.name}';
  }
}

enum AudioCommand {
  play('play'),
  speak('speak'),
  list('list');

  final String name;
  const AudioCommand(this.name);
}