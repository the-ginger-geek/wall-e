import 'request.dart';

class Disconnect extends Request {
  Disconnect(super.type);

  @override
  String get toExternalAction => type;

  static Request fromJson(Map<String, dynamic> json) {
    return Disconnect('disconnect');
  }
}