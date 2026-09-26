import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _generic = 'Something went wrong. Please try again.';

String friendlyError(Object? error) {
  if (error == null) return _generic;

  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'That email is already registered. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a moment.';
      case 'network-request-failed':
        return 'No internet connection.';
    }
    return error.message ?? _generic;
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return "You don't have access to do that.";
      case 'unavailable':
        return 'Service is temporarily unavailable. Try again.';
      case 'cancelled':
        return 'That action was cancelled.';
      case 'deadline-exceeded':
        return 'Took too long — check your connection.';
    }
    return error.message ?? _generic;
  }

  return _generic;
}
