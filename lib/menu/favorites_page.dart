import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import '../pages/note_detail_page.dart'; // Make sure this import path is correct

class FavoritesPage extends StatefulWidget {
  // This list will be passed from HomePage and contains all notes.
  // We will filter it here to show only favorites.
  final List<NoteModel> allNotes;

  const FavoritesPage({Key? key, required this.allNotes}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // This list will hold only the notes that are marked as favorite.
  List<NoteModel> favoriteNotes = [];

  @override
  void initState() {
    super.initState();
    _filterFavoriteNotes(); // Initial filtering when the page loads
  }

  // This method is called when the widget's configuration changes (e.g., when allNotes is updated).
  @override
  void didUpdateWidget(covariant FavoritesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the incoming 'allNotes' list is different from the old one, re-filter.
    // This handles cases where notes might have been favorited/unfavorited
    // while this page was in the widget tree but not at the top.
    if (widget.allNotes != oldWidget.allNotes) {
      _filterFavoriteNotes();
    }
  }

  // Filters the 'allNotes' list to populate 'favoriteNotes'.
  void _filterFavoriteNotes() {
    setState(() {
      favoriteNotes = widget.allNotes.where((note) => note.isFavorite).toList();
    });
  }

  // Navigates to the NoteDetailPage to view the selected favorite note.
  void _viewNote(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: favoriteNotes.isEmpty
          ? const Center(
              child: Text(
                'Belum ada catatan favorit.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favoriteNotes.length,
              itemBuilder: (context, index) {
                final note = favoriteNotes[index];
                return NoteCard(
                  note: note,
                  // Tapping a favorite note will navigate to its detail page.
                  onTap: () => _viewNote(note),
                  // For simplicity, we are not providing edit, delete, or toggle favorite
                  // functionality directly from the FavoritesPage.
                  // If you need this, you would need to pass callbacks from HomePage
                  // that can modify the original notes list and save to SharedPreferences.
                  onEdit: () {
                    // Optionally, show a message or disable the button visually
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit catatan dari halaman utama.'),
                      ),
                    );
                  },
                  onDelete: () {
                    // Optionally, show a message or disable the button visually
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hapus catatan dari halaman utama.'),
                      ),
                    );
                  },
                  onToggleFavorite: () {
                    // Optionally, show a message or disable the button visually
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ubah status favorit dari halaman utama.',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
