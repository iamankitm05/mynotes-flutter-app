import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      // initialize
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLogedOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLogedIn(user));
      }
      // login in
      on<AuthEventLogIn>((event, emit) async {
        emit(const AuthStateLoading());
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );
          emit(AuthStateLogedIn(user));
        } on Exception catch (e) {
          emit(AuthStateLoginFailure(e));
        }
      });
      // log out 
      on<AuthEventLogOut>((event, emit) async {
        try {
          emit(const AuthStateLoading());
          await provider.logOut();
          emit(const AuthStateLogedOut());
        } on Exception catch(e) {
          emit(AuthStateLogoutFailure(e));
        }
      });
    });
  }
}
