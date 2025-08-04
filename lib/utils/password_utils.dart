// lib/utils/password_utils.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Mã hóa mật khẩu bằng thuật toán SHA-256
String hashPassword(String password) {
  final bytes = utf8.encode(password);          // Chuyển mật khẩu thành bytes UTF8
  final digest = sha256.convert(bytes);         // Mã hóa SHA-256
  return digest.toString();                      // Trả về chuỗi hex dạng string
}