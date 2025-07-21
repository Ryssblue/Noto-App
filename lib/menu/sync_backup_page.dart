import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal dan waktu

class SyncBackupPage extends StatefulWidget {
  const SyncBackupPage({super.key});

  @override
  State<SyncBackupPage> createState() => _SyncBackupPageState();
}

class _SyncBackupPageState extends State<SyncBackupPage> {
  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadLastSyncTime();
  }

  // Memuat waktu sinkronisasi terakhir dari SharedPreferences
  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastSyncTimeString = prefs.getString('lastSyncTime');
    if (lastSyncTimeString != null) {
      setState(() {
        _lastSyncTime = DateTime.parse(lastSyncTimeString);
      });
    }
  }

  // Mensimulasikan proses sinkronisasi
  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    // TODO: Implementasi logika sinkronisasi data yang sebenarnya di sini.
    // Ini bisa berupa:
    // 1. Mengunggah catatan ke layanan cloud (misal Firebase Firestore, Supabase).
    // 2. Mengunduh catatan dari layanan cloud.
    // 3. Menyelesaikan konflik data.
    // Untuk contoh ini, kita hanya akan menunda selama beberapa detik.
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('lastSyncTime', now.toIso8601String());

    setState(() {
      _lastSyncTime = now;
      _isSyncing = false;
    });

    // Tampilkan pesan sukses
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sinkronisasi selesai!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinkronisasi & Cadangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Waktu Sinkronisasi Terakhir'),
              subtitle: Text(
                _lastSyncTime == null
                    ? 'Belum pernah disinkronkan'
                    : 'Terakhir: ${DateFormat('dd MMMM yyyy, HH:mm').format(_lastSyncTime!)}',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _performSync,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isSyncing ? 'Mensinkronkan...' : 'Sinkronkan Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Pengaturan Cadangan Otomatis (TODO):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Cadangan Otomatis ke Cloud'),
              trailing: Switch(
                value: false, // TODO: Ganti dengan nilai dari SharedPreferences
                onChanged: (bool value) {
                  // TODO: Implementasi logika untuk mengaktifkan/menonaktifkan cadangan otomatis
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur cadangan otomatis akan datang!')),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Frekuensi Cadangan'),
              subtitle: const Text('Setiap hari'), // TODO: Ganti dengan nilai dari SharedPreferences
              onTap: () {
                // TODO: Implementasi dialog untuk memilih frekuensi cadangan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengaturan frekuensi cadangan akan datang!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
