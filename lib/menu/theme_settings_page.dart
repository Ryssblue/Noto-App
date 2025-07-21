import 'package:flutter/material.dart';
import 'package:noto_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan ThemeProvider dari konteks
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Tema'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildThemeModeOption(
            context,
            'Mode Terang',
            ThemeMode.light,
            themeProvider,
          ),
          _buildThemeModeOption(
            context,
            'Mode Gelap',
            ThemeMode.dark,
            themeProvider,
          ),
          _buildThemeModeOption(
            context,
            'Ikuti Sistem',
            ThemeMode.system,
            themeProvider,
          ),
          const Divider(),
          // TODO: Implementasi pilihan warna aksen
          // Ini akan menjadi sedikit lebih kompleks karena Anda perlu menyimpan warna
          // dan menerapkannya ke ThemeData. Anda bisa menggunakan ColorPicker
          // atau daftar warna prasetel.
          ListTile(
            title: const Text('Warna Aksen'),
            subtitle: const Text('Pilih warna aksen aplikasi Anda'),
            trailing: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor, // Tampilkan warna aksen saat ini
              radius: 16,
            ),
            onTap: () {
              // Contoh: Menampilkan dialog pemilihan warna
              // Anda perlu mengimplementasikan dialog ini dan logika penyimpanannya
              _showColorPickerDialog(context, themeProvider);
            },
          ),
        ],
      ),
    );
  }

  // Widget pembangun untuk opsi mode tema
  Widget _buildThemeModeOption(
    BuildContext context,
    String title,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: mode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? newMode) {
        if (newMode != null) {
          themeProvider.setThemeMode(newMode);
        }
      },
    );
  }

  // Contoh fungsi untuk menampilkan dialog pemilihan warna
  void _showColorPickerDialog(BuildContext context, ThemeProvider themeProvider) {
    // Ini adalah placeholder. Anda perlu mengimplementasikan dialog pemilihan warna
    // yang sebenarnya dan logika untuk menyimpan dan menerapkan warna aksen.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Warna Aksen'),
          content: const Text('Fungsionalitas pemilihan warna aksen akan datang!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
