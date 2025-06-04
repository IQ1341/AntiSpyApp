import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/costum_header.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Stream<QuerySnapshot> getNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Icon _getIcon(String type) {
    switch (type) {
      case 'gerak':
        return const Icon(Icons.directions_run, color: Colors.redAccent);
      case 'jarak':
        return const Icon(Icons.sensors, color: Colors.orange);
      case 'kamera':
        return const Icon(Icons.camera_alt, color: Colors.blueAccent);
      default:
        return const Icon(Icons.notification_important, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    // const primaryColor = Color(0xFF5F59A6);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifikasi'),
      body: StreamBuilder<QuerySnapshot>(
        stream: getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi."));
          }

          final items = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index].data() as Map<String, dynamic>;
              final type = data['type'] ?? 'lainnya';
              final message = data['message'] ?? 'Tidak ada pesan';
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final timeText =
                  DateFormat('dd MMM yyyy • HH:mm').format(timestamp);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: ListTile(
                  leading: _getIcon(type),
                  title: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(timeText),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
