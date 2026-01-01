import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/is_authenticated_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final IsAuthenticatedUseCase isAuthenticatedUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.isAuthenticatedUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase.execute(event.email, event.password);
    _handleAuthResult(result, emit);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUseCase.execute(
      event.name,
      event.email,
      event.password,
    );
    _handleAuthResult(result, emit);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUseCase.execute();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Nous émettons d'abord un état de chargement pour éviter un écran blanc
    emit(AuthLoading());
    
    try {
      // Timeout pour éviter le blocage
      final authResult = await isAuthenticatedUseCase.execute()
          .timeout(const Duration(seconds: 5));
          
      await authResult.fold(
        (failure) async {
          print('⚠️ CheckAuthStatus - isAuthenticated failed: $failure');
          emit(AuthUnauthenticated());
        },
        (isAuthenticated) async {
          if (isAuthenticated) {
            final userResult = await getCurrentUserUseCase.execute()
                .timeout(const Duration(seconds: 3));
            userResult.fold(
              (failure) {
                print('⚠️ CheckAuthStatus - getCurrentUser failed: $failure');
                emit(AuthUnauthenticated());
              },
              (user) => emit(AuthAuthenticated(user: user)),
            );
          } else {
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      // En cas de timeout ou d'erreur, on considère l'utilisateur comme non authentifié
      print('⚠️ CheckAuthStatus error: $e');
      emit(AuthUnauthenticated());
    }
  }

  void _handleAuthResult(
    Either<Failure, User> result,
    Emitter<AuthState> emit,
  ) {
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
}
