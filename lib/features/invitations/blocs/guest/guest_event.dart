abstract class GuestEvent {}

class LoadGuests extends GuestEvent {
  final String invitationId;

  LoadGuests(this.invitationId);
}

class AddGuest extends GuestEvent {
  final String invitationId;
  final String title;
  final String name;
  final String suffix;
  final String note;

  AddGuest({
    required this.invitationId,
    required this.title,
    required this.name,
    required this.suffix,
    required this.note,
  });
}

class DeleteGuest extends GuestEvent {
  final String guestId;
  final String invitationId; // Cần ID thiệp để tải lại danh sách sau khi xóa

  DeleteGuest({required this.guestId, required this.invitationId});
}
