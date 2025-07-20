// widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onArchive; // Callback untuk aksi Arsipkan
  final IconData? editIcon; // Ikon kustom untuk aksi "Edit" (misal: unarchive)
  final IconData?
  deleteIcon; // Ikon kustom untuk aksi "Delete" (misal: delete_forever)

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    this.onArchive,
    this.editIcon,
    this.deleteIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12,
          ), // Padding utama kartu
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bagian Judul, Tombol Favorit, dan Menu Titik Tiga (semua dalam satu baris)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Pusatkan secara vertikal
                children: [
                  Expanded(
                    // Judul mengambil ruang yang tersedia
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Tombol Favorit
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.star : Icons.star_border,
                      color: note.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: onToggleFavorite,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ), // Ukuran ikon lebih ringkas
                  ),
                  // Menu Titik Tiga
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      } else if (value == 'archive') {
                        onArchive?.call();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      final String editText = editIcon == Icons.unarchive
                          ? 'Keluarkan dari Arsip'
                          : 'Edit';
                      final IconData currentEditIcon = editIcon ?? Icons.edit;

                      final String deleteText =
                          deleteIcon == Icons.delete_forever
                          ? 'Hapus Permanen'
                          : 'Hapus';
                      final IconData currentDeleteIcon =
                          deleteIcon ?? Icons.delete;

                      return <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(currentEditIcon),
                              const SizedBox(width: 8),
                              Text(editText),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(currentDeleteIcon),
                              const SizedBox(width: 8),
                              Text(deleteText),
                            ],
                          ),
                        ),
                        if (onArchive != null && !note.isArchived)
                          const PopupMenuItem<String>(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Icons.archive_outlined),
                                SizedBox(width: 8),
                                Text('Arsipkan'),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ), // Spasi antara baris judul/ikon dan konten
              // 2. Konten (tepat di bawah judul)
              Text(
                note.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4), // Spasi antara konten dan tanggal
              // 3. Tanggal (tetap di kanan bawah)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('dd MMM yyyy').format(note.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
