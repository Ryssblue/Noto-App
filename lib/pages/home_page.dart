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
import '../menu/archived_notes_page.dart'; // Import halaman arsip
import '../menu/feedback_page.dart'; // Import halaman feedback

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
      notes = jsonList
          .map((item) => NoteModel.fromMap(json.decode(item)))
          .toList();
      // Pastikan catatan yang diarsipkan tidak muncul di halaman utama secara default
      filteredNotes = notes.where((note) => !note.isArchived).toList();
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
      // Filter catatan yang tidak diarsipkan dan cocok dengan kueri pencarian
      filteredNotes = notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(query);
        final contentMatch = note.content.toLowerCase().contains(query);
        return (titleMatch || contentMatch) && !note.isArchived;
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
    _filterNotes(); // Re-filter untuk memperbarui tampilan jika perlu
  }

  void _viewNote(int originalIndex) {
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
      MaterialPageRoute(
        builder: (_) => EditNotePage(note: notes[originalIndex]),
      ),
    );
    await _saveNotes();
    await _refreshNotes(); // Muat ulang dan filter catatan untuk memperbarui UI
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Catatan berhasil diubah!')));
    }
  }

  void _deleteNote(int originalIndex) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // Ambil tema untuk Alert Dialog
        final dialogTheme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // Set background color for AlertDialog to follow theme
          backgroundColor:
              dialogTheme.cardColor, // Use cardColor for dialog background
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                'Hapus Catatan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dialogTheme.textTheme.titleLarge?.color,
                ), // Adjust text color
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus catatan ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              fontSize: 16,
              color: dialogTheme.textTheme.bodyMedium?.color,
            ), // Adjust text color
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: dialogTheme.hintColor,
                ), // Use hintColor for muted text
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        notes.removeAt(originalIndex);
      });
      await _saveNotes();
      _filterNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil dihapus!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _archiveNote(int originalIndex) {
    setState(() {
      notes[originalIndex].toggleArchive();
    });
    _saveNotes();
    _filterNotes();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan diarsipkan!')));
  }

  Widget _buildNoteList() {
    // Get text colors from theme
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    if (filteredNotes.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Belum ada catatan.'
              : 'Catatan tidak ditemukan.',
          style: TextStyle(
            color: textColor?.withOpacity(0.6),
            fontSize: 16,
          ), // Use theme color with opacity
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
          onArchive: () => _archiveNote(originalIndex),
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
    // Use colors from the theme
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final appBarBgColor = theme.appBarTheme.backgroundColor;
    final appBarFgColor = theme.appBarTheme.foregroundColor;
    final drawerHeaderColor =
        theme.primaryColor; // Or a specific color from your theme
    final drawerItemColor = theme
        .textTheme
        .bodyMedium
        ?.color; // Color for drawer list tile text/icons
    final floatingActionButtonColor =
        theme.colorScheme.secondary; // Usually secondary color
    final floatingActionButtonIconColor =
        theme.colorScheme.onSecondary; // Color for icon on secondary color

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          "Noto",
          style: TextStyle(color: appBarFgColor),
        ), // Ensure title color adjusts
        elevation: 0,
        backgroundColor: appBarBgColor, // Use theme color for AppBar background
        surfaceTintColor:
            Colors.transparent, // Keep this transparent or set based on theme
        iconTheme: IconThemeData(
          color: appBarFgColor,
        ), // Adjust leading icon color
      ),
      drawer: Drawer(
        // Set drawer background color to match app's overall theme or a specific dark variant
        backgroundColor: theme
            .scaffoldBackgroundColor, // Or theme.cardColor for a slightly different shade
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: drawerHeaderColor,
              ), // Use theme color
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ), // Icons in DrawerHeader often stay white for contrast
                  SizedBox(height: 8),
                  Text(
                    'Halo, $userName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ), // Text in DrawerHeader often stays white
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: drawerItemColor),
              title: Text('Beranda', style: TextStyle(color: drawerItemColor)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.star_border, color: drawerItemColor),
              title: Text('Favorit', style: TextStyle(color: drawerItemColor)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritesPage(allNotes: notes),
                  ),
                );
                _refreshNotes();
              },
            ),
            Divider(
              color: drawerItemColor?.withOpacity(0.3),
            ), // Theme-aware divider
            ListTile(
              leading: Icon(Icons.archive_outlined, color: drawerItemColor),
              title: Text('Arsip', style: TextStyle(color: drawerItemColor)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchivedNotesPage(allNotes: notes),
                  ),
                );
                _refreshNotes();
              },
            ),
             ListTile(
              leading: Icon(Icons.feedback_outlined, color: drawerItemColor),
              title: Text('Feedback', style: TextStyle(color: drawerItemColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                );
              },
            ),
            Divider(
              color: drawerItemColor?.withOpacity(0.3),
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: drawerItemColor),
              title: Text(
                'Pengaturan',
                style: TextStyle(color: drawerItemColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: drawerItemColor),
              title: Text('Logout', style: TextStyle(color: drawerItemColor)),
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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme
                    .textTheme
                    .headlineSmall
                    ?.color, // Ensure color is taken from theme
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.hintColor,
                ), // Use theme hintColor for icon
                filled: true,
                // inputDecorationTheme.fillColor from main.dart is already handled by InputDecoration
                // So, no need to manually set fillColor here unless you want to override it.
                // If you want it to use theme.cardColor as before, uncomment below:
                // fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(
                  color: theme.hintColor,
                ), // Ensure hint text color adjusts
                // The border styles (focusedBorder, enabledBorder) are already defined in InputDecorationTheme in main.dart
              ),
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
              ), // Ensure input text color adjusts
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshNotes,
                child: _buildNoteList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        tooltip: 'Tambah Catatan',
        backgroundColor: floatingActionButtonColor, // Use theme color
        foregroundColor:
            floatingActionButtonIconColor, // Use theme color for icon
        child: const Icon(Icons.add),
      ),
    );
  }
}
