import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formflow/models/user_model.dart';
import 'package:formflow/services/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignOutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthState {}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  bool _isCheckingAuth = false;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Prevent multiple simultaneous auth checks
    if (_isCheckingAuth) {
      print('🔍 AuthBloc: Auth check already in progress, skipping...');
      return;
    }

    _isCheckingAuth = true;
    print('🔍 AuthBloc: AuthCheckRequested event received');

    try {
      emit(AuthLoading());

      final user = AuthService.currentUser;
      print(
          '🔍 AuthBloc: Current user from AuthService: ${user?.uid ?? 'null'}');

      if (user != null) {
        print(
            '🔍 AuthBloc: Emitting Authenticated state for user: ${user.uid}');
        emit(Authenticated(user));
      } else {
        print('🔍 AuthBloc: Emitting Unauthenticated state');
        emit(Unauthenticated());
      }
    } catch (e) {
      print('🔍 AuthBloc: Error during auth check: $e');
      // Don't emit error state on auth check failure, keep current state
      // This prevents the cohort list from disappearing due to auth errors
      print('🔍 AuthBloc: Keeping current state due to auth check error');
    } finally {
      _isCheckingAuth = false;
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await AuthService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await AuthService.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      // After successful signup, emit authenticated state
      emit(Authenticated(user));

      // Don't sign out immediately - let the signup screen handle the flow
      // The user should be able to sign in immediately after signup
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await AuthService.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await AuthService.sendPasswordResetEmail(event.email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
