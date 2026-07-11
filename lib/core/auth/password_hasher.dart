import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class PasswordDigest {
  const PasswordDigest({
    required this.hashBase64,
    required this.saltBase64,
    required this.iterations,
    required this.algorithm,
  });

  final String hashBase64;
  final String saltBase64;
  final int iterations;
  final String algorithm;
}

class Pbkdf2PasswordHasher {
  Pbkdf2PasswordHasher({
    this.iterations = 600000,
    this.derivedKeyLength = 32,
    this.saltLength = 16,
    Random? secureRandom,
  }) : _random = secureRandom ?? Random.secure() {
    if (iterations < 1 || derivedKeyLength < 16 || saltLength < 8) {
      throw ArgumentError('Invalid password hashing parameters.');
    }
  }

  static const algorithm = 'PBKDF2-HMAC-SHA256';

  final int iterations;
  final int derivedKeyLength;
  final int saltLength;
  final Random _random;

  PasswordDigest hashPassword(
    String password, {
    bool multiFactorActivationSecret = false,
  }) {
    validateNewPassword(
      password,
      multiFactorActivationSecret: multiFactorActivationSecret,
    );
    final salt = Uint8List.fromList(
      List<int>.generate(saltLength, (_) => _random.nextInt(256)),
    );
    final hash = _derive(utf8.encode(password), salt, iterations);
    return PasswordDigest(
      hashBase64: base64Encode(hash),
      saltBase64: base64Encode(salt),
      iterations: iterations,
      algorithm: algorithm,
    );
  }

  bool verify({
    required String password,
    required String expectedHashBase64,
    required String saltBase64,
    required int iterations,
    required String algorithmName,
  }) {
    if (algorithmName != algorithm || iterations < 1) return false;
    try {
      final salt = base64Decode(saltBase64);
      final expected = base64Decode(expectedHashBase64);
      final actual = _derive(utf8.encode(password), salt, iterations,
          outputLength: expected.length);
      if (actual.length != expected.length) return false;
      var difference = 0;
      for (var index = 0; index < actual.length; index++) {
        difference |= actual[index] ^ expected[index];
      }
      return difference == 0;
    } catch (_) {
      return false;
    }
  }

  void validateNewPassword(
    String password, {
    bool multiFactorActivationSecret = false,
  }) {
    final minimum = multiFactorActivationSecret ? 8 : 15;
    if (password.runes.length < minimum) {
      throw PasswordPolicyException(
        'Password must contain at least $minimum characters.',
      );
    }
    if (password.runes.length > 128) {
      throw const PasswordPolicyException(
        'Password must not exceed 128 characters.',
      );
    }
    final normalized = password.trim().toLowerCase();
    if (_blockedPasswords.contains(normalized)) {
      throw const PasswordPolicyException(
        'Choose a password that is not commonly used or specific to this POS.',
      );
    }
  }

  Uint8List _derive(
    List<int> password,
    List<int> salt,
    int workFactor, {
    int? outputLength,
  }) {
    final length = outputLength ?? derivedKeyLength;
    final hmac = Hmac(sha256, password);
    final blockCount = (length / sha256.convert(const []).bytes.length).ceil();
    final output = <int>[];
    for (var block = 1; block <= blockCount; block++) {
      final blockBytes = [
        (block >> 24) & 0xff,
        (block >> 16) & 0xff,
        (block >> 8) & 0xff,
        block & 0xff,
      ];
      var current = hmac.convert([...salt, ...blockBytes]).bytes;
      final accumulated = List<int>.from(current);
      for (var iteration = 1; iteration < workFactor; iteration++) {
        current = hmac.convert(current).bytes;
        for (var index = 0; index < accumulated.length; index++) {
          accumulated[index] ^= current[index];
        }
      }
      output.addAll(accumulated);
    }
    return Uint8List.fromList(output.take(length).toList());
  }

  static const _blockedPasswords = {
    'password',
    'password123',
    '123456789012345',
    'admin1234567890',
    'cashier123456789',
    'xantara123456789',
  };
}

class PasswordPolicyException implements Exception {
  const PasswordPolicyException(this.message);
  final String message;
  @override
  String toString() => message;
}
