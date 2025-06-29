import 'package:flutter/material.dart';

class AddNotePage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  void _saveNote(BuildContext context) {
    if (controller.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan disimpan!')),
      );
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Tulis catatanmu di sini...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _saveNote(context),
            icon: Icon(Icons.check),
            label: Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
