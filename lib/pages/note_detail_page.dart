import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'edit_note_page.dart';
import 'package:intl/intl.dart';

class NoteDetailPage extends StatefulWidget {
  // Menerima data catatan dari halaman sebelumnya (HomePage)
  final NoteModel note;

  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  // Menyimpan note di dalam state agar bisa diperbarui setelah diedit
  late NoteModel _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Judul AppBar diambil dari judul catatan
        title: Text(_note.title),
        actions: [
          // Tombol untuk mengedit catatan
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menampilkan judul dengan gaya yang lebih besar
              Text(
                _note.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // --- BAGIAN BARU: Tampilkan Gambar jika ada ---
              if (_note.imagePath != null && _note.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_note.imagePath!),
                      width: double.infinity,
                      fit: BoxFit
                          .fitWidth, // Atau BoxFit.cover sesuai preferensi
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: 150,
                          child: Center(
                            child: Text(
                              'Gagal memuat gambar',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // --- AKHIR BAGIAN BARU ---

              // Menampilkan seluruh konten catatan
              Text(
                _note.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5, // Atur jarak antar baris agar mudah dibaca
                ),
              ),
              const SizedBox(height: 16),
              // Tambahkan informasi lain seperti tanggal dibuat jika diperlukan
              Text(
                'Dibuat pada: ${DateFormat('dd MMM yyyy, HH:mm').format(_note.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
