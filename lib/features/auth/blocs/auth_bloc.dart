import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LogInRequested>(_onLogInRequested);
    on<LogOutRequested>(_onLogOutRequested);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // Kiểm tra xem có session đăng nhập cũ không
    final session = _supabase.auth.currentSession;
    if (session != null && session.user != null) {
      emit(Authenticated(session.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onLogInRequested(LogInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        emit(Authenticated(response.user!));
      } else {
        emit(const AuthError("Đăng nhập thất bại. Vui lòng thử lại."));
        emit(Unauthenticated()); // Reset về trạng thái chưa đăng nhập
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  void _onLogOutRequested(
    LogOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _supabase.auth.signOut();
    emit(Unauthenticated());
  }
}
