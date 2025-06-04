import 'package:flutter/material.dart';

// Halaman tanpa bottom nav
import '../screens/splash_screen.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';

// Halaman dengan bottom nav (dibungkus MainScreen)
import '../screens/main_screen.dart';

import '../screens/history/history_page.dart';
import '../screens/settings/settings_page.dart';
import '../screens/notifications/notifications_page.dart';
import '../screens/live_stream/live_camera_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),

    // Pembungkus Bottom Navigation
    '/main': (context) => const MainScreen(),

    // Rute internal (dipakai oleh MainScreen untuk switch halaman)
    '/history': (context) => const HistoryPage(),
    '/control': (context) => const SettingsPage(),
    '/notifications': (context) => const NotificationsPage(),
    '/camera': (context) => const LiveCameraPage(),
  };
}
