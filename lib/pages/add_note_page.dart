import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'package:uuid/uuid.dart'; // Pastikan package 'uuid' sudah ditambahkan di pubspec.yaml

class AddNotePage extends StatefulWidget {
  final void Function(NoteModel) onSave;

  const AddNotePage({required this.onSave, super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final Uuid _uuid = const Uuid(); // Inisialisasi Uuid untuk ID unik

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
  if (_formKey.currentState!.validate()) {
    final newNote = NoteModel(
      id: _uuid.v4(),
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      createdAt: DateTime.now(),
      isFavorite: false,
      isArchived: false,
    );
    widget.onSave(newNote);
    // Add this check
    if (Navigator.canPop(context)) { // Check if there's a route to pop
      Navigator.pop(context); // Go back to the previous page after saving
    } else {
      print('No route to pop, staying on AddNotePage or navigating manually.');
    }
  }
}
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tambah Catatan"),
        elevation: 0,
        // Tombol simpan dihapus dari AppBar untuk dipindahkan ke bawah
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          // Membungkus input dengan Form untuk validasi
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                // Kolom input untuk judul catatan
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Judul catatan...',
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: theme.textTheme.bodyMedium,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                // Kolom input untuk konten, mengisi sisa ruang
                child: TextFormField(
                  controller: contentController,
                  maxLines:
                      null, // Memungkinkan input multi-line tanpa batas baris
                  expands:
                      true, // Memungkinkan TextField untuk mengisi ruang yang tersedia secara vertikal
                  textAlignVertical:
                      TextAlignVertical.top, // Memulai teks dari atas
                  decoration: InputDecoration(
                    hintText: 'Tulis isi catatan...',
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Konten tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24), // Spasi antara konten dan tombol
              SizedBox(
                // Tombol "Simpan Catatan" yang menempel di bawah
                width: double.infinity, // Lebar penuh
                child: ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.check),
                  label: const Text('Simpan Catatan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
