import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final String content;

  const NoteCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.note),
        title: Text(content),
      ),
    );
  }
}
