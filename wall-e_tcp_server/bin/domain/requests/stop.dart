import 'request.dart';

class Stop extends Request {
  Stop(super.type);

  @override
  String get toExternalAction => type;

  static Request fromJson(Map<String, dynamic> json) {
    return Stop('stop');
  }
}