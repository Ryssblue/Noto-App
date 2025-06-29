import 'package:flutter/material.dart';
import '../widgets/note_card.dart';

class HomePage extends StatelessWidget {
  final List<String> notes = [
    'Belajar Flutter',
    'Rancang UI aplikasi Noto',
    'Catatan harian hari ini',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCard(content: notes[index]);
      },
    );
  }
}
