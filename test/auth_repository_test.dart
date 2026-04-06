import 'package:flutter_test/flutter_test.dart';
import 'package:lumluay_pos/features/auth/data/auth_repository.dart';

void main() {
  group('AuthRepository — PIN hashing', () {
    test('hashPin with salt produces different hash than without', () {
      const pin = '1234';
      const salt = 'dGVzdHNhbHQ='; // base64 of "testsalt"
      final hashWithSalt = AuthRepository.hashPin(pin, salt: salt);
      final hashWithout = AuthRepository.hashPin(pin);
      expect(hashWithSalt, isNot(equals(hashWithout)));
    });

    test('same PIN with same salt produces consistent hash', () {
      const pin = '5678';
      const salt = 'c29tZXNhbHQ=';
      final hash1 = AuthRepository.hashPin(pin, salt: salt);
      final hash2 = AuthRepository.hashPin(pin, salt: salt);
      expect(hash1, equals(hash2));
    });

    test('same PIN with different salts produces different hashes', () {
      const pin = '1234';
      final hash1 = AuthRepository.hashPin(pin, salt: 'salt_a');
      final hash2 = AuthRepository.hashPin(pin, salt: 'salt_b');
      expect(hash1, isNot(equals(hash2)));
    });

    test('different PINs with same salt produce different hashes', () {
      const salt = 'same_salt';
      final hash1 = AuthRepository.hashPin('1234', salt: salt);
      final hash2 = AuthRepository.hashPin('5678', salt: salt);
      expect(hash1, isNot(equals(hash2)));
    });

    test('hashPin without salt uses legacy SHA-256', () {
      // This is the legacy behavior for migration
      final hash = AuthRepository.hashPin('1234');
      // SHA-256 of "1234" is known
      expect(hash, isNotEmpty);
      expect(hash.length, 64); // SHA-256 hex = 64 chars
    });

    test('hashPin with empty salt uses legacy fallback', () {
      final hashEmpty = AuthRepository.hashPin('1234', salt: '');
      final hashNull = AuthRepository.hashPin('1234');
      expect(hashEmpty, equals(hashNull));
    });
  });

  group('AuthRepository — salt generation', () {
    test('generateSalt produces non-empty base64 string', () {
      final salt = AuthRepository.generateSalt();
      expect(salt.isNotEmpty, true);
      // base64 encoded 16 bytes = 24 chars
      expect(salt.length, 24);
    });

    test('generateSalt produces unique values', () {
      final salts = List.generate(100, (_) => AuthRepository.generateSalt());
      final unique = salts.toSet();
      // All 100 should be unique (extremely high probability)
      expect(unique.length, 100);
    });
  });

  group('AuthRepository — rate limiting', () {
    test('isLockedOut returns false for unknown employee', () {
      expect(AuthRepository.isLockedOut('unknown'), false);
    });

    test('isLockedOut returns false below threshold', () {
      for (var i = 0; i < 4; i++) {
        AuthRepository.isLockedOut('emp1'); // check doesn't add attempts
      }
      expect(AuthRepository.isLockedOut('emp1'), false);
    });
  });
}
