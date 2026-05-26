import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Điều chỉnh đường dẫn import theo cấu trúc dự án của bạn
import '../../models/invitation.dart';
import '../../../../core/theme/app_theme.dart';

class TplA1Screen extends StatelessWidget {
  final Invitation invitation;

  const TplA1Screen({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    // Ép kiểu dynamicData an toàn
    final Map<String, dynamic> data = invitation.dynamicData;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: Center(
        child: ConstrainedBox(
          // Giới hạn chiều rộng tối đa để hiển thị đẹp trên cả Web/Desktop và Mobile
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryPink.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCoverSection(context),
                  const SizedBox(height: 40),
                  _buildParentsSection(data),
                  const SizedBox(height: 40),
                  _buildInvitationMessage(),
                  const SizedBox(height: 40),

                  // Our Story (Mẫu A1 yêu cầu 2 câu chuyện)
                  if (data['our_stories'] != null &&
                      (data['our_stories'] as List).isNotEmpty)
                    _buildOurStorySection(data['our_stories']),

                  // Timeline (Mẫu A1 có timeline)
                  if (data['timeline'] != null &&
                      (data['timeline'] as List).isNotEmpty)
                    _buildTimelineSection(data['timeline']),

                  // Mini Album (Lấy các ảnh còn lại trong Media Pool)
                  if (invitation.uploadedImages.length > 1) _buildMiniAlbum(),

                  // QR Code Nhận quà
                  if (data['qr_code_url'] != null &&
                      data['qr_code_url'].toString().isNotEmpty)
                    _buildGiftSection(data),

                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. ẢNH BÌA & THÔNG TIN CHÍNH
  // ==========================================
  Widget _buildCoverSection(BuildContext context) {
    String coverUrl = 'https://via.placeholder.com/600x800?text=Sachi+Wedding';
    if (invitation.uploadedImages.isNotEmpty) {
      coverUrl = invitation.uploadedImages[invitation.coverImageIndex ?? 0];
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Ảnh bìa
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(coverUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(64),
              bottomRight: Radius.circular(64),
            ),
          ),
        ),
        // Overlay mờ để làm nổi bật chữ
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(64),
              bottomRight: Radius.circular(64),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                AppTheme.primaryPink.withOpacity(0.6),
                AppTheme.backgroundCream.withOpacity(0.95),
              ],
            ),
          ),
        ),
        // Tên Dâu Rể & Ngày tháng
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            children: [
              Text(
                'Save the Date',
                style: GoogleFonts.dancingScript(
                  fontSize: 24,
                  color: AppTheme.deepPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${invitation.brideName} & ${invitation.groomName}',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.secondaryPink),
                ),
                child: Text(
                  DateFormat('dd . MM . yyyy').format(invitation.eventDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. THÔNG TIN PHỤ HUYNH
  // ==========================================
  Widget _buildParentsSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nhà Trai
          Expanded(
            child: Column(
              children: [
                const Text(
                  'NHÀ TRAI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepPink,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ông: ${data['groom_father'] ?? '...'}',
                  style: const TextStyle(color: AppTheme.textMain),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Bà: ${data['groom_mother'] ?? '...'}',
                  style: const TextStyle(color: AppTheme.textMain),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Icon nối giữa
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryPink.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: AppTheme.primaryPink,
              size: 20,
            ),
          ),
          // Nhà Gái
          Expanded(
            child: Column(
              children: [
                const Text(
                  'NHÀ GÁI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepPink,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ông: ${data['bride_father'] ?? '...'}',
                  style: const TextStyle(color: AppTheme.textMain),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Bà: ${data['bride_mother'] ?? '...'}',
                  style: const TextStyle(color: AppTheme.textMain),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. LỜI NGỎ
  // ==========================================
  Widget _buildInvitationMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.secondaryPink),
          const SizedBox(height: 16),
          Text(
            'Trân trọng kính mời quý khách đến dự buổi tiệc chung vui cùng gia đình chúng tôi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.textMain.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. CÂU CHUYỆN TÌNH YÊU (OUR STORY)
  // ==========================================
  Widget _buildOurStorySection(List<dynamic> stories) {
    return Container(
      color: AppTheme.backgroundCream,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          _buildSectionTitle('Our Story'),
          const SizedBox(height: 32),
          ...stories.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> story = entry.value;
            bool isEven = index % 2 == 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                //textDirection: isEven ? TextDirection.LTR : TextDirection.RTL,
                children: [
                  // Ảnh minh họa
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: NetworkImage(
                            story['image_url']?.isNotEmpty == true
                                ? story['image_url']
                                : 'https://via.placeholder.com/300?text=Sachi',
                          ),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryPink.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nội dung
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: isEven
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(
                          story['date'] ?? '',
                          style: const TextStyle(
                            color: AppTheme.deepPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          story['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textMain,
                          ),
                          textAlign: isEven ? TextAlign.left : TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          story['description'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLight,
                            height: 1.5,
                          ),
                          textAlign: isEven ? TextAlign.left : TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 5. TIMELINE
  // ==========================================
  Widget _buildTimelineSection(List<dynamic> timeline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(
        children: [
          _buildSectionTitle('Timeline'),
          const SizedBox(height: 32),
          ...timeline.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryPink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item['time'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepPink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      item['event'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textMain,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 6. MINI ALBUM
  // ==========================================
  Widget _buildMiniAlbum() {
    // Loại bỏ ảnh bìa khỏi album nếu cần thiết
    List<String> albumImages = List.from(invitation.uploadedImages);
    if (invitation.coverImageIndex != null &&
        invitation.coverImageIndex! < albumImages.length) {
      albumImages.removeAt(invitation.coverImageIndex!);
    }

    if (albumImages.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppTheme.backgroundCream,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          _buildSectionTitle('Our Moments'),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: min(albumImages.length, 6), // Hiển thị tối đa 6 ảnh
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(albumImages[index], fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 7. QR CODE NHẬN QUÀ
  // ==========================================
  Widget _buildGiftSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(
        children: [
          _buildSectionTitle('Gửi Lời Chúc'),
          const SizedBox(height: 16),
          Text(
            'Sự hiện diện của bạn là món quà tuyệt vời nhất.\nNếu không thể tham dự, bạn có thể gửi lời chúc qua đây.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppTheme.secondaryPink.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryPink.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    data['qr_code_url'],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data['bank_name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepPink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['bank_account'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FOOTER THƯƠNG HIỆU SACHI
  // ==========================================
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      color: AppTheme.primaryPink.withOpacity(0.1),
      child: Column(
        children: [
          Text(
            'Sachi',
            style: GoogleFonts.dancingScript(
              fontSize: 28,
              color: AppTheme.deepPink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Minimalist Digital Wedding Invitation',
            style: TextStyle(fontSize: 11, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  // Hàm tiện ích tạo Tiêu đề Section
  Widget _buildSectionTitle(String title) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 40, height: 2, color: AppTheme.primaryPink),
      ],
    );
  }
}
