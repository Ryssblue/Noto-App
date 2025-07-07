import 'package:flutter/material.dart';
import '../models/note_model.dart';

class EditNotePage extends StatefulWidget {
  final NoteModel note;

  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
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
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan isi tidak boleh kosong")),
      );
      return;
    }

    final updatedNote = NoteModel(
      title: titleController.text.trim(),
      content: contentController.text.trim(),
    );

    Navigator.pop(context, updatedNote);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ambil theme sekarang

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Catatan"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            TextField(
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 6,
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
    );
  }
}
