import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import 'add_note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NoteModel> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('notes') ?? [];

    setState(() {
      notes = jsonList
          .map((item) => NoteModel.fromMap(json.decode(item)))
          .toList();
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        notes.map((note) => json.encode(note.toMap())).toList();
    await prefs.setStringList('notes', jsonList);
  }

  void _editNote(int index) async {
    final edited = await showDialog<NoteModel>(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: notes[index].title);
        final contentController = TextEditingController(text: notes[index].content);
        return AlertDialog(
          title: const Text('Edit Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Judul')),
              const SizedBox(height: 12),
              TextField(controller: contentController, decoration: const InputDecoration(hintText: 'Isi')),
            ],
          ),
          actions: [
            TextButton(child: const Text('Batal'), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () {
                if (titleController.text.trim().isNotEmpty &&
                    contentController.text.trim().isNotEmpty) {
                  Navigator.pop(context, NoteModel(
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                  ));
                }
              },
            ),
          ],
        );
      },
    );

    if (edited != null) {
      setState(() {
        notes[index] = edited;
      });
      await _saveNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan diperbarui!')),
      );
    }
  }

  void _deleteNote(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        notes.removeAt(index);
      });
      await _saveNotes();
    }
  }

  Widget _buildNoteList() {
    if (notes.isEmpty) {
      return const Center(
        child: Text('Belum ada catatan.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: notes.length,
      itemBuilder: (context, index) => NoteCard(
        note: notes[index],
        onEdit: () => _editNote(index),
        onDelete: () => _deleteNote(index),
      ),
    );
  }

  void _navigateToAddNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNotePage(
          onSave: (NoteModel note) async {
            setState(() {
              notes.add(note);
            });
            await _saveNotes();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Catatan ditambahkan!')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Note App"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, User 👋",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(child: _buildNoteList()),
          ],
        ),
      ),
    );
  }
}
