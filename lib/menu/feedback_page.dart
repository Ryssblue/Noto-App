import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Enum untuk kategori feedback (tanpa perubahan)
enum FeedbackCategory { bug, feature, suggestion, praise }

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  FeedbackCategory? _selectedCategory;
  final _formKey = GlobalKey<FormState>();

  // Controllers (tanpa perubahan)
  final _bugController = TextEditingController();
  final _featureIdeaController = TextEditingController();
  final _featureReasonController = TextEditingController();
  final _generalFeedbackController = TextEditingController();
  final _emailController = TextEditingController();

  XFile? _attachment;
  bool _isSending = false;

  void _selectCategory(FeedbackCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _attachFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _attachment = image;
    });
  }

  // == FUNGSI PENGIRIMAN FEEDBACK (VERSI SIMULASI/PALSU) ==
  Future<void> _sendFeedback() async {
    if (_selectedCategory == null) {
      _showErrorDialog('Silakan pilih kategori masukan terlebih dahulu.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      // Simulasi jeda waktu seolah-olah sedang mengirim data ke server
      await Future.delayed(const Duration(seconds: 2));

      // Setelah jeda selesai, pastikan halaman masih ada
      if (mounted) {
        // Hentikan loading dan tampilkan dialog sukses
        setState(() {
          _isSending = false;
        });
        _showConfirmationDialog();
      }
    }
  }

  // Sisa kode di bawah ini sama persis dengan sebelumnya.
  // Tidak ada perubahan pada UI atau widget lainnya.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beri Kami Masukan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kami sangat menghargai pendapat Anda untuk membuat Note.app menjadi lebih baik.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text('1. Pilih Kategori Masukan Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildCategorySelection(),
              const SizedBox(height: 24),
              if (_selectedCategory != null) ...[
                const Text('2. Detail Masukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildDynamicFormFields(),
                const SizedBox(height: 24),
              ],
              const Text('3. Informasi Kontak (Opsional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Anda (Opsional)',
                  border: OutlineInputBorder(),
                  helperText: 'Kami mungkin akan menghubungi Anda jika memerlukan detail lebih lanjut.',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              if (_isSending)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  onPressed: _sendFeedback,
                  icon: const Icon(Icons.send),
                  label: const Text('Kirim Masukan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'Dengan mengirim, data diagnostik seperti versi aplikasi dan model perangkat akan disertakan secara otomatis.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: [
        _CategoryButton(
          label: 'Laporkan Bug',
          emoji: '🐞',
          description: 'Ada sesuatu yang tidak berfungsi.',
          isSelected: _selectedCategory == FeedbackCategory.bug,
          onTap: () => _selectCategory(FeedbackCategory.bug),
        ),
        _CategoryButton(
          label: 'Minta Fitur Baru',
          emoji: '💡',
          description: 'Punya ide cemerlang untuk kami?',
          isSelected: _selectedCategory == FeedbackCategory.feature,
          onTap: () => _selectCategory(FeedbackCategory.feature),
        ),
        _CategoryButton(
          label: 'Saran Perbaikan',
          emoji: '🤔',
          description: 'Ada yang bisa dibuat lebih baik?',
          isSelected: _selectedCategory == FeedbackCategory.suggestion,
          onTap: () => _selectCategory(FeedbackCategory.suggestion),
        ),
        _CategoryButton(
          label: 'Berikan Pujian',
          emoji: '❤️',
          description: 'Suka dengan aplikasi kami?',
          isSelected: _selectedCategory == FeedbackCategory.praise,
          onTap: () => _selectCategory(FeedbackCategory.praise),
        ),
      ],
    );
  }

  Widget _buildDynamicFormFields() {
    switch (_selectedCategory!) {
      case FeedbackCategory.bug:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _bugController,
              decoration: const InputDecoration(
                labelText: 'Jelaskan Bug yang Anda Temukan',
                hintText: 'Contoh: Saat saya mencoba membagikan catatan, aplikasi langsung tertutup.',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) => value!.isEmpty ? 'Deskripsi bug tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _attachFile,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(_attachment == null ? 'Lampirkan Screenshot' : 'Ganti Screenshot'),
            ),
            if (_attachment != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('File terlampir: ${_attachment!.name}', style: const TextStyle(color: Colors.green)),
              ),
          ],
        );
      case FeedbackCategory.feature:
        return Column(
          children: [
            TextFormField(
              controller: _featureIdeaController,
              decoration: const InputDecoration(
                labelText: 'Jelaskan Ide Fitur Anda',
                hintText: 'Contoh: Fitur untuk mengunci catatan dengan sidik jari.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Ide fitur tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _featureReasonController,
              decoration: const InputDecoration(
                labelText: 'Mengapa Fitur Ini Penting Bagi Anda?',
                hintText: 'Contoh: Untuk membantu saya menyimpan informasi sensitif.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Alasan tidak boleh kosong' : null,
            ),
          ],
        );
      case FeedbackCategory.suggestion:
      case FeedbackCategory.praise:
        return TextFormField(
          controller: _generalFeedbackController,
          decoration: const InputDecoration(
            labelText: 'Tulis Masukan Anda di Sini',
            hintText: 'Bagikan pendapat Anda selengkap mungkin...',
            border: OutlineInputBorder(),
          ),
          maxLines: 6,
          validator: (value) => value!.isEmpty ? 'Masukan tidak boleh kosong' : null,
        );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Terima Kasih! 🎉'),
        content: const Text('Masukan Anda telah berhasil kami terima. Terima kasih telah membantu kami menjadi lebih baik.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final String emoji;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.emoji,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 160,
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}