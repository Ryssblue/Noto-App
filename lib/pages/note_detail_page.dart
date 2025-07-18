import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'edit_note_page.dart';

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

  // Fungsi untuk navigasi ke halaman edit
  Future<void> _navigateToEditPage() async {
    // Tunggu hasil dari EditNotePage
    final updatedNote = await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: _note)),
    );

    // Jika ada data yang dikembalikan (catatan diperbarui),
    // perbarui UI halaman ini
    if (updatedNote != null) {
      setState(() {
        _note = updatedNote;
      });
    }
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
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Ubah Catatan',
            onPressed: _navigateToEditPage,
          ),
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
              // Menampilkan seluruh konten catatan
              Text(
                _note.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5, // Atur jarak antar baris agar mudah dibaca
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}