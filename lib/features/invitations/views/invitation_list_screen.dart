import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';

class InvitationListScreen extends StatefulWidget {
  const InvitationListScreen({super.key});

  @override
  State<InvitationListScreen> createState() => _InvitationListScreenState();
}

class _InvitationListScreenState extends State<InvitationListScreen> {
  // Biến trạng thái để theo dõi chế độ xem hiện tại (Mặc định là Grid)
  bool _isGridView = true;

  late Future<List<Invitation>> _invitationsFuture;

  @override
  void initState() {
    super.initState();
    _loadData(); // Tải dữ liệu lần đầu
  }

  void _loadData() {
    setState(() {
      _invitationsFuture = _fetchInvitations();
    });
  }

  Future<List<Invitation>> _fetchInvitations() async {
    final response = await Supabase.instance.client
        .from('invitations')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Invitation.fromJson(json)).toList();
  }

  void _copyPublicLink(String id) {
    // Tự động lấy tên miền hiện tại (localhost lúc dev, sachi.vn lúc release)
    final baseUrl = Uri.base.origin;

    // Lưu ý: Nếu app Flutter Web của bạn đang dùng Hash Route (có dấu #)
    // thì link sẽ là: $baseUrl/#/i/$id. Còn nếu dùng Path Route thì là $baseUrl/i/$id
    // Mặc định GoRouter bản mới thường là Path Route.
    final link = '$baseUrl/i/$id';

    // Lưu vào bộ nhớ tạm của máy tính/điện thoại
    Clipboard.setData(ClipboardData(text: link));

    SmartDialog.showToast('Đã sao chép link gửi khách! 💌');
  }

  // ---> HÀM XỬ LÝ XÓA THIỆP <---
  Future<void> _deleteInvitation(String id, String bride, String groom) async {
    // 1. Hiện hộp thoại hỏi lại cho chắc chắn
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa thiệp cưới của\n"$bride & $groom" không?\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Bấm Hủy
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true), // Bấm Xóa
            child: const Text(
              'Xóa vĩnh viễn',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // 2. Nếu người dùng chọn "Xóa vĩnh viễn"
    if (confirm == true) {
      SmartDialog.showLoading(msg: 'Đang xóa thiệp...');
      try {
        // Gọi Supabase xóa record theo ID
        await Supabase.instance.client
            .from('invitations')
            .delete()
            .eq('id', id);

        SmartDialog.dismiss();
        SmartDialog.showToast('Đã xóa thiệp thành công! 🗑️');

        // 3. Gọi lại hàm load dữ liệu để làm mới danh sách
        _loadData();
      } catch (e) {
        SmartDialog.dismiss();
        SmartDialog.showToast('Có lỗi xảy ra: $e');
      }
    }
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
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isGridView
                ? 'Chuyển sang dạng Bảng'
                : 'Chuyển sang dạng Lưới',
            icon: Icon(
              _isGridView
                  ? Icons.table_chart_outlined
                  : Icons.grid_view_outlined,
              color: AppTheme.deepPink,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              // ---> THAY ĐỔI Ở ĐÂY <---
              onPressed: () async {
                await context.push('/invitations/create');
                _loadData();
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tạo thiệp mới'),
            ),
          ),
        ],
      ),

      // Hiển thị giao diện tương ứng dựa trên biến _isGridView
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Invitation>>(
          future: _invitationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null || data.isEmpty) {
              return Center(
                child: Text(
                  'Chưa có thiệp cưới nào. Hãy tạo cái đầu tiên nhé!',
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isGridView ? _buildGridView(data) : _buildTableView(data),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // GIAO DIỆN DẠNG LƯỚI (GRID CARDS)
  // ==========================================
  Widget _buildGridView(List<Invitation> data) {
    return GridView.builder(
      key: const ValueKey(
        'gridView',
      ), // Cần có key để AnimatedSwitcher nhận diện
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildInvitationCard(data[index]);
      },
    );
  }

  // ==========================================
  // GIAO DIỆN DẠNG BẢNG (DATA TABLE)
  // ==========================================
  Widget _buildTableView(List<Invitation> data) {
    return Container(
      key: const ValueKey('tableView'), // Cần có key
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryPink.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Bọc trong SingleChildScrollView để có thể cuộn ngang nếu màn hình quá hẹp
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => AppTheme.secondaryPink.withOpacity(0.15),
          ),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 70,
          horizontalMargin: 24,
          columnSpacing: 48,
          columns: const [
            DataColumn(
              label: Text(
                'Cô dâu & Chú rể',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepPink,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Ngày cưới',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Trạng thái',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Thao tác',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
            ),
          ],
          rows: data.map((invitation) {
            final statusConfig = _getStatusConfig(invitation.status);

            return DataRow(
              cells: [
                // Cột Tên + Hình ảnh thu nhỏ
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(invitation.coverUrl),
                        backgroundColor: AppTheme.secondaryPink.withOpacity(
                          0.3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${invitation.brideName} & ${invitation.groomName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
                // Cột Ngày cưới
                DataCell(
                  Text(DateFormat('dd/MM/yyyy').format(invitation.eventDate)),
                ),
                // Cột Trạng thái (Dùng Chip bo tròn)
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusConfig.text,
                      style: TextStyle(
                        color: statusConfig.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Cột Nút thao tác
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ---> NÚT SAO CHÉP MỚI THÊM VÀO <---
                      IconButton(
                        tooltip: 'Sao chép link gửi khách',
                        icon: const Icon(
                          Icons.copy_outlined,
                          color: AppTheme.primaryPink,
                        ),
                        onPressed: () => _copyPublicLink(invitation.id),
                      ),
                      IconButton(
                        tooltip: 'Xem trước',
                        icon: const Icon(
                          Icons.remove_red_eye_outlined,
                          color: AppTheme.textLight,
                          size: 20,
                        ),
                        onPressed: () {
                          context.push(
                            '/invitations/preview',
                            extra: invitation,
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Chỉnh sửa',
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppTheme.primaryPink,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        tooltip: 'Cài đặt',
                        icon: const Icon(
                          Icons.share_outlined,
                          color: AppTheme.deepPink,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // HÀM HỖ TRỢ (WIDGETS & LOGIC)
  // ==========================================
  Widget _buildInvitationCard(Invitation invitation) {
    final statusConfig = _getStatusConfig(invitation.status);

    return Card(
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppTheme.secondaryPink.withOpacity(0.3),
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusConfig.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                    color: AppTheme.deepPink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(invitation.eventDate),
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.secondaryPink.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: 'Chỉnh sửa',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.textMain,
                  ),
                  onPressed: () async {
                    // Chuyển sang màn Editor và ném data cũ vào
                    await context.push(
                      '/invitations/create',
                      extra: invitation,
                    );

                    // Khi Editor đóng lại, load lại danh sách để cập nhật thay đổi
                    _loadData();
                  },
                ),

                // Nút Xem trước và Copy link (giữ nguyên code cũ của bạn)
                IconButton(
                  tooltip: 'Xem trước',
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: AppTheme.textMain,
                  ),
                  onPressed: () =>
                      context.push('/invitations/preview', extra: invitation),
                ),

                IconButton(
                  tooltip: 'Sao chép link',
                  icon: const Icon(
                    Icons.copy_outlined,
                    color: AppTheme.primaryPink,
                  ),
                  onPressed: () => _copyPublicLink(invitation.id),
                ),

                // ---> NÚT XÓA <---
                IconButton(
                  tooltip: 'Xóa thiệp',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _deleteInvitation(
                    invitation.id,
                    invitation.brideName,
                    invitation.groomName,
                  ),
                ),
                IconButton(
                  tooltip: 'Cài đặt RSVP & Share',
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppTheme.deepPink,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tách logic lấy màu và text của trạng thái ra một hàm riêng để tái sử dụng
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

// Class nhỏ hỗ trợ trả về màu và chữ
class _StatusConfig {
  final Color color;
  final String text;
  _StatusConfig(this.color, this.text);
}
