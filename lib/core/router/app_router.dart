import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wedding_admin_panel/features/invitations/models/invitation.dart';
import 'package:wedding_admin_panel/features/invitations/views/guest_invitation_screen.dart';
import 'package:wedding_admin_panel/features/invitations/views/guest_management_screen.dart';
import 'package:wedding_admin_panel/features/invitations/views/invitation_editor_screen.dart';
import 'package:wedding_admin_panel/features/invitations/views/invitation_preview_screen.dart';

import '../../features/auth/views/login_screen.dart';
import '../../features/dashboard/views/dashboard_screen.dart';
import '../../features/invitations/views/invitation_list_screen.dart';
import '../../shared/layouts/main_layout.dart';
import '../../features/invitations/views/host_auth_screen.dart';

// Khóa Global để Router quản lý ngữ cảnh
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',

  // ---> CHÌA KHÓA Ở ĐÂY: Lắng nghe sự thay đổi trạng thái đăng nhập từ Supabase
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),

  // Guard bảo vệ route: Kiểm tra trạng thái đăng nhập
  redirect: (context, state) {
    final isPublicLink = state.uri.path.startsWith('/i/');
    if (isPublicLink) {
      return null; // Mở barie, cho qua luôn không cần hỏi thẻ!
    }

    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isGoingToLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isGoingToLogin) {
      return '/login'; // Chưa đăng nhập -> Đá về Login
    }
    if (isLoggedIn && isGoingToLogin) {
      return '/dashboard'; // Đã đăng nhập nhưng vào Login -> Đá vào Dashboard
    }
    return null; // Hợp lệ, cho phép đi tiếp
  },

  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/g/:code',
      builder: (context, state) {
        final guestCode = state.pathParameters['code']!;
        return GuestInvitationScreen(
          guestCode: guestCode,
        ); // Truyền mã khách vào
      },
    ),
    GoRoute(
      path: '/i/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GuestInvitationScreen(invitationId: id);
      },
    ),
    GoRoute(
      path: '/i/:id', // Đường dẫn ngắn gọn để gửi cho khách
      builder: (context, state) {
        // Lấy ID từ tham số đường dẫn URL
        final invitationId = state.pathParameters['id']!;
        return GuestInvitationScreen(invitationId: invitationId);
      },
    ),
    GoRoute(
      path: '/invitations/guests',
      builder: (context, state) {
        // Lấy object invitation được truyền sang
        final invitation = state.extra as Invitation;
        return GuestManagementScreen(invitation: invitation);
      },
    ),
    // Route dành cho Dâu/Rể nhập mã PIN
    GoRoute(
      path: '/host/:token',
      builder: (context, state) {
        final token = state.pathParameters['token']!;
        return HostAuthScreen(token: token);
      },
    ),
    // StatefulShellRoute giúp giữ nguyên trạng thái của từng tab khi chuyển qua lại
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        // Nhánh 1: Tổng quan
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/invitations',
              builder: (context, state) => const InvitationListScreen(),
              // ---> BỔ SUNG ROUTE CON Ở ĐÂY <---
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) {
                    // Lấy dữ liệu thiệp cũ được truyền sang (nếu có)
                    final existingInvitation = state.extra as Invitation?;
                    return InvitationEditorScreen(
                      existingInvitation: existingInvitation,
                    );
                  },
                ),
                GoRoute(
                  path: 'preview',
                  builder: (context, state) {
                    // Lấy object Invitation được truyền qua extra
                    final invitation = state.extra as Invitation;
                    return InvitationPreviewScreen(invitation: invitation);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// =========================================================================
// HELPER CLASS: Chuyển đổi Stream của Supabase thành ChangeNotifier cho GoRouter
// =========================================================================
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
