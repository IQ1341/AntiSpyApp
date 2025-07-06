import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../widgets/costum_header.dart';

class LiveCameraPage extends StatefulWidget {
  const LiveCameraPage({super.key});

  @override
  State<LiveCameraPage> createState() => _LiveCameraPageState();
}

class _LiveCameraPageState extends State<LiveCameraPage> {
  String? _ipAddress;
  bool _isStreamLoading = true;
  bool _hasStreamError = false;
  bool _isMotionSensorActive = false;
  bool _hasCapturedRecently = false;
  bool _isCapturingManually = false;

  @override
  void initState() {
    super.initState();
    _fetchIpAddress();
    _listenToMotionSensor();
  }

  void _listenToMotionSensor() {
    final statusRef = FirebaseDatabase.instance.ref('sensorPIR/status');

    statusRef.onValue.listen((event) async {
      final status = event.snapshot.value;

      print("📥 Status PIR: $status");

      if (status == 1 || status == '1' || status == true) {
        setState(() => _isMotionSensorActive = true);

        if (!_hasCapturedRecently && _ipAddress != null) {
          print("📸 Mulai capture otomatis...");
          _hasCapturedRecently = true;
          await _captureAndUploadImage();

          Future.delayed(const Duration(seconds: 10), () {
            _hasCapturedRecently = false;
            print("🔁 Reset capture flag.");
          });
        } else {
          print("⚠️ Sudah capture, tunggu delay.");
        }
      } else {
        setState(() => _isMotionSensorActive = false);
      }
    });
  }

  Future<void> _fetchIpAddress() async {
    final ref = FirebaseDatabase.instance.ref('esp32cam/ip');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      setState(() {
        _ipAddress = snapshot.value.toString();
      });
      print("📡 IP ESP32 ditemukan: $_ipAddress");
    } else {
      setState(() => _ipAddress = null);
      print("❌ IP ESP32 tidak ditemukan.");
    }
  }

  Future<void> _captureAndUploadImage() async {
    if (_ipAddress == null) return;

    final captureUrl = 'http://$_ipAddress/capture';
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dd2elgipw/image/upload';
    const uploadPreset = 'cam_upload';

    try {
      print("📷 Mengambil gambar dari $_ipAddress...");

      // Coba capture maksimal 2 kali
      http.Response? response;
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          response = await http
              .get(Uri.parse(captureUrl))
              .timeout(const Duration(seconds: 10));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            print("✅ Capture berhasil pada attempt ke-$attempt");
            break;
          } else {
            print("⚠️ Capture gagal (status: ${response.statusCode}), mencoba ulang...");
          }
        } catch (e) {
          print("⚠️ Error saat capture ke-$attempt: $e");
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (response == null || response.bodyBytes.isEmpty) {
        throw Exception('Gambar kosong atau tidak valid');
      }

      // Upload ke Cloudinary
      final uploadRequest = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      uploadRequest.fields['upload_preset'] = uploadPreset;
      uploadRequest.files.add(
        http.MultipartFile.fromBytes('file', response.bodyBytes, filename: 'snapshot.jpg'),
      );

      print("☁️ Upload ke Cloudinary...");
      final uploadResponse = await uploadRequest.send();
      final result = await http.Response.fromStream(uploadResponse);

      if (uploadResponse.statusCode != 200) throw Exception('Upload gagal');

      final data = jsonDecode(result.body);
      final imageUrl = data['secure_url'];

      // Simpan gambar dan log ke Firestore
      await FirebaseFirestore.instance.collection('captures').add({
        'imageUrl': imageUrl,
        'timestamp': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('History').add({
        'motion': 'Mencurigakan',
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Gambar berhasil diunggah')),
        );
      }
    } catch (e) {
      print("❌ Error saat capture: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Terjadi kesalahan saat capture: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5F59A6);

    return Scaffold(
      appBar: const CustomAppBar(title: 'AntiSpy Cam'),
      body: _ipAddress == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStreamSection(primaryColor),
                const SizedBox(height: 20),
                _buildMotionSensorSection(primaryColor),
                _buildDetectionHistorySection(primaryColor),
              ],
            ),
    );
  }

  Widget _buildStreamSection(Color primaryColor) {
    final streamUrl = 'http://$_ipAddress/stream';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Live Camera Feed',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            color: Colors.black,
            child: Stack(
              children: [
                Mjpeg(
                  stream: streamUrl,
                  isLive: true,
                  fit: BoxFit.cover,
                  loading: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_isStreamLoading) {
                        setState(() => _isStreamLoading = false);
                      }
                    });
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  error: (context, error, stack) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_hasStreamError) {
                        setState(() {
                          _hasStreamError = true;
                          _isStreamLoading = false;
                        });
                      }
                    });
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text('Gagal memuat stream', style: TextStyle(color: Colors.red[300])),
                          Text('Periksa koneksi kamera', style: TextStyle(color: Colors.red[300])),
                        ],
                      ),
                    );
                  },
                ),
                if (_isStreamLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isCapturingManually
              ? null
              : () async {
                  if (_ipAddress == null) return;
                  setState(() => _isCapturingManually = true);
                  await _captureAndUploadImage();
                  if (mounted) setState(() => _isCapturingManually = false);
                },
          icon: const Icon(Icons.camera_alt),
          label: Text(_isCapturingManually ? 'Mengambil...' : 'Ambil Gambar'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMotionSensorSection(Color primaryColor) {
    return _SensorStatusCard(
      icon: Icons.motion_photos_on,
      label: 'Sensor Gerak',
      value: _isMotionSensorActive ? "Mencurigakan" : "Aktivitas Normal",
      active: _isMotionSensorActive,
      primaryColor: primaryColor,
    );
  }

  Widget _buildDetectionHistorySection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Riwayat Deteksi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('History')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text('Gagal memuat data riwayat.');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Tidak ada riwayat deteksi', style: TextStyle(color: Colors.grey)),
                );
              }

              final logs = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final motionType = data['motion'] ?? 'Tidak diketahui';
                final timestampStr = data['timestamp'] ?? '';
                String formattedTime = 'Tidak diketahui';

                try {
                  final dt = DateTime.parse(timestampStr);
                  formattedTime = TimeOfDay.fromDateTime(dt).format(context);
                } catch (_) {}

                return DetectionLog(
                  time: formattedTime,
                  type: motionType,
                );
              }).toList();

              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) =>
                    _buildDetectionLogItem(logs[index], primaryColor),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionLogItem(DetectionLog log, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.notifications_active, color: primaryColor),
        ),
        title: Text(log.type, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text("Waktu: ${log.time}"),
        trailing: Icon(Icons.chevron_right, color: primaryColor),
      ),
    );
  }
}

class DetectionLog {
  final String time;
  final String type;

  DetectionLog({required this.time, required this.type});
}

class _SensorStatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool active;
  final Color primaryColor;

  const _SensorStatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.active,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? primaryColor : primaryColor.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: active ? primaryColor : primaryColor.withOpacity(0.8)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: active ? primaryColor : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
