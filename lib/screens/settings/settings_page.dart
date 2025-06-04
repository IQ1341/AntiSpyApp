import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../widgets/costum_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('control');

  bool _isDeviceOn = false;
  String _mode = 'otomatis';

  @override
  void initState() {
    super.initState();
    _listenToStatus();
  }

  void _listenToStatus() {
    _dbRef.child('status').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is bool) {
        setState(() {
          _isDeviceOn = value;
        });
      }
    });

    _dbRef.child('mode').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is String) {
        setState(() {
          _mode = value;
        });
      }
    });
  }

  void _toggleDevice(bool value) {
    _dbRef.child('status').set(value);
  }

  void _changeMode(String newMode) {
    _dbRef.child('mode').set(newMode);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5F59A6);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Pengaturan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const Icon(Icons.settings, size: 64, color: primaryColor),
                const SizedBox(height: 10),
                Text(
                  'Pengaturan Perangkat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildControlCard(
              icon: Icons.power_settings_new,
              title: 'Status Perangkat',
              subtitle: _isDeviceOn ? 'AKTIF' : 'NONAKTIF',
              trailing: Switch(
                value: _isDeviceOn,
                onChanged: _toggleDevice,
                activeColor: primaryColor,
              ),
              iconColor: _isDeviceOn ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            _buildControlCard(
              icon: Icons.settings_remote,
              title: 'Mode',
              subtitle: _mode.toUpperCase(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChoiceChip(
                    label: const Text('Otomatis'),
                    selected: _mode == 'otomatis',
                    onSelected: (selected) {
                      if (selected) _changeMode('otomatis');
                    },
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: _mode == 'otomatis' ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Manual'),
                    selected: _mode == 'manual',
                    onSelected: (selected) {
                      if (selected) _changeMode('manual');
                    },
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: _mode == 'manual' ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              iconColor: primaryColor,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
