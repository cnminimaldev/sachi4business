import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';
import '../blocs/invitation/invitation_bloc.dart';
import '../blocs/invitation/invitation_event.dart';
import '../blocs/invitation/invitation_state.dart';

// --- WIDGET BỌC NGOÀI ĐỂ CUNG CẤP BLOC ---
class InvitationListScreen extends StatelessWidget {
  const InvitationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvitationBloc()..add(LoadInvitations()),
      child: const _InvitationListView(),
    );
  }
}

// --- GIAO DIỆN CHÍNH SỬ DỤNG BLOC ---
class _InvitationListView extends StatefulWidget {
  const _InvitationListView();

  @override
  State<_InvitationListView> createState() => _InvitationListViewState();
}

class _InvitationListViewState extends State<_InvitationListView> {
  bool _isGridView = true;

  // --- HÀM CẤP QUYỀN HOST ---
  Future<void> _showHostAccessDialog(
    BuildContext context,
    Invitation invitation,
  ) async {
    String currentPin = invitation.managePin ?? '';
    final String currentToken = invitation.manageToken ?? invitation.id;

    if (currentPin.isEmpty) {
      SmartDialog.showLoading(msg: 'Đang khởi tạo quyền truy cập...');
      final rnd = Random();
      currentPin = (rnd.nextInt(9000) + 1000).toString();

      try {
        await Supabase.instance.client
            .from('invitations')
            .update({'manage_pin': currentPin})
            .eq('id', invitation.id);

        SmartDialog.dismiss();
        if (mounted) context.read<InvitationBloc>().add(LoadInvitations());
      } catch (e) {
        SmartDialog.dismiss();
        SmartDialog.showToast('Lỗi tạo mã PIN: $e');
        return;
      }
    }

    final baseUrl = Uri.base.origin;
    final hostLink = '$baseUrl/host/$currentToken';

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '🔐 Quyền quản lý Dâu/Rể',
          style: TextStyle(color: AppTheme.deepPink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gửi thông tin này cho chủ tiệc để họ tự quản lý khách mời của mình:',
              style: TextStyle(color: AppTheme.textMain),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link truy cập:',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hostLink,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mã PIN (Mật khẩu):',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentPin,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 6,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy gửi khách'),
            onPressed: () {
              final message =
                  'Dạ Sachi gửi anh/chị link quản lý khách mời ạ:\n👉 Link: $hostLink\n🔑 Mã PIN: $currentPin';
              Clipboard.setData(ClipboardData(text: message));
              SmartDialog.showToast('Đã copy tin nhắn mẫu! 📋');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // --- HÀM COPY LINK GỬI KHÁCH ---
  void _copyPublicLink(String id) {
    final baseUrl = Uri.base.origin;
    final link = '$baseUrl/i/$id';
    Clipboard.setData(ClipboardData(text: link));
    SmartDialog.showToast('Đã sao chép link gửi khách! 💌');
  }

  // --- HÀM NHÂN BẢN THIỆP ---
  Future<void> _cloneInvitation(Invitation oldInvitation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Nhân bản thiệp',
          style: TextStyle(
            color: AppTheme.primaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tạo một bản sao từ thiệp của\n"${oldInvitation.brideName} & ${oldInvitation.groomName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nhân bản'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<InvitationBloc>().add(CloneInvitation(oldInvitation));
    }
  }

  // --- HÀM XÁC NHẬN XÓA THIỆP ---
  void _confirmDelete(
    BuildContext context,
    String invitationId,
    String bride,
    String groom,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa thiệp cưới của\n"$bride & $groom" không?\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InvitationBloc>().add(
                DeleteInvitation(invitationId),
              );
            },
            child: const Text(
              'Xóa vĩnh viễn',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        title: const Text(
          'Quản lý Thiệp cưới',
          style: TextStyle(
            color: AppTheme.textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isGridView
                ? 'Chuyển sang dạng Danh sách'
                : 'Chuyển sang dạng Lưới',
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppTheme.textMain,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: BlocConsumer<InvitationBloc, InvitationState>(
        listener: (context, state) {
          if (state is InvitationLoading) {
            SmartDialog.showLoading(msg: 'Đang xử lý...');
          } else if (state is InvitationError) {
            SmartDialog.dismiss();
            SmartDialog.showToast(state.message);
          } else if (state is InvitationOperationSuccess) {
            SmartDialog.dismiss();
            SmartDialog.showToast(state.message);
          } else if (state is InvitationsLoaded) {
            SmartDialog.dismiss();
          }
        },
        builder: (context, state) {
          if (state is InvitationInitial ||
              (state is InvitationLoading && state is! InvitationsLoaded)) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          if (state is InvitationsLoaded) {
            final data = state.invitations;
            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: AppTheme.secondaryPink.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có thiệp cưới nào.',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isGridView
                    ? _buildGridView(data)
                    : _buildListView(data),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.deepPink,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tạo thiệp mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          await context.push('/invitations/create');
          if (context.mounted)
            context.read<InvitationBloc>().add(LoadInvitations());
        },
      ),
    );
  }

  // ==========================================
  // GIAO DIỆN DẠNG LƯỚI (GRID CARDS)
  // ==========================================
  Widget _buildGridView(List<Invitation> data) {
    return GridView.builder(
      key: const ValueKey('gridView'),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.75,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildInvitationCard(data[index]);
      },
    );
  }

  // ==========================================
  // GIAO DIỆN DẠNG DANH SÁCH (LIST VIEW)
  // ==========================================
  Widget _buildListView(List<Invitation> data) {
    return ListView.separated(
      key: const ValueKey('listView'),
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final invitation = data[index];
        final statusConfig = _getStatusConfig(invitation.status);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.secondaryPink.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    invitation.coverUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.secondaryPink.withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${invitation.brideName} & ${invitation.groomName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat(
                              'dd/MM/yyyy',
                            ).format(invitation.eventDate),
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusConfig.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusConfig.text,
                              style: TextStyle(
                                color: statusConfig.color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(invitation),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // WIDGET CARD DÙNG CHUNG CHO LƯỚI
  // ==========================================
  Widget _buildInvitationCard(Invitation invitation) {
    final statusConfig = _getStatusConfig(invitation.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.secondaryPink.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  invitation.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(color: AppTheme.secondaryPink.withOpacity(0.2)),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusConfig.text,
                      style: TextStyle(
                        color: statusConfig.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${invitation.brideName} & ${invitation.groomName}',
                  style: const TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy').format(invitation.eventDate),
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.secondaryPink.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: _buildActionButtons(invitation),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NHÓM NÚT THAO TÁC (DÙNG CHUNG)
  // ==========================================
  Widget _buildActionButtons(Invitation invitation) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Chỉnh sửa nội dung',
            icon: const Icon(
              Icons.edit_rounded,
              color: AppTheme.textMain,
              size: 20,
            ),
            onPressed: () async {
              await context.push('/invitations/create', extra: invitation);
              if (context.mounted)
                context.read<InvitationBloc>().add(LoadInvitations());
            },
          ),
          IconButton(
            tooltip: 'Quản lý Khách mời & RSVP',
            icon: const Icon(
              Icons.people_alt_rounded,
              color: AppTheme.deepPink,
              size: 20,
            ),
            onPressed: () =>
                context.push('/invitations/guests', extra: invitation),
          ),
          IconButton(
            tooltip: 'Sao chép link gửi khách',
            icon: const Icon(
              Icons.share_rounded,
              color: AppTheme.primaryPink,
              size: 20,
            ),
            onPressed: () => _copyPublicLink(invitation.id),
          ),
          // Các thao tác phụ được gom vào Menu 3 chấm để giao diện không bị quá tải
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppTheme.textLight,
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'preview':
                  context.push('/invitations/preview', extra: invitation);
                  break;
                case 'host':
                  _showHostAccessDialog(context, invitation);
                  break;
                case 'clone':
                  _cloneInvitation(invitation);
                  break;
                case 'delete':
                  _confirmDelete(
                    context,
                    invitation.id,
                    invitation.brideName,
                    invitation.groomName,
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'preview',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      size: 18,
                      color: AppTheme.textMain,
                    ),
                    SizedBox(width: 8),
                    Text('Xem trước thiệp'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'host',
                child: Row(
                  children: [
                    Icon(Icons.vpn_key_rounded, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Cấp quyền Dâu/Rể'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clone',
                child: Row(
                  children: [
                    Icon(
                      Icons.content_copy_rounded,
                      size: 18,
                      color: AppTheme.primaryPink,
                    ),
                    SizedBox(width: 8),
                    Text('Nhân bản thiệp'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Xóa thiệp',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CẤU HÌNH TRẠNG THÁI
  // ==========================================
  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'active':
        return _StatusConfig(Colors.green.shade400, 'Đã thanh toán');
      case 'draft':
        return _StatusConfig(Colors.orange.shade400, 'Bản nháp');
      case 'expired':
        return _StatusConfig(Colors.grey.shade500, 'Hết hạn');
      default:
        return _StatusConfig(AppTheme.secondaryPink, 'Không rõ');
    }
  }
}

class _StatusConfig {
  final Color color;
  final String text;
  _StatusConfig(this.color, this.text);
}
