import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';
import '../models/guest.dart';
import 'templates/tpl_minimalist_screen.dart';
import 'templates/tpl_classic_screen.dart';

class GuestInvitationScreen extends StatefulWidget {
  final String? invitationId; // Dùng cho link chung /i/:id
  final String? guestCode; // Dùng cho link cá nhân hóa /g/:code

  const GuestInvitationScreen({super.key, this.invitationId, this.guestCode});

  @override
  State<GuestInvitationScreen> createState() => _GuestInvitationScreenState();
}

class _GuestInvitationScreenState extends State<GuestInvitationScreen> {
  // Trả về một Map chứa cả thông tin Thiệp và Khách mời
  late Future<Map<String, dynamic>?> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchFullData();
  }

  Future<Map<String, dynamic>?> _fetchFullData() async {
    try {
      Guest? guest;
      String? targetInvitationId = widget.invitationId;

      // 1. Nếu có mã khách ngắn, tiến hành giải mã
      if (widget.guestCode != null) {
        final guestRes = await Supabase.instance.client
            .from('guests')
            .select()
            .eq('guest_code', widget.guestCode!)
            .maybeSingle();

        if (guestRes != null) {
          guest = Guest.fromJson(guestRes);
          targetInvitationId = guest.invitationId;

          // TỰ ĐỘNG TRACKING: Âm thầm cập nhật trạng thái "Đã xem" lên Supabase
          if (!guest.viewed) {
            await Supabase.instance.client
                .from('guests')
                .update({'viewed': true})
                .eq('id', guest.id);
          }
        }
      }

      // 2. Tải thông tin thiệp cưới tương ứng
      if (targetInvitationId == null) return null;

      final inviteRes = await Supabase.instance.client
          .from('invitations')
          .select()
          .eq('id', targetInvitationId)
          .maybeSingle();

      if (inviteRes == null) return null;

      return {'invitation': Invitation.fromJson(inviteRes), 'guest': guest};
    } catch (e) {
      print('Lỗi giải mã luồng dữ liệu khách mời: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double targetRatio = 9 / 16;

    double appWidth = screenSize.width / screenSize.height > targetRatio
        ? screenSize.height * targetRatio
        : screenSize.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: appWidth,
          height: screenSize.height,
          decoration: BoxDecoration(
            color: AppTheme.backgroundCream,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryPink),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Không tìm thấy thiệp cưới hoặc đường dẫn đã hết hạn 🌸',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight, fontSize: 16),
                    ),
                  ),
                );
              }

              final invitation = snapshot.data!['invitation'] as Invitation;
              final guest = snapshot.data!['guest'] as Guest?;

              // ĐIỀU PHỐI VÀ TRUYỀN THÊM ĐỐI TƯỢNG GUEST VÀO TRONG UI MAY ĐO
              switch (invitation.templateId) {
                case 'tpl_1':
                  // Nếu muốn, sau này bạn cập nhật cả tpl_1 tương tự tpl_2
                  return TplMinimalistScreen(invitation: invitation);
                case 'tpl_2':
                  return TplClassicScreen(invitation: invitation, guest: guest);
                default:
                  return TplClassicScreen(invitation: invitation, guest: guest);
              }
            },
          ),
        ),
      ),
    );
  }
}
