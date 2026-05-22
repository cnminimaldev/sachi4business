import '../../models/invitation.dart';

abstract class InvitationState {}

class InvitationInitial extends InvitationState {}

class InvitationLoading extends InvitationState {}

class InvitationsLoaded extends InvitationState {
  final List<Invitation> invitations;

  InvitationsLoaded(this.invitations);
}

class InvitationOperationSuccess extends InvitationState {
  final String message;
  final String?
  newInvitationId; // Dùng để tự động chuyển sang trang Editor nếu vừa tạo thiệp mới xong

  InvitationOperationSuccess(this.message, {this.newInvitationId});
}

class InvitationError extends InvitationState {
  final String message;

  InvitationError(this.message);
}
