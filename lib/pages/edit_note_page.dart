import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:path/path.dart' as p; // Import path for joining paths

import '../models/note_model.dart';

class EditNotePage extends StatefulWidget {
  final NoteModel note; // Catatan yang akan diedit

  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final ImagePicker _picker = ImagePicker(); // Inisialisasi ImagePicker

  File? _selectedImage; // Menyimpan file gambar yang dipilih/diedit

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data catatan yang ada
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);

    // ⭐ Load existing image if available ⭐
    if (widget.note.imagePath != null && widget.note.imagePath!.isNotEmpty) {
      _selectedImage = File(widget.note.imagePath!);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  // ⭐ Fungsi untuk memilih/mengganti gambar ⭐
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(pickedFile.path);
      final File localImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');

      setState(() {
        // ⭐ Penting: Jika ada gambar lama, hapus file lamanya ⭐
        if (_selectedImage != null &&
            _selectedImage!.existsSync() &&
            _selectedImage!.path != localImage.path) {
          _selectedImage!.delete();
        }
        _selectedImage = localImage;
      });
    }
  }

  // ⭐ Fungsi untuk menghapus gambar yang dipilih/sudah ada ⭐
  void _removeImage() async {
    setState(() {
      // ⭐ Hapus file gambar dari penyimpanan lokal saat dihapus dari UI ⭐
      if (_selectedImage != null && _selectedImage!.existsSync()) {
        _selectedImage!.delete();
      }
      _selectedImage = null; // Setel ke null di UI
    });
  }

  void _saveNote() async {
    // Make _saveNote async because it will delete file
    if (_formKey.currentState!.validate()) {
      // ⭐ Perbarui properti catatan yang ada ⭐
      widget.note.title = titleController.text.trim();
      widget.note.content = contentController.text.trim();

      // ⭐ Tangani perubahan gambar ⭐
      if (widget.note.imagePath != _selectedImage?.path) {
        // Jika path gambar berubah (gambar baru dipilih atau gambar dihapus)
        // Note: Penghapusan file lama sudah dilakukan di _pickImage/_removeImage
        widget.note.imagePath = _selectedImage?.path;
      }

      // Kembalikan objek note yang sudah diperbarui
      // HomePage akan bertanggung jawab untuk menyimpan perubahan ini ke SharedPreferences
      Navigator.pop(context, widget.note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ambil warna tema untuk TextField
    final inputFillColor = theme.inputDecorationTheme.fillColor;
    final labelStyleColor =
        theme.textTheme.bodyMedium?.color; // labelStyle uses bodyMedium
    final textInputColor = theme.textTheme.bodyMedium?.color;
    final elevatedButtonBgColor = theme
        .elevatedButtonTheme
        .style
        ?.backgroundColor
        ?.resolve({});
    final elevatedButtonFgColor = theme
        .elevatedButtonTheme
        .style
        ?.foregroundColor
        ?.resolve({});

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Edit Catatan",
          style: theme.appBarTheme.titleTextStyle,
        ), // Menyesuaikan tema
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor, // Menyesuaikan tema
        foregroundColor: theme.appBarTheme.foregroundColor, // Menyesuaikan tema
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: theme.appBarTheme.foregroundColor,
            ), // Menyesuaikan tema
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  filled: true,
                  fillColor: inputFillColor, // Menggunakan warna tema
                  labelStyle: TextStyle(
                    color: labelStyleColor,
                  ), // Menggunakan warna tema
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  color: textInputColor,
                ), // Menggunakan warna tema
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // ⭐ Area untuk menampilkan/mengganti gambar ⭐
              _selectedImage != null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        // Display the selected/existing image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Button to remove the image
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor:
                                Colors.black54, // Keep this for contrast
                            radius: 16,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: _removeImage,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                        // Button to change the image (optional, could be done via a menu or long press)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Ganti Gambar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: elevatedButtonBgColor
                                  ?.withOpacity(
                                    0.8,
                                  ), // Muted for less prominence
                              foregroundColor: elevatedButtonFgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Tambah Gambar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          foregroundColor: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
              const SizedBox(
                height: 16,
              ), // Spasi setelah gambar/tombol tambah gambar
              Expanded(
                child: TextFormField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: 'Isi',
                    filled: true,
                    fillColor: inputFillColor, // Menggunakan warna tema
                    labelStyle: TextStyle(
                      color: labelStyleColor,
                    ), // Menggunakan warna tema
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(
                    color: textInputColor,
                  ), // Menggunakan warna tema
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Konten tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: Icon(Icons.check, color: elevatedButtonFgColor),
                  label: Text(
                    'Simpan Perubahan',
                    style: TextStyle(color: elevatedButtonFgColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: elevatedButtonBgColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
