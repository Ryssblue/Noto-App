import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import 'add_note_page.dart';
import 'edit_note_page.dart';

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
    final jsonList = notes.map((note) => json.encode(note.toMap())).toList();
    await prefs.setStringList('notes', jsonList);
  }

  void _editNote(int index) async {
    final updatedNote = await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: notes[index])),
    );

    if (updatedNote != null) {
      setState(() {
        notes[index] = updatedNote;
      });
      await _saveNotes();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Catatan diperbarui!')));
    }
  }

  void _deleteNote(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Note App"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, User 👋", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(child: _buildNoteList()),
          ],
        ),
      ),
    );
  }
}
