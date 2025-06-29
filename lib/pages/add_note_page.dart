import 'package:flutter/material.dart';

class AddNotePage extends StatelessWidget {
  final void Function(String) onSave;

  const AddNotePage({required this.onSave, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Tulis catatanmu di sini...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                controller.clear();
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
