import 'package:flutter/material.dart';
import '../../widgets/costum_header.dart';

class LiveCameraPage extends StatefulWidget {
  const LiveCameraPage({super.key});

  @override
  State<LiveCameraPage> createState() => _LiveCameraPageState();
}

class _LiveCameraPageState extends State<LiveCameraPage> {
  final List<Map<String, String>> detectionLogs = [
    {"time": "10:32", "type": "Gerakan Terdeteksi"},
    {"time": "10:30", "type": "Orang Lewat"},
    {"time": "10:28", "type": "Gerakan Terdeteksi"},
  ];

  // Contoh status sensor gerak (ganti dengan data realtime nantinya)
  bool isMotionSensorActive = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5F59A6);

    return Scaffold(
      appBar: const CustomAppBar(title: 'AntiSpy Cam'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // MJPEG stream
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 200,
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Text(
                'Live Stream ESP32-CAM',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status sensor gerak
          _SensorStatusCard(
            icon: Icons.motion_photos_on,
            label: 'Sensor Gerak',
            value: isMotionSensorActive ? "Mencurigakan" : "Aktivitas Normal",
            active: isMotionSensorActive,
          ),

          const SizedBox(height: 24),
          const Text(
            'Riwayat Deteksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          ...detectionLogs.map((log) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: primaryColor),
                title: Text(log['type'] ?? '-'),
                subtitle: Text("Waktu: ${log['time']}"),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SensorStatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool active;

  const _SensorStatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5F59A6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 36,
            color: primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}
