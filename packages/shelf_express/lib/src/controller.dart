import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'method.dart';
import 'route.dart';

abstract class Controller {
  late final List<Route> _routes;
  final String path;

  Controller(this.path) {
    _routes = [];
  }

  void add(Method method, String path, Function handler) {
    _routes.add(Route(method, path, handler));
  }

  void all(String path, Function handler) {
    add(Method.get, path, handler);
    add(Method.post, path, handler);
    add(Method.put, path, handler);
    add(Method.delete, path, handler);
  }

  void get(String path, Function handler) {
    add(Method.get, path, handler);
  }

  void post(String path, Function handler) {
    add(Method.post, path, handler);
  }

  void put(String path, Function handler) {
    add(Method.put, path, handler);
  }

  void delete(String path, Function handler) {
    add(Method.delete, path, handler);
  }

  shelf.Handler get routes {
    final router = shelf_router.Router();
    for (final route in _routes) {
      router.add(route.method.verb, route.path, route.handler);
    }
    return router;
  }
}
