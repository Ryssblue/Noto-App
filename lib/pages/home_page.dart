import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/note_card.dart';
import 'add_note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = savedNotes;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', notes);
  }

  void _editNote(int index) async {
    final editedText = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: notes[index]);
        return AlertDialog(
          title: const Text('Edit Catatan'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () => Navigator.pop(context, controller.text),
            ),
          ],
        );
      },
    );

    if (editedText != null && editedText.trim().isNotEmpty) {
      setState(() {
        notes[index] = editedText.trim();
      });
      await _saveNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil diperbarui!')),
      );
    }
  }

  void _deleteNote(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        notes.removeAt(index);
      });
      await _saveNotes();
    }
  }

  Widget _buildNoteList() {
    if (notes.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada catatan',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCard(
          content: notes[index],
          onEdit: () => _editNote(index),
          onDelete: () => _deleteNote(index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Noto - Catatan")),
      body: _selectedIndex == 0
          ? _buildNoteList()
          : AddNotePage(
              onSave: (String newNote) async {
                setState(() {
                  notes.add(newNote);
                  _selectedIndex = 0;
                });
                await _saveNotes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan berhasil ditambahkan!')),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Tambah'),
        ],
      ),
    );
  }
}
