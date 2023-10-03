import 'package:shelf_express/shelf_express.dart';

abstract class ChatException implements Exception {
  final int statusCode;
  final String message;

  ChatException(this.statusCode, this.message);

  Response get toResponse => Response.json(
        statusCode: statusCode,
        body: {
          'error': message,
        },
      );
}

class BadRequestException extends ChatException {
  BadRequestException(String message) : super(400, message);
}

class UnauthorizedException extends ChatException {
  UnauthorizedException(String message) : super(401, message);
}

class ForbiddenException extends ChatException {
  ForbiddenException(String message) : super(403, message);
}

class NotFoundException extends ChatException {
  NotFoundException(String message) : super(404, message);
}

class ConflictException extends ChatException {
  ConflictException(String message) : super(409, message);
}

class InternalServerErrorException extends ChatException {
  InternalServerErrorException(String message) : super(500, message);
}

class UnimplementedException extends ChatException {
  UnimplementedException(String message) : super(501, message);
}
