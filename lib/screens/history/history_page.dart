import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/costum_header.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? selectedDate;

  Stream<QuerySnapshot> getCaptureStream() {
    final ref = FirebaseFirestore.instance.collection('captures');
    if (selectedDate != null) {
      final start = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );
      final end = start.add(const Duration(days: 1));
      return ref
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThan: Timestamp.fromDate(end))
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      return ref.orderBy('timestamp', descending: true).snapshots();
    }
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5F59A6);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Riwayat Deteksi'),
      body: Column(
        children: [
          // Filter tanggal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range, color: Colors.white),
                    label: Text(
                      selectedDate != null
                          ? DateFormat('dd MMM yyyy').format(selectedDate!)
                          : 'Pilih Tanggal',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: primaryColor),
                    onPressed: () {
                      setState(() {
                        selectedDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),

          // StreamBuilder ambil data dari Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getCaptureStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada riwayat deteksi."));
                }

                final items = snapshot.data!.docs;

                return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: GridView.builder(
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.84, // proporsi ideal
    ),
    itemBuilder: (context, index) {
      final data = items[index].data() as Map<String, dynamic>;
      final imageUrl = data['imageUrl'] ?? '';
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final timeText = DateFormat('yyyy-MM-dd • HH:mm').format(timestamp);

      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 4),
              )
            ],
            border: Border.all(color: primaryColor.withOpacity(0.1)),
          ),
          child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black12,
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        ),
      ),
    ),
    const SizedBox(height: 8),
    const Icon(Icons.visibility, size: 22, color: primaryColor),
    const SizedBox(height: 4),
    Padding(
      padding: const EdgeInsets.only(bottom: 2), // jarak ke bawah lebih sempit
      child: Text(
        timeText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    ),
  ],
),

        ),
      );
    },
  ),
);


              },
            ),
          ),
        ],
      ),
    );
  }
}
