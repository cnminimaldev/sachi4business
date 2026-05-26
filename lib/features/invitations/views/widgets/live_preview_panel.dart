import 'package:flutter/material.dart';
import '../../models/invitation.dart';

// Import các mẫu template của bạn tại đây
import '../templates/tpl_a1_screen.dart';
// import '../templates/tpl_minimalist_screen.dart';
// import '../templates/tpl_classic_screen.dart';

class LivePreviewPanel extends StatelessWidget {
  final Invitation invitation;

  const LivePreviewPanel({super.key, required this.invitation});

  // Nạp giao diện Template tương ứng với lựa chọn hiện tại
  Widget _getTemplateView() {
    switch (invitation.templateId) {
      case 'tpl_a1':
        return TplA1Screen(invitation: invitation);
      case 'tpl_minimalist':
      // return TplMinimalistScreen(invitation: invitation);
      case 'tpl_classic':
      // return TplClassicScreen(invitation: invitation);
      default:
        return const Center(
          child: Text(
            'Chưa nạp được giao diện mẫu này 🌸',
            style: TextStyle(color: Color(0xFF9E928A)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(
        0xFFF5F2EB,
      ), // Nền kem trầm nhẹ làm nổi bật khung điện thoại
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          width: 375, // Kích thước chuẩn mô phỏng thiết bị di động
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC8DD).withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            // Khung viền mô phỏng viền điện thoại mỏng nhẹ
            border: Border.all(color: Colors.white, width: 6),
          ),
          clipBehavior: Clip.antiAlias,
          child: _getTemplateView(),
        ),
      ),
    );
  }
}
