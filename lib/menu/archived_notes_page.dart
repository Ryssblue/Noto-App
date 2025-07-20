// menu/archived_notes_page.dart
import 'dart:async'; // Pastikan ada jika menggunakan Future
import 'dart:convert'; // Untuk json.encode/decode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import '../pages/note_detail_page.dart';

class ArchivedNotesPage extends StatefulWidget {
  final List<NoteModel> allNotes; // Menerima semua catatan dari HomePage

  const ArchivedNotesPage({Key? key, required this.allNotes}) : super(key: key);

  @override
  State<ArchivedNotesPage> createState() => _ArchivedNotesPageState();
}

class _ArchivedNotesPageState extends State<ArchivedNotesPage> {
  // Gunakan 'late' karena akan diinisialisasi di initState,
  // atau jadikan nullable jika tidak selalu ada data awal.
  // Untuk kasus ini, 'late' aman karena allNotes selalu dikirim.
  late List<NoteModel> _editableAllNotes; // Salinan catatan yang bisa diedit

  List<NoteModel> archivedNotes = [];

  @override
  void initState() {
    super.initState();
    // Penting: Buat salinan yang bisa diubah dari daftar yang diterima.
    // Ini agar perubahan yang dilakukan di halaman arsip tidak langsung
    // memengaruhi daftar 'notes' di HomePage sebelum disimpan.
    _editableAllNotes = List<NoteModel>.from(widget.allNotes);
    _filterArchivedNotes();
  }

  @override
  void didUpdateWidget(covariant ArchivedNotesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Perbarui salinan lokal jika daftar 'allNotes' yang diterima dari widget berubah
    if (widget.allNotes != oldWidget.allNotes) {
      _editableAllNotes = List<NoteModel>.from(widget.allNotes);
      _filterArchivedNotes();
    }
  }

  void _filterArchivedNotes() {
    setState(() {
      archivedNotes = _editableAllNotes
          .where((note) => note.isArchived)
          .toList();
    });
  }

  /// Mengembalikan catatan dari arsip ke status tidak diarsipkan.
  Future<void> _unarchiveNote(NoteModel noteToUnarchive) async {
    setState(() {
      final index = _editableAllNotes.indexWhere(
        (note) => note.id == noteToUnarchive.id,
      );
      if (index != -1) {
        _editableAllNotes[index].toggleArchive(); // Ubah status arsip
        _filterArchivedNotes(); // Perbarui daftar catatan di halaman ini
      }
    });
    // Simpan perubahan ke SharedPreferences setelah setState selesai
    await _saveNotes(_editableAllNotes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan dikembalikan dari arsip.')),
      );
    }
  }

  /// Menghapus catatan secara permanen dari daftar dan penyimpanan.
  Future<void> _deleteNotePermanently(NoteModel noteToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Permanen'),
        content: const Text(
          'Yakin ingin menghapus catatan ini secara permanen? Aksi ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ), // Beri warna merah untuk aksi hapus
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _editableAllNotes.removeWhere((note) => note.id == noteToDelete.id);
        _filterArchivedNotes(); // Perbarui daftar catatan di halaman ini
      });
      // Simpan perubahan ke SharedPreferences setelah setState selesai
      await _saveNotes(_editableAllNotes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan dihapus permanen.')),
        );
      }
    }
  }

  /// Menyimpan semua catatan dari [_editableAllNotes] ke SharedPreferences.
  Future<void> _saveNotes(List<NoteModel> notesToSave) async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan `toMap()` ada di NoteModel Anda dan mengembalikan Map<String, dynamic>
    // Kemudian encode setiap map ke JSON string
    final jsonList = notesToSave
        .map((note) => json.encode(note.toMap()))
        .toList();
    await prefs.setStringList('notes', jsonList);
  }

  /// Menavigasi ke halaman detail catatan.
  void _viewNote(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arsip')),
      body: archivedNotes.isEmpty
          ? const Center(
              child: Text(
                'Belum ada catatan di arsip.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: archivedNotes.length,
              itemBuilder: (context, index) {
                final note = archivedNotes[index];
                return NoteCard(
                  note: note,
                  onTap: () => _viewNote(note),
                  // Aksi untuk 'Edit' sekarang menjadi 'Unarchive'
                  onEdit: () => _unarchiveNote(note),
                  // Aksi untuk 'Delete' sekarang menjadi 'Delete Permanently'
                  onDelete: () => _deleteNotePermanently(note),
                  onToggleFavorite: () {
                    // Anda bisa menambahkan fungsionalitas favorit/unfavorit di sini
                    // jika diperlukan, dan pastikan untuk memanggil _saveNotes(_editableAllNotes)
                  },
                  // Menggunakan ikon kustom dari NoteCard
                  editIcon: Icons.unarchive, // Ikon untuk 'Unarchive'
                  deleteIcon:
                      Icons.delete_forever, // Ikon untuk 'Delete Permanently'
                );
              },
            ),
    );
  }
}
