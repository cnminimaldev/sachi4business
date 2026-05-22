import '../../models/invitation.dart';

abstract class InvitationEvent {}

class LoadInvitations extends InvitationEvent {}

class DeleteInvitation extends InvitationEvent {
  final String id;

  DeleteInvitation(this.id);
}

// Bổ sung sự kiện Nhân bản thiệp
class CloneInvitation extends InvitationEvent {
  final Invitation oldInvitation;

  CloneInvitation(this.oldInvitation);
}
