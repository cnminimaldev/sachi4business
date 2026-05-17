import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'features/auth/blocs/auth_bloc.dart';
import 'features/auth/blocs/auth_event.dart';

void main() async {
  // Đảm bảo Flutter bindings đã khởi tạo trước khi gọi các async functions
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Supabase.initialize(
    url: 'https://zskxssvkhluqayppgwyd.supabase.co',
    anonKey: 'sb_publishable_INqkQyUchgiZdW614qfWAw_MEwMRiSr',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc()..add(AppStarted()), // Khởi chạy kiểm tra session ngay
        ),
      ],
      child: MaterialApp.router(
        // Sau khi cấu hình GoRouter, ta sẽ đổi thành MaterialApp.router
        title: 'Hệ thống Quản lý Thiệp cưới',
        debugShowCheckedModeBanner: false,
        // Kích hoạt giao diện phấn hường ở đây!
        theme: AppTheme.lightTheme,
        // Tích hợp SmartDialog vào hệ thống
        builder: FlutterSmartDialog.init(),

        // Tạm thời hiển thị màn hình trống chờ làm Layout và Router
        routerConfig: appRouter,
      ),
    );
  }
}
