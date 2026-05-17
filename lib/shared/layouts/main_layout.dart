import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  void _onItemTapped(int index) {
    // Điều hướng tới nhánh (tab) tương ứng.
    navigationShell.goBranch(
      index,
      // Nếu bấm lại vào tab đang mở, sẽ đưa tab đó về màn hình gốc
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Thanh Menu bên trái
          NavigationRail(
            backgroundColor: AppTheme.backgroundCream,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onItemTapped,
            extended:
                true, // true để hiện cả icon lẫn text (có thể kết nối với biến để thu gọn/mở rộng)
            indicatorColor: AppTheme.secondaryPink.withOpacity(0.4),

            selectedIconTheme: const IconThemeData(
              color: AppTheme.deepPink,
              size: 28,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppTheme.textLight,
              size: 24,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppTheme.deepPink,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppTheme.textLight,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Tổng quan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.mark_email_read_outlined),
                selectedIcon: Icon(Icons.mark_email_read),
                label: Text('Thiệp cưới'),
              ),
            ],
          ),

          // Đường kẻ dọc mỏng ngăn cách
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: AppTheme.secondaryPink.withOpacity(0.3),
          ),

          // Phần nội dung thay đổi bên phải
          Expanded(
            child: Container(
              color: AppTheme.backgroundCream,
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}
