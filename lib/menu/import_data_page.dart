import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Untuk memilih file
import 'dart:io'; // Untuk operasi file

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  String _importStatus = '';

  // Fungsi untuk mengimpor data catatan
  Future<void> _importNotes() async {
    setState(() {
      _importStatus = 'Memilih file...';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json'], // Izinkan file teks atau JSON
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _importStatus = 'Membaca file: ${file.path}';
        });

        String fileContent = await file.readAsString();

        // TODO: Implementasi logika parsing data yang sebenarnya di sini.
        // Anda perlu mengurai fileContent berdasarkan formatnya (teks, JSON, dll.)
        // dan menambahkan catatan ke model data aplikasi Anda.
        // Contoh sederhana untuk file teks:
        List<String> importedNotes = fileContent.split('\n\n---\n\n');
        // Misalnya, Anda bisa menambahkan ini ke daftar catatan Anda
        // for (String noteContent in importedNotes) {
        //   // Buat objek NoteModel dan tambahkan ke database/list Anda
        // }

        setState(() {
          _importStatus =
              'Data berhasil diimpor dari: ${file.path}. Ditemukan ${importedNotes.length} catatan (TODO: tambahkan ke aplikasi).';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diimpor!')),
          );
        }
      } else {
        // Pengguna membatalkan pemilihan file
        setState(() {
          _importStatus = 'Pemilihan file dibatalkan.';
        });
      }
    } catch (e) {
      setState(() {
        _importStatus = 'Gagal mengimpor data: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengimpor data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impor Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Impor catatan Anda dari file teks atau JSON. Pastikan format file sesuai dengan yang diekspor sebelumnya.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _importNotes,
                icon: const Icon(Icons.file_download),
                label: const Text('Impor Catatan Sekarang'),
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
              _importStatus,
              style: TextStyle(
                color: _importStatus.startsWith('Gagal')
                    ? Colors.red
                    : Colors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Catatan: Pastikan Anda memiliki izin yang diperlukan untuk membaca file dari penyimpanan perangkat Anda.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            // TODO: Tambahkan opsi untuk memilih format impor (JSON, CSV, dll.)
          ],
        ),
      ),
    );
  }
}
