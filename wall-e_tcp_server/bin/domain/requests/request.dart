abstract class Request {
  final String type;

  Request(this.type);

  String get toExternalAction;
}