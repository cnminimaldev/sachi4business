import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wedding_admin_panel/features/invitations/views/widgets/invitation_view_template.dart';
import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';

class GuestInvitationScreen extends StatefulWidget {
  final String invitationId;

  const GuestInvitationScreen({super.key, required this.invitationId});

  @override
  State<GuestInvitationScreen> createState() => _GuestInvitationScreenState();
}

class _GuestInvitationScreenState extends State<GuestInvitationScreen> {
  late Future<Invitation> _invitationFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo hàm lấy dữ liệu từ Supabase dựa vào ID trên URL
    _invitationFuture = _fetchInvitation();
  }

  Future<Invitation> _fetchInvitation() async {
    final response = await Supabase.instance.client
        .from('invitations')
        .select()
        .eq('id', widget.invitationId)
        .single(); // single() đảm bảo chỉ trả về 1 object thay vì 1 mảng

    return Invitation.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen tuyền, không có AppBar
      body: FutureBuilder<Invitation>(
        future: _invitationFuture,
        builder: (context, snapshot) {
          // 1. Trạng thái Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          // 2. Trạng thái Lỗi (Link sai hoặc thiệp bị xóa)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link_off, color: Colors.white54, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy thiệp cưới.\nVui lòng kiểm tra lại đường link!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 3. Trạng thái Thành công -> Hiển thị thiệp
          final invitation = snapshot.data!;

          return Center(
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
                  ),
                  child: InvitationViewTemplate(
                    invitation: invitation,
                  ), // GỌI WIDGET DÙNG CHUNG
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
