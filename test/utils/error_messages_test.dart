import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skill_swap/utils/error_messages.dart';

void main() {
  group('friendlyError', () {
    test('returns plain message for null', () {
      expect(friendlyError(null), 'Something went wrong. Please try again.');
    });

    test('maps known FirebaseAuth codes', () {
      expect(
        friendlyError(FirebaseAuthException(code: 'invalid-credential')),
        'Email or password is incorrect.',
      );
      expect(
        friendlyError(FirebaseAuthException(code: 'invalid-email')),
        'That email address is not valid.',
      );
      expect(
        friendlyError(FirebaseAuthException(code: 'email-already-in-use')),
        'That email is already registered. Try signing in.',
      );
      expect(
        friendlyError(FirebaseAuthException(code: 'weak-password')),
        'Password is too weak. Use at least 6 characters.',
      );
      expect(
        friendlyError(FirebaseAuthException(code: 'too-many-requests')),
        'Too many attempts. Try again in a moment.',
      );
      expect(
        friendlyError(FirebaseAuthException(code: 'network-request-failed')),
        'No internet connection.',
      );
    });

    test('falls back to FirebaseAuth message for unknown codes', () {
      final e = FirebaseAuthException(
        code: 'something-unknown',
        message: 'Server says X',
      );
      expect(friendlyError(e), 'Server says X');
    });

    test('maps known FirebaseException codes', () {
      expect(
        friendlyError(FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied')),
        "You don't have access to do that.",
      );
      expect(
        friendlyError(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable')),
        'Service is temporarily unavailable. Try again.',
      );
      expect(
        friendlyError(FirebaseException(plugin: 'cloud_firestore', code: 'cancelled')),
        'That action was cancelled.',
      );
    });

    test('returns generic message for unknown exception types', () {
      expect(friendlyError(Exception('raw')), 'Something went wrong. Please try again.');
      expect(friendlyError('a string'), 'Something went wrong. Please try again.');
      expect(friendlyError(StateError('bad state')), 'Something went wrong. Please try again.');
    });
  });
}
