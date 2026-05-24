class Invitation {
  final String id;
  final String title;
  final String templateId;
  final String brideName;
  final String groomName;
  final String status;
  final DateTime eventDate;

  // Quản lý Media Pool và Dữ liệu động
  final List<String> uploadedImages;
  final int? coverImageIndex;
  final Map<String, dynamic> dynamicData;

  final String? manageToken;
  final String? managePin;

  Invitation({
    required this.id,
    this.title = 'Thiệp chưa đặt tên',
    required this.templateId,
    required this.brideName,
    required this.groomName,
    required this.status,
    required this.eventDate,
    this.uploadedImages = const [],
    this.coverImageIndex,
    this.dynamicData = const {},
    this.manageToken,
    this.managePin,
  });

  // ĐỌC DỮ LIỆU TỪ SUPABASE
  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Thiệp chưa đặt tên',
      templateId: json['template_id'] as String? ?? 'tpl_minimalist',
      brideName: json['bride_name'] as String? ?? '',
      groomName: json['groom_name'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'])
          : DateTime.now(),

      // Parse list ảnh từ mảng JSONB
      uploadedImages:
          (json['uploaded_images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      coverImageIndex: json['cover_image_index'] as int?,

      // Lấy map dữ liệu động (Đã đổi tên cột thành dynamic_data trên DB)
      dynamicData: json['dynamic_data'] as Map<String, dynamic>? ?? {},

      manageToken: json['manage_token'],
      managePin: json['manage_pin'],
    );
  }

  // ĐÓNG GÓI DỮ LIỆU ĐỂ LƯU LÊN SUPABASE
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id, // Chỉ gửi ID nếu là update
      'title': title,
      'template_id': templateId,
      'bride_name': brideName,
      'groom_name': groomName,
      'status': status,
      'event_date': eventDate.toIso8601String(),
      'uploaded_images': uploadedImages,
      'cover_image_index': coverImageIndex,
      'dynamic_data': dynamicData,
    };
  }

  // Hàm tạo bản sao với dữ liệu mới (Dùng trong Editor State)
  Invitation copyWith({
    String? id,
    String? title,
    String? templateId,
    String? brideName,
    String? groomName,
    String? status,
    DateTime? eventDate,
    List<String>? uploadedImages,
    int? coverImageIndex,
    Map<String, dynamic>? dynamicData,
    String? manageToken,
    String? managePin,
  }) {
    return Invitation(
      id: id ?? this.id,
      title: title ?? this.title,
      templateId: templateId ?? this.templateId,
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      status: status ?? this.status,
      eventDate: eventDate ?? this.eventDate,
      uploadedImages: uploadedImages ?? this.uploadedImages,
      coverImageIndex: coverImageIndex ?? this.coverImageIndex,
      dynamicData: dynamicData ?? this.dynamicData,
      manageToken: manageToken ?? this.manageToken,
      managePin: managePin ?? this.managePin,
    );
  }

  // Tiện ích lấy URL ảnh bìa (Dành cho màn hình Danh sách thiệp)
  String get coverUrl {
    if (coverImageIndex != null &&
        uploadedImages.isNotEmpty &&
        coverImageIndex! < uploadedImages.length) {
      return uploadedImages[coverImageIndex!];
    }
    return 'https://placehold.net/default.png';
  }
}
