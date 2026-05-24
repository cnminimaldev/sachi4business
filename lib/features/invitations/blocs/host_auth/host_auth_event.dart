import 'package:equatable/equatable.dart';

abstract class HostAuthEvent extends Equatable {
  const HostAuthEvent();
  @override
  List<Object> get props => [];
}

class VerifyPinRequested extends HostAuthEvent {
  final String token;
  final String pin;

  const VerifyPinRequested({required this.token, required this.pin});

  @override
  List<Object> get props => [token, pin];
}
