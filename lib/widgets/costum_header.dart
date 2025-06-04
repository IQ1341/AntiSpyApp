import 'package:flutter/material.dart';
import '../screens/notifications/notifications_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF5F59A6), // ungu gelap
      elevation: 4,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
  IconButton(
    icon: const Icon(Icons.notifications, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationsPage(),
        ),
      );
    },
  ),
],

    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
