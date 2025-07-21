import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashSettingsPage extends StatefulWidget {
  const TrashSettingsPage({super.key});

  @override
  State<TrashSettingsPage> createState() => _TrashSettingsPageState();
}

class _TrashSettingsPageState extends State<TrashSettingsPage> {
  int _retentionDays = 30; // Default: 30 hari
  final String _trashRetentionKey = 'trashRetentionDays';

  @override
  void initState() {
    super.initState();
    _loadRetentionSetting();
  }

  // Memuat pengaturan retensi dari SharedPreferences
  Future<void> _loadRetentionSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _retentionDays = prefs.getInt(_trashRetentionKey) ?? 30;
    });
  }

  // Menyimpan pengaturan retensi ke SharedPreferences
  Future<void> _saveRetentionSetting(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trashRetentionKey, days);
    setState(() {
      _retentionDays = days;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan di sampah akan dihapus setelah $_retentionDays hari.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Sampah'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Hapus Otomatis Catatan Lama'),
            subtitle: const Text('Catatan di sampah akan dihapus setelah jangka waktu tertentu.'),
          ),
          RadioListTile<int>(
            title: const Text('7 Hari'),
            value: 7,
            groupValue: _retentionDays,
            onChanged: (int? value) {
              if (value != null) {
                _saveRetentionSetting(value);
              }
            },
          ),
          RadioListTile<int>(
            title: const Text('30 Hari (Default)'),
            value: 30,
            groupValue: _retentionDays,
            onChanged: (int? value) {
              if (value != null) {
                _saveRetentionSetting(value);
              }
            },
          ),
          RadioListTile<int>(
            title: const Text('60 Hari'),
            value: 60,
            groupValue: _retentionDays,
            onChanged: (int? value) {
              if (value != null) {
                _saveRetentionSetting(value);
              }
            },
          ),
          RadioListTile<int>(
            title: const Text('Jangan Pernah Hapus Otomatis'),
            value: 0, // Menggunakan 0 untuk "jangan pernah"
            groupValue: _retentionDays,
            onChanged: (int? value) {
              if (value != null) {
                _saveRetentionSetting(value);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Kosongkan Sampah Sekarang'),
            subtitle: const Text('Hapus semua catatan di sampah secara permanen.'),
            onTap: () {
              _showConfirmEmptyTrashDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi untuk mengosongkan sampah
  void _showConfirmEmptyTrashDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kosongkan Sampah?'),
          content: const Text('Apakah Anda yakin ingin menghapus semua catatan di sampah secara permanen? Tindakan ini tidak dapat dibatalkan.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // TODO: Implementasi logika untuk menghapus semua catatan di sampah
                // Ini akan melibatkan interaksi dengan model data catatan Anda.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sampah dikosongkan (fungsionalitas TODO)!')),
                );
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
