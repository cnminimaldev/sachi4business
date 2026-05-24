import 'package:flutter/material.dart';

// Giả định cấu trúc State của Dashboard (bạn có thể map trực tiếp với DashboardBloc sau này)
class DashboardSummaryData {
  final int totalActiveInvitations;
  final int weddingsThisWeek;
  final int pendingAlerts;
  final List<RecentRsvpModel> recentRsvps;

  DashboardSummaryData({
    required this.totalActiveInvitations,
    required this.weddingsThisWeek,
    required this.pendingAlerts,
    required this.recentRsvps,
  });
}

class RecentRsvpModel {
  final String guestName;
  final String weddingName;
  final String status; // 'attending', 'declined', 'uncertain'
  final String timeAgo;

  RecentRsvpModel({
    required this.guestName,
    required this.weddingName,
    required this.status,
    required this.timeAgo,
  });
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mô phỏng ban đầu để dựng giao diện tĩnh
    final mockData = DashboardSummaryData(
      totalActiveInvitations: 24,
      weddingsThisWeek: 5,
      pendingAlerts: 3,
      recentRsvps: [
        RecentRsvpModel(
          guestName: 'Nguyễn Văn Minh',
          weddingName: 'Minh Thư & Hoàng Nam',
          status: 'attending',
          timeAgo: '2 phút trước',
        ),
        RecentRsvpModel(
          guestName: 'Trần Thị Thủy',
          weddingName: 'Khánh Linh & Đức Anh',
          status: 'declined',
          timeAgo: '15 phút trước',
        ),
        RecentRsvpModel(
          guestName: 'Lê Hoàng Long',
          weddingName: 'Minh Thư & Hoàng Nam',
          status: 'uncertain',
          timeAgo: '1 giờ trước',
        ),
        RecentRsvpModel(
          guestName: 'Phạm Hồng Nhung',
          weddingName: 'Thùy Dung & Quốc Bảo',
          status: 'attending',
          timeAgo: '3 giờ trước',
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFFDFBF7,
      ), // Màu nền kem nhạt tối giản kiểu Nhật
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildMetricGrid(mockData),
              const SizedBox(height: 40),
              _buildRecentRsvpSection(mockData),
            ],
          ),
        ),
      ),
    );
  }

  // Tiêu đề chào mừng và ngày tháng hiện tại
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào buổi sáng, Quản trị viên',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dưới đây là tình hình hoạt động của Sachi hôm nay.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Lưới hiển thị các thẻ chỉ số (Metrics) với tông màu pastel mềm mại
  Widget _buildMetricGrid(DashboardSummaryData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tự động điều chỉnh số cột dựa trên độ rộng màn hình (Responsive nhẹ cho Web/Tablet Admin)
        int crossAxisCount = constraints.maxWidth > 800
            ? 3
            : (constraints.maxWidth > 550 ? 2 : 1);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard(
              title: 'Thiệp đang chạy',
              value: '${data.totalActiveInvitations}',
              subtitle: 'Hệ thống đang tải ổn định',
              backgroundColor: const Color(0xFFEAF2F8), // Xanh pastel nhạt
              icon: Icons.insert_drive_file_outlined,
              iconColor: const Color(0xFF4A90E2),
            ),
            _buildStatCard(
              title: 'Đám cưới trong tuần',
              value: '${data.weddingsThisWeek}',
              subtitle: 'Cần lưu ý hỗ trợ Dâu/Rể',
              backgroundColor: const Color(0xFFFCEFEF), // Hồng/Đỏ pastel nhạt
              icon: Icons.favorite_border_rounded,
              iconColor: const Color(0xFFE26D6D),
            ),
            _buildStatCard(
              title: 'Cập nhật RSVP mới',
              value: '${data.recentRsvps.length}',
              subtitle: 'Lượt phản hồi từ khách mời',
              backgroundColor: const Color(
                0xFFEFEFE9,
              ), // Xanh rêu/Beige pastel nhạt
              icon: Icons.how_to_reg_outlined,
              iconColor: const Color(0xFF7A8266),
            ),
          ],
        );
      },
    );
  }

  // Widget Thẻ chỉ số chi tiết
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          20,
        ), // Bo góc sâu tạo cảm giác mềm mại
        border: Border.all(color: Colors.black.withOpacity(0.03), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }

  // Khu vực hiển thị luồng RSVP mới nhất
  Widget _buildRecentRsvpSection(DashboardSummaryData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cập nhật RSVP mới nhất',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            TextButton(
              onPressed: () {
                // Điều hướng sang màn hình quản lý khách mời đầy đủ
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Xem tất cả', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.recentRsvps.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey.withOpacity(0.1), height: 1),
            itemBuilder: (context, index) {
              final item = data.recentRsvps[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: Text(
                    item.guestName.isNotEmpty ? item.guestName[0] : 'G',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      item.guestName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(item.status),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Đám cưới: ${item.weddingName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                trailing: Text(
                  item.timeAgo,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Nhãn trạng thái phản hồi của khách
  Widget _buildStatusChip(String status) {
    Color labelColor;
    Color bgColor;
    String text;

    switch (status) {
      case 'attending':
        text = 'Tham dự';
        labelColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'declined':
        text = 'Không đi';
        labelColor = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        break;
      default:
        text = 'Chưa rõ';
        labelColor = const Color(0xFFEF6C00);
        bgColor = const Color(0xFFFFF3E0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: labelColor,
        ),
      ),
    );
  }
}
