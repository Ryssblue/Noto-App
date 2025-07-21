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
  late List<NoteModel> _editableAllNotes; // Salinan catatan yang bisa diedit

  List<NoteModel> archivedNotes = [];

  @override
  void initState() {
    super.initState();
    _editableAllNotes = List<NoteModel>.from(widget.allNotes);
    _filterArchivedNotes();
  }

  @override
  void didUpdateWidget(covariant ArchivedNotesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  Future<void> _unarchiveNote(NoteModel noteToUnarchive) async {
    setState(() {
      final index = _editableAllNotes.indexWhere(
        (note) => note.id == noteToUnarchive.id,
      );
      if (index != -1) {
        _editableAllNotes[index].toggleArchive();
        _filterArchivedNotes();
      }
    });
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
      builder: (BuildContext dialogContext) {
        // Use dialogContext to avoid conflicts
        // Ambil ThemeData dari dialogContext untuk tema AlertDialog
        final theme = Theme.of(dialogContext);
        final dialogTextColor = theme.textTheme.titleMedium?.color; // For title
        final dialogContentColor =
            theme.textTheme.bodyMedium?.color; // For content
        final buttonCancelColor = theme.hintColor; // For cancel button text

        return AlertDialog(
          // Set background color for AlertDialog to follow theme
          backgroundColor:
              theme.cardColor, // Use cardColor for dialog background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Permanen',
            style: TextStyle(color: dialogTextColor), // Apply theme text color
          ),
          content: Text(
            'Yakin ingin menghapus catatan ini secara permanen? Aksi ini tidak bisa dibatalkan.',
            style: TextStyle(
              color: dialogContentColor,
            ), // Apply theme text color
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false), // Use dialogContext here
              child: Text(
                'Batal',
                style: TextStyle(
                  color: buttonCancelColor,
                ), // Apply theme text color
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true), // Use dialogContext here
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red, // Keep red for prominent delete action
                foregroundColor: Colors.white, // Keep white text on red button
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ), // Text color on red button remains white
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _editableAllNotes.removeWhere((note) => note.id == noteToDelete.id);
        _filterArchivedNotes();
      });
      await _saveNotes(_editableAllNotes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan dihapus permanen.')),
        );
      }
    }
  }

  Future<void> _saveNotes(List<NoteModel> notesToSave) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notesToSave
        .map((note) => json.encode(note.toMap()))
        .toList();
    await prefs.setStringList('notes', jsonList);
  }

  void _viewNote(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme for this page's general elements
    final theme = Theme.of(context);
    final emptyListTextColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme
          .scaffoldBackgroundColor, // Ensure Scaffold background follows theme
      appBar: AppBar(
        title: Text(
          'Arsip',
          style: theme.appBarTheme.titleTextStyle,
        ), // Use AppBarTheme's text style
        backgroundColor: theme
            .appBarTheme
            .backgroundColor, // Use AppBarTheme's background color
        foregroundColor: theme
            .appBarTheme
            .foregroundColor, // Use AppBarTheme's foreground color for icons/text
        elevation: theme.appBarTheme.elevation,
      ),
      body: archivedNotes.isEmpty
          ? Center(
              child: Text(
                'Belum ada catatan di arsip.',
                style: TextStyle(
                  color: emptyListTextColor?.withOpacity(0.6),
                  fontSize: 16,
                ), // Apply theme text color with opacity
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
                  onEdit: () => _unarchiveNote(note),
                  onDelete: () => _deleteNotePermanently(note),
                  onToggleFavorite: () {
                    // You might want to implement this if favorites can be toggled in archive
                    // note.toggleFavorite();
                    // _saveNotes(_editableAllNotes);
                    // _filterArchivedNotes();
                  },
                  editIcon: Icons.unarchive,
                  deleteIcon: Icons.delete_forever,
                );
              },
            ),
    );
  }
}
