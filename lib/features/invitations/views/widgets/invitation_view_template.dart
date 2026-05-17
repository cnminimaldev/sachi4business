import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/invitation.dart';

// ĐÂY LÀ KHUNG XƯƠNG GIAO DIỆN CHÍNH, CHỈ DÙNG ĐỂ HIỂN THỊ
class InvitationViewTemplate extends StatelessWidget {
  final Invitation invitation;

  const InvitationViewTemplate({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Ảnh Bìa Hero
          Stack(
            children: [
              Image.network(
                invitation.coverUrl,
                height: 500,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 500,
                  color: AppTheme.secondaryPink.withOpacity(0.3),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 200,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    const Text(
                      'SAVE THE DATE',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 4,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${invitation.brideName} & ${invitation.groomName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd . MM . yyyy').format(invitation.eventDate),
                      style: const TextStyle(
                        color: AppTheme.primaryPink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Nội dung các Section động
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: invitation.sections.where((s) => s.isActive).map((
                section,
              ) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        section.title.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (section.type == 'gallery')
                        _buildGallery(
                          section.content['images'] as List<dynamic>?,
                        )
                      else if (section.type == 'our_story')
                        Text(
                          section.content['text'] ?? '',
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else if (section.type == 'timeline')
                        _buildTimeline(
                          section.content['items'] as List<dynamic>?,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. Lời chào cuối
          const Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Center(
              child: Text(
                'Trân trọng kính mời!',
                style: TextStyle(
                  color: AppTheme.deepPink,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM XÂY DỰNG SECTION THÀNH PHẦN ---
  Widget _buildGallery(List<dynamic>? images) {
    if (images == null || images.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(images[index], fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildTimeline(List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index] as Map<String, dynamic>;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 55,
              child: Text(
                item['time'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepPink,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index != items.length - 1)
                    Container(
                      width: 2,
                      height: 50,
                      color: AppTheme.secondaryPink.withOpacity(0.5),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMain,
                      fontSize: 15,
                    ),
                  ),
                  if (item['desc'] != null &&
                      (item['desc'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item['desc'],
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
