import 'request.dart';

class Status extends Request {
  Status() : super('status');

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status();
  }

  @override
  String get toExternalAction => 'STATUS';

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}