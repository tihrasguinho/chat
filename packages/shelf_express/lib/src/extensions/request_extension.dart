import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_multipart/form_data.dart';

extension RequestExtension on shelf.Request {
  /// Gets the request body as a map of parameters.
  ///
  /// Returns a `Future` that contains a map of parameters, where the key is a
  /// string and the value is dynamic. If the request is of type `multipart/form-data`,
  /// the body will be parsed and the parameters will be extracted from the form fields,
  /// and if contains files, the files will be extracted
  /// as base64 encoded strings.
  /// If there is no body, an empty map will be returned.
  ///
  /// Example usage:
  /// ```dart
  /// final parameters = await request.body();
  /// print(parameters);
  /// ```
  Future<Map<String, dynamic>> body() async {
    if (isMultipartForm) {
      final parameters = <String, dynamic>{
        await for (final form in multipartFormData)
          form.name: form.filename != null ? 'data:${lookupMimeType(form.filename ?? 'application/octet-stream')};base64,${base64Encode(await form.part.readBytes())}' : await form.part.readString(),
      };

      return parameters;
    } else {
      return jsonDecode(await readAsString());
    }
  }

  String get path => requestedUri.path;

  Map<String, String> get queryParams => requestedUri.queryParameters;

  String get authorization => headers['Authorization']?.replaceAll('Bearer ', '') ?? '';

  T? fromContext<T extends Object>(String key) => context[key] as T;
}
