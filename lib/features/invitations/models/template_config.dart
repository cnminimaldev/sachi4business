class TemplateConfig {
  final String id;
  final String name;
  final bool hasCoverPhoto; // Có cần chọn ảnh bìa từ Media Pool không?
  final bool hasParentsInfo; // Thông tin nhà trai/nhà gái
  final bool hasLunarDate; // Ngày âm lịch
  final int requiredOurStoryCount; // Số lượng Our Story (0 là không có)
  final bool hasTimeline; // Dòng thời gian tình yêu
  final bool hasMiniAlbum; // Có chọn nhiều ảnh làm album không?
  final bool hasQrCode; // QR Code nhận quà
  final bool hasAudio; // Có nhạc nền không?

  const TemplateConfig({
    required this.id,
    required this.name,
    this.hasCoverPhoto = true,
    this.hasParentsInfo = true,
    this.hasLunarDate = true,
    this.requiredOurStoryCount = 0,
    this.hasTimeline = false,
    this.hasMiniAlbum = false,
    this.hasQrCode = true,
    this.hasAudio = true,
  });
}

// Danh sách các template cấu hình sẵn của Sachi
const List<TemplateConfig> availableTemplates = [
  TemplateConfig(
    id: 'tpl_a1',
    name: 'Mẫu A1 (Đầy đủ chi tiết)',
    requiredOurStoryCount: 2, // Đòi hỏi nhập 2 câu chuyện
    hasTimeline: true,
    hasMiniAlbum: true,
  ),
  TemplateConfig(
    id: 'tpl_minimalist',
    name: 'Tối giản Nhật Bản (Lược bỏ)',
    requiredOurStoryCount: 0, // Ẩn section Our Story
    hasTimeline: false, // Ẩn section Timeline
    hasMiniAlbum: false, // Ẩn section Album
  ),
  TemplateConfig(
    id: 'tpl_classic',
    name: 'Cổ điển thanh lịch',
    requiredOurStoryCount: 1,
    hasTimeline: false,
    hasMiniAlbum: true,
  ),
];
