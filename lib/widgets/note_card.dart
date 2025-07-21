// widgets/note_card.dart
import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onArchive;
  final IconData? editIcon;
  final IconData? deleteIcon;

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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final hintColor = theme.hintColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.star : Icons.star_border,
                      color: note.isFavorite ? Colors.amber : hintColor,
                    ),
                    onPressed: onToggleFavorite,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: theme.cardColor,
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
                              Icon(currentEditIcon, color: textColor),
                              const SizedBox(width: 8),
                              Text(
                                editText,
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(currentDeleteIcon, color: textColor),
                              const SizedBox(width: 8),
                              Text(
                                deleteText,
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                        ),
                        if (onArchive != null && !note.isArchived)
                          PopupMenuItem<String>(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Icons.archive_outlined, color: textColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Arsipkan',
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // --- BAGIAN BARU: Tampilkan Gambar jika ada ---
              if (note.imagePath != null && note.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                  ), // Spasi di bawah gambar
                  child: ClipRRect(
                    // Untuk sudut melengkung pada gambar
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Sudut lebih kecil dari Card
                    child: Image.file(
                      File(note.imagePath!), // Menggunakan File dari dart:io
                      height: 120, // Tinggi pratinjau gambar
                      width: double.infinity, // Lebar penuh kartu
                      fit: BoxFit
                          .cover, // Gambar akan mengisi area tanpa distorsi
                      errorBuilder: (context, error, stackTrace) {
                        // Penanganan error jika gambar tidak dapat dimuat
                        return Container(
                          height: 120,
                          color: theme
                              .colorScheme
                              .errorContainer, // Warna error container dari tema
                          alignment: Alignment.center,
                          child: Text(
                            'Gagal memuat gambar',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // --- AKHIR BAGIAN BARU ---
              Text(
                note.content,
                style: TextStyle(fontSize: 14, color: textColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('dd MMM yyyy').format(note.createdAt),
                  style: TextStyle(fontSize: 12, color: hintColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
