import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLogedIn extends AuthState {
  final AuthUser user;
  const AuthStateLogedIn(this.user);
}

class AuthStateLoginFailure extends AuthState {
  final Exception exception;
  const AuthStateLoginFailure(this.exception);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLogedOut extends AuthState {
  const AuthStateLogedOut();
}

class AuthStateLogoutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
}