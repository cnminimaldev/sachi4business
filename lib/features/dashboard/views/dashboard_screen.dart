import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../../auth/blocs/auth_event.dart';
import '../../auth/blocs/auth_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,

      // Thanh AppBar phía trên cùng
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0, // Xóa đổ bóng mặc định để nhìn hiện đại hơn
        title: const Text(
          'Tổng quan',
          style: TextStyle(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Nút Đăng xuất
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout_rounded, color: AppTheme.deepPink),
            onPressed: () {
              // Bắn sự kiện yêu cầu đăng xuất vào BLoC
              context.read<AuthBloc>().add(LogOutRequested());
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      // Phần nội dung chính (body)
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Hiện loading mờ khi đang xử lý đăng xuất
          if (state is AuthLoading) {
            SmartDialog.showLoading(msg: 'Đang đăng xuất...');
          } else {
            SmartDialog.dismiss();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon trang trí phong cách Kawaii
              const Icon(
                Icons.auto_awesome,
                size: 80,
                color: AppTheme.primaryPink,
              ),
              const SizedBox(height: 24),
              Text(
                'Chào mừng bạn đến với Admin Dashboard! 🌸',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.deepPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nơi quản lý thiệp cưới và theo dõi doanh thu siêu dễ thương.',
                style: TextStyle(color: AppTheme.textLight, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
