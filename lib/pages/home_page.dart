import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isInRoom = true;
  List<dynamic> _dataList = [];
  Timer? _timer;
  int _lastDataCount = 0;

  @override
  void initState() {
    super.initState();
    // Inisialisasi default mode ke server
    ApiService.updateMode(_isInRoom).catchError((e) {
      debugPrint('❌ Gagal update mode default: $e');
    });

    if (!_isInRoom) {
      _startFetching();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    // ... (Fungsi _fetchData tidak perlu diubah)
    // ... (Code sama seperti sebelumnya)
    try {
      final data = await ApiService.getData(); 
      if (_isInRoom) {
        _timer?.cancel();
        return;
      }
      if (_dataList.isEmpty) {
        setState(() {
          _dataList = data;
          _lastDataCount = data.length;
        });
        return;
      }
      if (data.length > _lastDataCount) {
        final newItem = data.first;
        final rfid = newItem['rfid_tag'] ?? 'Unknown';
        final status = newItem['status'] ?? '-';

        if (status.toLowerCase().contains("terbuka")) {
          await ApiService.activateBuzzer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🔓 Akses baru: $rfid ($status)')),
          );
        }

        setState(() {
          _dataList = data;
          _lastDataCount = data.length;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetch data: $e');
    }
  }

  void _toggleMode(bool isInRoom) async {
    setState(() {
      _isInRoom = isInRoom;
    });

    try {
      await ApiService.updateMode(isInRoom);
    } catch (e) {
      debugPrint('❌ Gagal update mode: $e');
    }

    if (_isInRoom) {
      _timer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status: Berada di kamar ✅\nPolling dihentikan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status: Tidak di kamar 🚪\nPolling dimulai')),
      );
      _startFetching();
    }
  }

  void _startFetching() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchData();
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Menghapus 'title: const Text('Smart Door Monitor'),'
        title: const Text('DHEA SYSTEMS'), // Biarkan kosong atau hapus title sepenuhnya jika memungkinkan
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 28), // Ikon lebih besar
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28, // Ukuran avatar lebih besar
                        backgroundImage: AssetImage('assets/profile.png'),
                        backgroundColor: Colors.white, // Agar terlihat lebih rapi
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              // Font sudah menggunakan default/sans-serif sistem
                            ),
                          ),
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 22, // Ukuran font lebih besar
                              fontWeight: FontWeight.w700, // Lebih tebal
                              // Font sudah menggunakan default/sans-serif sistem
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Ganti Icon Notifikasi
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded, 
                      size: 24, 
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Mode box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25), // Padding lebih besar
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15, // Shadow lebih halus
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mode Monitoring',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Apakah Anda sedang berada di dalam kamar saat ini?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _toggleMode(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isInRoom ? const Color(0xFF7CAFA4) : Colors.grey.shade200, // Warna solid
                              foregroundColor:
                                  _isInRoom ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text('Di Kamar', style: TextStyle(fontWeight: _isInRoom ? FontWeight.bold : FontWeight.normal)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _toggleMode(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  !_isInRoom ? const Color(0xFF7CAFA4) : Colors.grey.shade200,
                              foregroundColor:
                                  !_isInRoom ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text('Di Luar', style: TextStyle(fontWeight: !_isInRoom ? FontWeight.bold : FontWeight.normal)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Aktivitas Pintu Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: _isInRoom
                    ? Center(
                        child: Text(
                          'Mode dalam kamar aktif.\nTidak ada pembaruan data real-time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      )
                    : _dataList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _dataList.length,
                            itemBuilder: (context, index) {
                              final item = _dataList[index];
                              final rfid = item['rfid_tag'] ?? 'Unknown';
                              final status = item['status'] ?? '-';
                              final timestamp = item['timestamp'] ?? '';

                              final DateTime parsedTime = timestamp != ''
                                  ? DateTime.parse(timestamp).toLocal()
                                  : DateTime.now();

                              final time = DateFormat('HH:mm:ss').format(parsedTime);
                              final date = DateFormat('dd MMM').format(parsedTime); // Format tanggal lebih ringkas

                              return _buildHistoryCard(rfid, status, time, date);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tampilan kartu histori
  Widget _buildHistoryCard(String rfid, String status, String time, String date) {
    // Tentukan ikon dan warna berdasarkan status
    final bool isOpened = status.toLowerCase().contains("terbuka");
    final IconData icon = isOpened ? Icons.lock_open_rounded : Icons.lock_rounded;
    final Color statusColor = isOpened ? Colors.orange.shade700 : const Color(0xFF7CAFA4);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Status
          Icon(icon, size: 30, color: statusColor),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.toUpperCase(), // Status di-kapitalisasi
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'RFID: $rfid',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Waktu dan Tanggal di sisi kanan
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    ); 
  }
}