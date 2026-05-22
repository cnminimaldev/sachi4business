import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';

class HostAuthScreen extends StatefulWidget {
  final String token;

  const HostAuthScreen({super.key, required this.token});

  @override
  State<HostAuthScreen> createState() => _HostAuthScreenState();
}

class _HostAuthScreenState extends State<HostAuthScreen> {
  final TextEditingController _pinController = TextEditingController();

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      SmartDialog.showToast('Vui lòng nhập đủ mã PIN 4 số');
      return;
    }

    SmartDialog.showLoading(msg: 'Đang xác thực...');
    try {
      // 1. Tải thông tin thiệp để kiểm tra trạng thái khóa trước
      final inviteData = await Supabase.instance.client
          .from('invitations')
          .select()
          .eq('manage_token', widget.token)
          .maybeSingle();

      if (inviteData == null) {
        SmartDialog.dismiss();
        SmartDialog.showToast('Đường dẫn quản lý không hợp lệ');
        return;
      }

      // 2. KIỂM TRA XEM CÓ ĐANG BỊ KHÓA KHÔNG
      if (inviteData['lockout_until'] != null) {
        final lockoutUntil = DateTime.parse(inviteData['lockout_until']);
        final now = DateTime.now().toUtc(); // Supabase lưu thời gian dạng UTC

        if (lockoutUntil.isAfter(now)) {
          final remainingMinutes = lockoutUntil.difference(now).inMinutes + 1;
          SmartDialog.dismiss();
          SmartDialog.showToast(
            'Tài khoản tạm khóa do nhập sai nhiều lần. Thử lại sau $remainingMinutes phút ⏳',
          );
          _pinController.clear();
          return;
        }
      }

      // 3. KIỂM TRA MÃ PIN
      final bool isPinCorrect = inviteData['manage_pin'] == pin;

      if (isPinCorrect) {
        // Tình huống: ĐÚNG MÃ PIN -> Reset bộ đếm sai về 0 và xóa mốc khóa
        await Supabase.instance.client
            .from('invitations')
            .update({'failed_attempts': 0, 'lockout_until': null})
            .eq('manage_token', widget.token);

        SmartDialog.dismiss();
        SmartDialog.showToast('Xác thực thành công! 🌸');

        if (!mounted) return;
        final invitation = Invitation.fromJson(inviteData);
        context.pushReplacement('/invitations/guests', extra: invitation);
      } else {
        // Tình huống: SAI MÃ PIN -> Tăng bộ đếm
        int currentFailed = (inviteData['failed_attempts'] ?? 0) + 1;
        Map<String, dynamic> updatePayload = {'failed_attempts': currentFailed};

        // Nếu sai từ 5 lần trở lên -> Kích hoạt khóa 15 phút
        if (currentFailed >= 5) {
          final lockoutTime = DateTime.now()
              .add(const Duration(minutes: 15))
              .toUtc();
          updatePayload['lockout_until'] = lockoutTime.toIso8601String();
          SmartDialog.dismiss();
          SmartDialog.showToast(
            'Nhập sai quá 5 lần. Thiết bị bị tạm khóa 15 phút!',
          );
        } else {
          final remainingAttempts = 5 - currentFailed;
          SmartDialog.dismiss();
          SmartDialog.showToast(
            'Mã PIN không chính xác. Bạn còn $remainingAttempts lần thử!',
          );
        }

        // Cập nhật số lần sai lên database
        await Supabase.instance.client
            .from('invitations')
            .update(updatePayload)
            .eq('manage_token', widget.token);

        _pinController.clear();
      }
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('Lỗi hệ thống: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400, // Cố định chiều rộng tối đa cho đẹp trên Web Desktop
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: AppTheme.primaryPink,
                ),
                const SizedBox(height: 24),
                const Text(
                  'QUẢN LÝ KHÁCH MỜI',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepPink,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vui lòng nhập mã PIN bảo mật do Sachi cung cấp để truy cập vào danh sách khách mời của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 40),

                // Ô nhập mã PIN
                TextField(
                  controller: _pinController,
                  obscureText: true, // Ẩn mã PIN dưới dạng dấu chấm
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 32,
                    letterSpacing: 16, // Tạo khoảng cách rộng giữa các số
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepPink,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '', // Ẩn bộ đếm 0/4
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.primaryPink.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryPink,
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (_) =>
                      _verifyPin(), // Nhấn Enter trên bàn phím để submit
                ),
                const SizedBox(height: 32),

                // Nút Xác nhận
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepPink,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _verifyPin,
                  child: const Text(
                    'Xác nhận truy cập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
