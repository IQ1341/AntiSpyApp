import 'package:antispy/screens/history/history_page.dart';
import 'package:antispy/screens/live_stream/live_camera_page.dart';
import 'package:antispy/screens/settings/settings_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // camera FAB default di tengah

  final List<Widget> _screens = const [
    HistoryPage(),
    LiveCameraPage(),
    SettingsPage(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _onMiddleTap() {
    _onTap(1); // live camera
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onMiddleTap,
        backgroundColor: const Color(0xFF5F59A6),
        elevation: 8,
        shape: const CircleBorder(),
        child: Icon(
          _currentIndex == 1 ? Icons.camera_alt : Icons.camera_alt_outlined,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 10,
        color: const Color(0xFF5F59A6), // UNGU gelap
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.history_outlined,
                Icons.history,
                "History",
                0,
              ), // Spacer tengah untuk FAB
              const SizedBox(width: 48),
              
              _buildNavItem(
                Icons.settings_outlined,
                Icons.settings,
                "Settings",
                2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? Colors.white : Colors.white60,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
