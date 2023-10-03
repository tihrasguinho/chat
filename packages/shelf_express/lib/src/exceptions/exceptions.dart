abstract class ExpressException implements Exception {
  final int statusCode;
  final String message;

  ExpressException(this.statusCode, this.message);
}

class BadRequestException extends ExpressException {
  BadRequestException(String message) : super(400, message);
}

class UnauthorizedException extends ExpressException {
  UnauthorizedException(String message) : super(401, message);
}

class ForbiddenException extends ExpressException {
  ForbiddenException(String message) : super(403, message);
}

class NotFoundException extends ExpressException {
  NotFoundException(String message) : super(404, message);
}

class MethodNotAllowedException extends ExpressException {
  MethodNotAllowedException(String message) : super(405, message);
}

class ConflictException extends ExpressException {
  ConflictException(String message) : super(409, message);
}

class InternalServerErrorException extends ExpressException {
  InternalServerErrorException(String message) : super(500, message);
}

class NotImplementedException extends ExpressException {
  NotImplementedException(String message) : super(501, message);
}
