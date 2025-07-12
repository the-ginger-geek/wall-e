import 'request.dart';

class Animation extends Request {
  final String id;

  Animation(super.type, {required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory Animation.fromJson(Map<String, dynamic> json) {
    return Animation(
      'animation',
      id: json['id'] as String,
    );
  }

  @override
  String get toExternalAction => 'A{$id}';
}