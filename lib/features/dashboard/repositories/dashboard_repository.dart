import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  final SupabaseClient _supabase;

  DashboardRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<DashboardSummaryData> getDashboardSummary() async {
    // Lưu ý: Các query dưới đây là cấu trúc giả định dựa trên bảng của dự án

    // 1. Đếm tổng số thiệp đang hoạt động
    final activeCountRes = await _supabase
        .from('invitations')
        .select('id')
        .eq('status', 'active')
        .count(CountOption.exact);

    // 2. Đếm số đám cưới trong tuần tới (từ hôm nay đến +7 ngày)
    final today = DateTime.now().toIso8601String();
    final nextWeek = DateTime.now()
        .add(const Duration(days: 7))
        .toIso8601String();
    final weeklyWeddingsRes = await _supabase
        .from('invitations')
        .select('id')
        .gte('wedding_date', today)
        .lte('wedding_date', nextWeek)
        .count(CountOption.exact);

    // 3. Lấy 5 RSVP mới nhất (Join bảng guests với bảng invitations để lấy tên đám cưới)
    final rsvpRes = await _supabase
        .from('guests')
        .select('''
          name,
          rsvp_status,
          updated_at,
          invitations ( title )
        ''')
        .order('updated_at', ascending: false)
        .limit(5);

    final recentRsvps = (rsvpRes as List).map((row) {
      return RecentRsvpModel(
        guestName: row['name'] as String,
        weddingName: row['invitations']['title'] as String, // Tên Dâu/Rể
        status: row['rsvp_status'] as String,
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
    }).toList();

    return DashboardSummaryData(
      totalActiveInvitations: activeCountRes.count ?? 0,
      weddingsThisWeek: weeklyWeddingsRes.count ?? 0,
      pendingAlerts: 0, // Tính năng mở rộng sau
      recentRsvps: recentRsvps,
    );
  }
}
