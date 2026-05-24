import '../../models/invitation.dart';

abstract class InvitationEvent {}

class LoadInvitations extends InvitationEvent {}

class DeleteInvitation extends InvitationEvent {
  final String id;

  DeleteInvitation(this.id);
}

class CloneInvitation extends InvitationEvent {
  final Invitation oldInvitation;

  CloneInvitation(this.oldInvitation);
}

class SaveInvitation extends InvitationEvent {
  final Invitation invitation;
  SaveInvitation(this.invitation);
}
