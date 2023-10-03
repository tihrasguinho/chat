import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'controller.dart';
import 'method.dart';
import 'route.dart';

class Express {
  final List<Route> _routes = [];
  final List<Controller> _controllers = [];
  final List<Middleware> _middlewares = [];

  Express();

  Express all(String path, Function handler) {
    _routes.addAll([
      Route.get(path, handler),
      Route.post(path, handler),
      Route.put(path, handler),
      Route.delete(path, handler),
    ]);

    return this;
  }

  Express add(Method method, String path, Function handler) {
    _routes.add(Route(method, path, handler));
    return this;
  }

  Express get(String path, Function handler) {
    _routes.add(Route.get(path, handler));
    return this;
  }

  Express post(String path, Function handler) {
    _routes.add(Route.post(path, handler));
    return this;
  }

  Express put(String path, Function handler) {
    _routes.add(Route.put(path, handler));
    return this;
  }

  Express delete(String path, Function handler) {
    _routes.add(Route.delete(path, handler));
    return this;
  }

  Express use(Controller controller) {
    _controllers.add(controller);
    return this;
  }

  Express middleware(Middleware middleware) {
    _middlewares.add(middleware);
    return this;
  }

  Future<HttpServer> start({Object address = '0.0.0.0', int port = 8080, void Function()? onListen}) async {
    final router = shelf_router.Router();

    for (final route in _routes) {
      router.add(route.method.verb, route.path, route.handler);
    }
    for (final controller in _controllers) {
      router.mount(controller.path, controller.routes);
    }
    var handler = Pipeline().addHandler(router);
    for (final middleware in _middlewares) {
      handler = middleware(handler);
    }

    return await shelf_io.serve(handler, address, port).whenComplete(() => onListen?.call());
  }
}
