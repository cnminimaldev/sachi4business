import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';
import '../models/guest.dart';
import '../blocs/guest/guest_bloc.dart';
import '../blocs/guest/guest_event.dart';
import '../blocs/guest/guest_state.dart';

// --- WIDGET BỌC NGOÀI ĐỂ CUNG CẤP BLOC ---
class GuestManagementScreen extends StatelessWidget {
  final Invitation invitation;

  const GuestManagementScreen({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Khởi tạo BLoC và bắn ngay event LoadGuests khi vừa mở màn hình
      create: (context) => GuestBloc()..add(LoadGuests(invitation.id)),
      child: _GuestManagementView(invitation: invitation),
    );
  }
}

// --- GIAO DIỆN CHÍNH (KHÔNG CÒN GỌI DATABASE TRỰC TIẾP) ---
class _GuestManagementView extends StatefulWidget {
  final Invitation invitation;

  const _GuestManagementView({required this.invitation});

  @override
  State<_GuestManagementView> createState() => _GuestManagementViewState();
}

class _GuestManagementViewState extends State<_GuestManagementView> {
  // Biến đệm để giữ danh sách khách hiển thị không bị chớp giật khi State thay đổi
  List<Guest> _currentGuests = [];

  // --- HÀM SAO CHÉP LINK SIÊU NGẮN (Giữ nguyên logic cũ vì không liên quan database) ---
  void _copyGuestLink(Guest guest) {
    final baseUrl = Uri.base.origin;
    final code = guest.guestCode ?? guest.id;
    final link = '$baseUrl/g/$code';

    Clipboard.setData(ClipboardData(text: link));

    final displayName =
        '${guest.guestTitle} ${guest.guestName} ${guest.guestSuffix ?? ''}'
            .trim();
    SmartDialog.showToast('Đã copy link gửi cho $displayName 💌');
  }

  // --- DIALOG NHẬP LIỆU ---
  void _showAddGuestDialog() {
    // Lấy instance của BLoC trước khi mở Dialog (vì Dialog nằm ở route khác)
    final guestBloc = context.read<GuestBloc>();

    String selectedTitle = 'Anh/Chị';
    String selectedSuffix = '';
    final nameController = TextEditingController();
    final noteController = TextEditingController();

    final titles = [
      'Anh/Chị',
      'Anh',
      'Chị',
      'Em',
      'Bạn',
      'Cô/Chú',
      'Cô',
      'Chú',
      'Bác',
      'Ông/Bà',
    ];
    final suffixes = [
      {'label': 'Không có', 'value': ''},
      {'label': 'và gia đình', 'value': 'và gia đình'},
      {'label': 'và người thương', 'value': 'và người thương'},
      {'label': 'và phu quân', 'value': 'và phu quân'},
      {'label': 'và phu nhân', 'value': 'và phu nhân'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Thêm khách mời mới',
          style: TextStyle(color: AppTheme.deepPink),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        value: selectedTitle,
                        decoration: const InputDecoration(
                          labelText: 'Danh xưng',
                        ),
                        items: titles
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setStateDialog(() => selectedTitle = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên khách mời',
                          hintText: 'VD: Công, Lan...',
                        ),
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSuffix,
                  decoration: const InputDecoration(labelText: 'Hậu tố đi kèm'),
                  items: suffixes
                      .map(
                        (s) => DropdownMenuItem(
                          value: s['value']!,
                          child: Text(s['label']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedSuffix = val!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú nội bộ (Tùy chọn)',
                    hintText: 'VD: Bạn cấp 3, Đồng nghiệp...',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // BẮN SỰ KIỆN VÀO BLOC THAY VÌ GỌI API
                guestBloc.add(
                  AddGuest(
                    invitationId: widget.invitation.id,
                    title: selectedTitle,
                    name: nameController.text,
                    suffix: selectedSuffix,
                    note: noteController.text,
                  ),
                );
              }
            },
            child: const Text('Lưu & Thêm'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý khách mời',
              style: TextStyle(
                color: AppTheme.textMain,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.invitation.brideName} & ${widget.invitation.groomName}',
              style: const TextStyle(color: AppTheme.deepPink, fontSize: 13),
            ),
          ],
        ),
      ),

      // SỬ DỤNG BLOCCONSUMER ĐỂ VỪA LẮNG NGHE (Hiện Popup) VỪA VẼ UI
      body: BlocConsumer<GuestBloc, GuestState>(
        listener: (context, state) {
          // Xử lý các hiệu ứng phụ (Side-effects) như Loading, Toast
          if (state is GuestLoading && _currentGuests.isNotEmpty) {
            SmartDialog.showLoading(msg: 'Đang xử lý...');
          } else if (state is GuestOperationSuccess) {
            SmartDialog.dismiss();
            SmartDialog.showToast(state.message);
          } else if (state is GuestError) {
            SmartDialog.dismiss();
            SmartDialog.showToast(state.message);
          } else if (state is GuestLoaded) {
            SmartDialog.dismiss();
          }
        },
        builder: (context, state) {
          // Cập nhật dữ liệu đệm nếu BLoC trả về list mới
          if (state is GuestLoaded) {
            _currentGuests = state.guests;
          }

          // Trạng thái đang tải lần đầu
          if (state is GuestLoading && _currentGuests.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          // Tính toán thống kê
          final total = _currentGuests.length;
          final attending = _currentGuests
              .where((g) => g.rsvpStatus == 'attending')
              .length;
          final viewed = _currentGuests.where((g) => g.viewed).length;

          return Column(
            children: [
              Container(
                color: AppTheme.surfaceWhite,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Tổng khách',
                      total.toString(),
                      Colors.blueGrey,
                    ),
                    _buildStatItem(
                      'Đã xem thiệp',
                      viewed.toString(),
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'Sẽ tham dự',
                      attending.toString(),
                      Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _currentGuests.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có khách mời nào. Bấm nút + để thêm nhé!',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _currentGuests.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildGuestCard(
                            context,
                            _currentGuests[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGuestDialog,
        backgroundColor: AppTheme.deepPink,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm khách'),
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context, Guest guest) {
    Color statusColor = Colors.grey;
    String statusText = 'Chưa phản hồi';
    if (guest.rsvpStatus == 'attending') {
      statusColor = Colors.green;
      statusText = 'Tham dự (${guest.paxCount} người)';
    } else if (guest.rsvpStatus == 'declined') {
      statusColor = Colors.redAccent;
      statusText = 'Từ chối';
    }

    final displayName =
        '${guest.guestTitle} ${guest.guestName} ${guest.guestSuffix ?? ''}'
            .trim();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.secondaryPink.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (guest.viewed)
              const Icon(
                Icons.remove_red_eye,
                color: AppTheme.primaryPink,
                size: 16,
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (guest.guestCode != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• Mã: ${guest.guestCode}',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              if (guest.note != null && guest.note!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Ghi chú: ${guest.note}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Copy link gửi khách',
              icon: const Icon(Icons.copy, color: AppTheme.deepPink),
              onPressed: () => _copyGuestLink(guest),
            ),
            IconButton(
              tooltip: 'Xóa',
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () {
                // BẮN SỰ KIỆN XÓA VÀO BLOC
                context.read<GuestBloc>().add(
                  DeleteGuest(
                    guestId: guest.id,
                    invitationId: widget.invitation.id,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
        ),
      ],
    );
  }
}
