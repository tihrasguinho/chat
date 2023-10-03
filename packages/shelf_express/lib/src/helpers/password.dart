import 'dart:convert';

import 'package:crypto/crypto.dart';

class Password {
  static String hash(String password, {Hash hash = sha256}) {
    return hash.convert(utf8.encode(password)).toString();
  }

  static bool verify(String password, String hashed, {Hash hash = sha256}) {
    return hash.convert(utf8.encode(password)).toString() == hashed;
  }
}
