import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LogInRequested extends AuthEvent {
  final String email;
  final String password;

  const LogInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogOutRequested extends AuthEvent {}
