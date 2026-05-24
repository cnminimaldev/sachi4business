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
  final String status;
  final DateTime updatedAt;

  RecentRsvpModel({
    required this.guestName,
    required this.weddingName,
    required this.status,
    required this.updatedAt,
  });

  // Hàm tiện ích để hiển thị thời gian (ví dụ: "2 phút trước")
  String get timeAgo {
    final difference = DateTime.now().difference(updatedAt);
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    return '${difference.inDays} ngày trước';
  }
}
