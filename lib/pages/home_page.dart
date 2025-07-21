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
    // Menunggu hasil dari EditNotePage (catatan yang sudah diedit)
    // Karena NoteModel diteruskan sebagai referensi, perubahan di EditNotePage
    // langsung memengaruhi objek di `notes[originalIndex]`.
    // Kita hanya perlu await untuk memastikan EditNotePage selesai,
    // lalu panggil _saveNotes() untuk menyimpan perubahan tersebut.
    await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(
        builder: (_) => EditNotePage(note: notes[originalIndex]),
      ),
    );
    // ✅ PERBAIKAN PENTING: Panggil _saveNotes() setelah EditNotePage selesai
    await _saveNotes();
    await _refreshNotes(); // Muat ulang dan filter catatan untuk memperbarui UI
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Catatan berhasil diubah!')));
    }
  }

  // Existing _deleteNote function
  void _deleteNote(int originalIndex) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // Add BuildContext type hint
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ), // Softer corners
          title: Row(
            // Add an icon to the title
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                'Hapus Catatan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus catatan ini? Tindakan ini tidak dapat dibatalkan.', // More descriptive text
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey), // Muted color for cancel
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Prominent red for delete
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
            backgroundColor: Colors.red, // Green feedback for success
          ),
        );
      }
    }
  }

  // Fungsi untuk mengarsipkan catatan
  void _archiveNote(int originalIndex) {
    setState(() {
      notes[originalIndex].toggleArchive(); // Mengubah status isArchived
    });
    _saveNotes();
    _filterNotes(); // Perbarui daftar catatan yang ditampilkan (sembunyikan yang diarsipkan)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan diarsipkan!')));
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
        final originalIndex = notes.indexOf(
          note,
        ); // Dapatkan indeks di daftar `notes` asli

        return NoteCard(
          note: note,
          onTap: () => _viewNote(originalIndex),
          onEdit: () => _editNote(originalIndex),
          onDelete: () => _deleteNote(originalIndex),
          onToggleFavorite: () => _toggleFavorite(originalIndex),
          onArchive: () => _archiveNote(originalIndex), // Panggil fungsi arsip
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
            _filterNotes(); // Re-filter untuk menyertakan catatan baru dalam daftar yang ditampilkan
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
              onTap: () async {
                Navigator.pop(context); // Tutup drawer
                await Navigator.push(
                  context,
                  // Kirim semua catatan ke FavoritesPage agar bisa difilter
                  MaterialPageRoute(
                    builder: (_) => FavoritesPage(allNotes: notes),
                  ),
                );
                _refreshNotes(); // Muat ulang catatan setelah kembali
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Arsip'),
              onTap: () async {
                Navigator.pop(context); // Tutup drawer
                await Navigator.push(
                  context,
                  // Kirim semua catatan ke ArchivedNotesPage
                  MaterialPageRoute(
                    builder: (_) => ArchivedNotesPage(allNotes: notes),
                  ),
                );
                _refreshNotes(); // Muat ulang catatan setelah kembali
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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
            Expanded(
              child: RefreshIndicator(
                // Tambahkan RefreshIndicator untuk pull-to-refresh
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
