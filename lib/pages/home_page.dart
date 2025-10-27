import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan package intl di-import
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

  int _lastDataCount = 0; // untuk mendeteksi data baru

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi ambil data dari server
  Future<void> _fetchData() async {
    try {
      final data = await ApiService.getData();
      if (!_isInRoom) {
        if (data.length > _lastDataCount && _dataList.isNotEmpty) {
          final newItem = data.last;
          final rfid = newItem['rfid_tag'] ?? 'Unknown';
          final status = newItem['status'] ?? '-';
          final timestamp = newItem['timestamp'] ?? '';
          final time = timestamp != ''
              ? DateFormat('HH:mm:ss').format(
                  DateTime.parse(timestamp).toLocal(),
                )
              : '-';

        }

        setState(() {
          _dataList = data.reversed.toList();
          _lastDataCount = data.length;
        });
      }
    } catch (e) {
      debugPrint('Error fetch data: $e');
    }
  }

  void _toggleMode(bool isInRoom) {
    setState(() {
      _isInRoom = isInRoom;
    });

    if (_isInRoom) {
      _timer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status: Berada di kamar ✅')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status: Tidak di kamar 🚪')),
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
        title: const Text('Smart Door Monitor'),
        backgroundColor: const Color(0xFF7CAFA4),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                        radius: 25,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications_none_rounded, size: 28),
                ],
              ),

              const SizedBox(height: 20),

              // Mode box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEEEA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sedang berada di dalam kamar?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _toggleMode(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isInRoom ? Colors.teal : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('Ya'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _toggleMode(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  !_isInRoom ? Colors.teal : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('Tidak'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Histori Keluar-Masuk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: _isInRoom
                    ? const Center(
                        child: Text(
                          'Mode dalam kamar aktif.\nData tidak diambil dari server.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
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
                              final time = timestamp != ''
                                  ? DateFormat('HH:mm:ss').format(
                                      DateTime.parse(timestamp).toLocal(),
                                    )
                                  : '-';
                              
                              // Menambahkan hari dan tanggal di sebelah kanan
                              final date = timestamp != ''
                                  ? DateFormat('dd MMMM yyyy').format(
                                      DateTime.parse(timestamp).toLocal(),
                                    )
                                  : '-';
                              
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
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RFID: $rfid',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7CAFA4),
                ),
              ),
              const SizedBox(height: 8),
              Text('Status: $status'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.teal),
                  const SizedBox(width: 5),
                  Text(time, style: const TextStyle(color: Colors.teal)),
                ],
              ),
            ],
          ),
          Text(
            date, // Menampilkan tanggal di sebelah kanan
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
