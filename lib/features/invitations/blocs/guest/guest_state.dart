import '../../models/guest.dart';

abstract class GuestState {}

class GuestInitial extends GuestState {}

class GuestLoading extends GuestState {}

class GuestLoaded extends GuestState {
  final List<Guest> guests;

  GuestLoaded(this.guests);
}

class GuestOperationSuccess extends GuestState {
  final String message;

  GuestOperationSuccess(this.message);
}

class GuestError extends GuestState {
  final String message;

  GuestError(this.message);
}
