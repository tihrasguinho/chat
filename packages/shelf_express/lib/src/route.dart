import 'method.dart';

final class Route {
  final Method method;
  final String path;
  final Function handler;

  Route._({required this.method, required this.path, required this.handler});

  factory Route(Method method, String path, Function handler) {
    return Route._(method: method, path: path, handler: handler);
  }

  factory Route.get(String path, Function handler) {
    return Route._(method: Method.get, path: path, handler: handler);
  }

  factory Route.post(String path, Function handler) {
    return Route._(method: Method.post, path: path, handler: handler);
  }

  factory Route.put(String path, Function handler) {
    return Route._(method: Method.put, path: path, handler: handler);
  }

  factory Route.delete(String path, Function handler) {
    return Route._(method: Method.delete, path: path, handler: handler);
  }
}
