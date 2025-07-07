import 'package:flutter/material.dart';
import '../models/note_model.dart';

class AddNotePage extends StatelessWidget {
  final void Function(NoteModel) onSave;

  const AddNotePage({required this.onSave, super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Tambah Catatan"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            TextField(
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 6,
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
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty) {
                    onSave(
                      NoteModel(
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
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
