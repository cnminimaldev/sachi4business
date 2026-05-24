import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../blocs/host_auth/host_auth_bloc.dart';
import '../blocs/host_auth/host_auth_event.dart';
import '../blocs/host_auth/host_auth_state.dart';

class HostAuthScreen extends StatefulWidget {
  final String token;

  const HostAuthScreen({super.key, required this.token});

  @override
  State<HostAuthScreen> createState() => _HostAuthScreenState();
}

class _HostAuthScreenState extends State<HostAuthScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submitPin(BuildContext context) {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      SmartDialog.showToast('Vui lòng nhập đủ mã PIN 4 số');
      return;
    }
    // Gắn Event đẩy vào BLoC thay vì viết logic API ở đây
    context.read<HostAuthBloc>().add(
      VerifyPinRequested(token: widget.token, pin: pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HostAuthBloc(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundCream,
        // Dùng BlocConsumer để vừa lắng nghe state (hiện Toast/Chuyển trang) vừa vẽ UI
        body: BlocConsumer<HostAuthBloc, HostAuthState>(
          listener: (context, state) {
            if (state is HostAuthLoading) {
              SmartDialog.showLoading(msg: 'Đang xác thực...');
            } else {
              SmartDialog.dismiss(); // Tắt loading khi có kết quả
            }

            if (state is HostAuthSuccess) {
              SmartDialog.showToast('Xác thực thành công! 🌸');
              context.pushReplacement(
                '/invitations/guests',
                extra: state.invitation,
              );
            } else if (state is HostAuthFailure) {
              SmartDialog.showToast(state.message);
              _pinController.clear();
            } else if (state is HostAuthLocked) {
              final remainingMinutes =
                  state.lockoutUntil.difference(DateTime.now()).inMinutes + 1;
              SmartDialog.showToast(
                '⏳ ${state.message} (Thử lại sau $remainingMinutes phút)',
              );
              _pinController.clear();
            }
          },
          builder: (context, state) {
            final isLocked =
                state is HostAuthLocked &&
                state.lockoutUntil.isAfter(DateTime.now());

            return Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 400,
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
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        enabled:
                            !isLocked, // Khóa ô nhập nếu đang trong trạng thái Locked
                        style: const TextStyle(
                          fontSize: 32,
                          letterSpacing: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepPink,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: isLocked ? Colors.grey[200] : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
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
                            isLocked ? null : _submitPin(context),
                      ),
                      const SizedBox(height: 32),

                      // Nút Xác nhận
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLocked
                              ? Colors.grey
                              : AppTheme.deepPink,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isLocked ? null : () => _submitPin(context),
                        child: Text(
                          isLocked ? 'Đang tạm khóa' : 'Xác nhận truy cập',
                          style: const TextStyle(
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
            );
          },
        ),
      ),
    );
  }
}
