import 'request.dart';

class Move extends Request {
  final double x, y;

  Move(super.type, {required this.x, required this.y});

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      'move',
      x: json['x'] as double? ?? 0.0,
      y: json['y'] as double? ?? 0.0,
    );
  }

  @override
  String get toExternalAction => '$type $x $y';
}