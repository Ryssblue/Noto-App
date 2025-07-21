import 'package:flutter/material.dart';
import 'dart:io'; // Untuk operasi file
import 'package:path_provider/path_provider.dart'; // Untuk mendapatkan direktori

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  String _exportStatus = '';

  // Fungsi untuk mengekspor data catatan
  Future<void> _exportNotes() async {
    setState(() {
      _exportStatus = 'Mengekspor data...';
    });

    try {
      // TODO: Ganti dengan pengambilan data catatan Anda yang sebenarnya
      // Misalnya, dari database atau daftar di memori.
      final List<String> notes = [
        'Catatan 1: Ini adalah catatan pertama saya.',
        'Catatan 2: Belanja: susu, roti, telur.',
        'Catatan 3: Ide proyek: aplikasi manajemen tugas.',
      ];

      // Format data untuk ekspor (misalnya, sebagai teks biasa, JSON, atau CSV)
      String fileContent = notes.join('\n\n---\n\n'); // Contoh format teks

      // Dapatkan direktori dokumen aplikasi
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/noto_notes_export.txt';
      final file = File(filePath);

      await file.writeAsString(fileContent);

      setState(() {
        _exportStatus = 'Data berhasil diekspor ke: $filePath';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diekspor!')),
        );
      }
    } catch (e) {
      setState(() {
        _exportStatus = 'Gagal mengekspor data: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengekspor data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ekspor Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ekspor semua catatan Anda ke file teks. Anda dapat memilih format yang berbeda di masa mendatang.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _exportNotes,
                icon: const Icon(Icons.file_upload),
                label: const Text('Ekspor Catatan Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _exportStatus,
              style: TextStyle(
                color: _exportStatus.startsWith('Gagal')
                    ? Colors.red
                    : Colors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Catatan: Untuk mengakses file yang diekspor, Anda mungkin perlu menggunakan file manager di perangkat Anda atau menghubungkan perangkat ke komputer.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            // TODO: Tambahkan opsi untuk memilih format ekspor (JSON, CSV, dll.)
            // TODO: Tambahkan opsi untuk memilih lokasi penyimpanan (jika diizinkan oleh OS)
          ],
        ),
      ),
    );
  }
}
