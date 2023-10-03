import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;

class Response extends shelf.Response {
  Response._(
    super.statusCode, {
    super.body,
    super.headers,
    super.context,
    super.encoding,
  });

  factory Response.json({
    int statusCode = HttpStatus.ok,
    Object? body,
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Encoding? encoding,
  }) {
    return Response._(
      statusCode,
      body: body != null ? jsonEncode(body) : null,
      headers: {'Content-Type': 'application/json', ...?headers},
      context: context,
      encoding: encoding,
    );
  }
}
