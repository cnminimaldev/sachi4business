import 'package:equatable/equatable.dart';
import '../../models/invitation.dart';

abstract class HostAuthState extends Equatable {
  const HostAuthState();
  @override
  List<Object?> get props => [];
}

class HostAuthInitial extends HostAuthState {}

class HostAuthLoading extends HostAuthState {}

class HostAuthSuccess extends HostAuthState {
  final Invitation invitation;
  const HostAuthSuccess(this.invitation);
  @override
  List<Object> get props => [invitation];
}

class HostAuthFailure extends HostAuthState {
  final String message;
  const HostAuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

class HostAuthLocked extends HostAuthState {
  final DateTime lockoutUntil;
  final String message;
  const HostAuthLocked(this.lockoutUntil, this.message);
  @override
  List<Object> get props => [lockoutUntil, message];
}
