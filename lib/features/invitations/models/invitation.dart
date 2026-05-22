class Invitation {
  final String id;
  final String templateId;
  final String brideName;
  final String groomName;
  final String coverUrl; // Link ảnh bìa
  final String
  status; // 'draft' (Bản nháp), 'active' (Đang chạy), 'expired' (Hết hạn)
  final DateTime eventDate; // Ngày cưới
  final List<SectionData> sections;
  final String? manageToken; // Thêm trường Token
  final String? managePin; // Thêm trường PIN

  Invitation({
    required this.id,
    required this.templateId,
    required this.brideName,
    required this.groomName,
    required this.coverUrl,
    required this.status,
    required this.eventDate,
    required this.sections,
    this.manageToken,
    this.managePin,
  });

  // ---> THÊM HÀM NÀY ĐỂ ĐỌC DATA TỪ SUPABASE <---
  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      templateId: json['template_id'] as String? ?? '1',
      brideName: json['bride_name'] as String,
      groomName: json['groom_name'] as String,
      // Tạm thời lấy ảnh bìa là ảnh đầu tiên trong gallery (nếu có), hoặc link rỗng
      coverUrl: json['cover_url'] ?? 'https://placehold.net/default.png',
      status: json['status'] as String,
      eventDate: DateTime.parse(json['event_date']),
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => SectionData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      manageToken: json['manage_token'],
      managePin: json['manage_pin'],
    );
  }
}

class SectionData {
  String id;
  String type;
  String title;
  bool isActive;
  Map<String, dynamic> content;

  SectionData({
    required this.id,
    required this.type,
    required this.title,
    this.isActive = false,
    Map<String, dynamic>? content,
  }) : content = content ?? <String, dynamic>{};

  // ---> THÊM HÀM NÀY ĐỂ ĐỌC DATA SECTION <---
  factory SectionData.fromJson(Map<String, dynamic> json) {
    return SectionData(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      isActive: json['isActive'] as bool? ?? true,
      content: json['content'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
}
