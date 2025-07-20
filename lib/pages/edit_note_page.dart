import 'package:flutter/material.dart';
import '../models/note_model.dart';

class EditNotePage extends StatefulWidget {
  final NoteModel note; // Catatan yang akan diedit

  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data catatan yang ada
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      // Pastikan form valid
      // ✅ PERBAIKAN UTAMA DI SINI: Langsung perbarui properti dari objek note yang ada
      widget.note.title = titleController.text.trim();
      widget.note.content = contentController.text.trim();
      // Properti lain seperti id, createdAt, isFavorite, isArchived
      // tidak perlu diubah karena sudah ada di objek widget.note dan tidak diedit di sini.

      // Kembalikan objek note yang sudah diperbarui
      Navigator.pop(context, widget.note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Catatan"),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          // Menggunakan Form untuk validasi
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                // Menggunakan TextFormField
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  labelStyle: theme.textTheme.bodyMedium,
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
                // Memungkinkan konten multi-baris
                child: TextFormField(
                  // Menggunakan TextFormField
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: 'Isi',
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    labelStyle: theme.textTheme.bodyMedium,
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
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
