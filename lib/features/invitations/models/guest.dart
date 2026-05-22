class Guest {
  final String id;
  final String invitationId;
  final String guestTitle;
  final String guestName;
  final String? guestSuffix;
  final String? guestCode;
  final String? note; // ---> THÊM TRƯỜNG NOTE Ở ĐÂY
  final bool viewed;
  final String rsvpStatus;
  final int paxCount;

  Guest({
    required this.id,
    required this.invitationId,
    required this.guestTitle,
    required this.guestName,
    this.guestSuffix,
    this.guestCode,
    this.note, // ---> THÊM VÀO CONSTRUCTOR
    required this.viewed,
    required this.rsvpStatus,
    required this.paxCount,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      invitationId: json['invitation_id'],
      guestTitle: json['guest_title'],
      guestName: json['guest_name'],
      guestSuffix: json['guest_suffix'],
      guestCode: json['guest_code'],
      note: json['note'], // ---> THÊM VÀO MAPPING JSON
      viewed: json['viewed'] ?? false,
      rsvpStatus: json['rsvp_status'] ?? 'pending',
      paxCount: json['pax_count'] ?? 1,
    );
  }
}
