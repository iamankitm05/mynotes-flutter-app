import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialize()) {
    on<AuthEventInitialize>((event, emit) async {
      // send email verification
      on<AuthEventSendEmailVerification>((event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      });
      on<AuthEventRegister>((event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(
            email: email,
            password: password,
          );
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification());
        } on Exception catch (e) {
          emit(AuthStateRegistering(e));
        }
      });
      // initialize
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLogedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLogedIn(user));
      }
      // login in
      on<AuthEventLogIn>((event, emit) async {
        emit(const AuthStateUninitialize());
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );

          if (!user.isEmailVerified) {
            emit(
              const AuthStateLogedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(const AuthStateNeedsVerification());
          } else {
            emit(
              const AuthStateLogedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(AuthStateLogedIn(user));
          }
        } on Exception catch (e) {
          emit(
            AuthStateLogedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      });
      // log out
      on<AuthEventLogOut>((event, emit) async {
        try {
          await provider.logOut();
          emit(
            const AuthStateLogedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          emit(
            AuthStateLogedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      });
    });
  }
}
