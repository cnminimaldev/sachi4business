import 'package:flutter/material.dart';
import 'package:wedding_admin_panel/features/invitations/views/widgets/invitation_view_template.dart';
import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';

class InvitationPreviewScreen extends StatelessWidget {
  final Invitation invitation;

  const InvitationPreviewScreen({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Nền tối để làm nổi bật khung thiệp
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Xem trước Thiệp',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          // ---> BỌC THÊM ASPECT RATIO VÀO ĐÂY <---
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: InvitationViewTemplate(
                invitation: invitation,
              ), // GỌI WIDGET DÙNG CHUNG
            ),
          ),
        ),
      ),
    );
  }
}
