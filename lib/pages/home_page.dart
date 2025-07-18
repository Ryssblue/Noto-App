import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import 'add_note_page.dart';
import 'edit_note_page.dart';
import 'auth_page.dart';
import 'note_detail_page.dart';
import '../menu/favorites_page.dart';
import '../menu/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NoteModel> notes = [];
  List<NoteModel> filteredNotes = [];
  String userName = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = jsonList.map((item) => NoteModel.fromMap(json.decode(item))).toList();
      filteredNotes = notes;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((note) => json.encode(note.toMap())).toList();
    await prefs.setStringList('notes', jsonList);
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(query);
        final contentMatch = note.content.toLowerCase().contains(query);
        return titleMatch || contentMatch;
      }).toList();
    });
  }

  Future<void> _refreshNotes() async {
    await _loadNotes();
    _filterNotes();
  }

  void _toggleFavorite(int originalIndex) {
    setState(() {
      notes[originalIndex].toggleFavorite();
    });
    _saveNotes();
    _filterNotes();
  }
  
  void _viewNote(int originalIndex) {
    // Navigasi ke halaman detail dengan membawa data catatan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailPage(note: notes[originalIndex]),
      ),
    );
  }
  void _editNote(int originalIndex) async {
    await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: notes[originalIndex])),
    );
    await _refreshNotes();
  }

  void _deleteNote(int originalIndex) async {
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
        notes.removeAt(originalIndex);
      });
      await _saveNotes();
      _filterNotes();
    }
  }

  Widget _buildNoteList() {
    if (filteredNotes.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Belum ada catatan.'
              : 'Catatan tidak ditemukan.',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        final originalIndex = notes.indexOf(note);

        return NoteCard(
          note: note,
          onTap: () => _viewNote(originalIndex), 
          onEdit: () => _editNote(originalIndex),
          onDelete: () => _deleteNote(originalIndex),
          onToggleFavorite: () => _toggleFavorite(originalIndex),
        );
      },
    );
  }

  void _navigateToAddNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNotePage(
          onSave: (NoteModel newNote) async {
            setState(() {
              notes.add(newNote);
            });
            await _saveNotes();
            _filterNotes();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan ditambahkan!')),
              );
            }
          },
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Noto"),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Halo, $userName',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text('Favorit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Folder'),
              onTap: () {
                // TODO: Navigasi ke Halaman Folder
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('Tags'),
              onTap: () {
                // TODO: Navigasi ke Halaman Tags
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Arsip'),
              onTap: () {
                // TODO: Navigasi ke Halaman Arsip
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Sampah'),
              onTap: () {
                // TODO: Navigasi ke Halaman Sampah
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang, $userName 👋',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildNoteList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}