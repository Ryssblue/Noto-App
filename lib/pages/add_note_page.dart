import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:path/path.dart' as p; // Import path for joining paths

import '../models/note_model.dart';

class AddNotePage extends StatefulWidget {
  final void Function(NoteModel) onSave;

  const AddNotePage({required this.onSave, super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker(); // Inisialisasi ImagePicker

  File? _selectedImage; // Menyimpan file gambar yang dipilih

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      // Simpan gambar ke direktori aplikasi
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(pickedFile.path);
      final File localImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');

      setState(() {
        _selectedImage = localImage;
      });
    }
  }

  // Fungsi untuk menghapus gambar yang dipilih
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final newNote = NoteModel(
        id: _uuid.v4(),
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        createdAt: DateTime.now(),
        isFavorite: false,
        isArchived: false,
        imagePath: _selectedImage?.path, // Simpan path gambar ke model
      );
      widget.onSave(newNote);
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        print(
          'No route to pop, staying on AddNotePage or navigating manually.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ambil warna tema untuk TextField
    final inputFillColor = theme.inputDecorationTheme.fillColor;
    final hintStyleColor = theme.hintColor;
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
          "Tambah Catatan",
          style: theme.appBarTheme.titleTextStyle,
        ), // Menyesuaikan tema
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor, // Menyesuaikan tema
        foregroundColor: theme.appBarTheme.foregroundColor, // Menyesuaikan tema
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
                  hintText: 'Judul catatan...',
                  filled: true,
                  fillColor: inputFillColor, // Menggunakan warna tema
                  hintStyle: TextStyle(
                    color: hintStyleColor,
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
              // Area untuk menampilkan gambar yang dipilih
              _selectedImage != null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
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
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.5,
                            ), // Warna border menyesuaikan tema
                          ),
                          foregroundColor: theme
                              .textTheme
                              .bodyMedium
                              ?.color, // Warna teks/ikon menyesuaikan tema
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
                    hintText: 'Tulis isi catatan...',
                    filled: true,
                    fillColor: inputFillColor, // Menggunakan warna tema
                    hintStyle: TextStyle(
                      color: hintStyleColor,
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
                  icon: Icon(
                    Icons.check,
                    color: elevatedButtonFgColor,
                  ), // Warna ikon menyesuaikan tema
                  label: Text(
                    'Simpan Catatan',
                    style: TextStyle(color: elevatedButtonFgColor),
                  ), // Warna teks menyesuaikan tema
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        elevatedButtonBgColor, // Warna background tombol menyesuaikan tema
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
