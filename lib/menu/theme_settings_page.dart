import 'package:flutter/material.dart';
import 'package:noto_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan ThemeProvider dari konteks
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Dapatkan ThemeData dari konteks saat ini
    final theme = Theme.of(context);

    // Ambil warna dari tema untuk konsistensi
    final textColor = theme.textTheme.bodyLarge?.color;
    final subtitleColor = theme.textTheme.bodyMedium?.color;
    final iconColor = theme.iconTheme.color;
    final dividerColor = theme.dividerColor;
    final radioActiveColor =
        theme.colorScheme.primary; // Warna untuk RadioListTile yang aktif

    return Scaffold(
      backgroundColor: theme
          .scaffoldBackgroundColor, // Background Scaffold menyesuaikan tema
      appBar: AppBar(
        title: Text(
          'Pengaturan Tema',
          style: theme
              .appBarTheme
              .titleTextStyle, // Judul AppBar menyesuaikan tema
        ),
        backgroundColor: theme
            .appBarTheme
            .backgroundColor, // Background AppBar menyesuaikan tema
        foregroundColor: theme
            .appBarTheme
            .foregroundColor, // Warna ikon/teks AppBar menyesuaikan tema
        elevation: theme.appBarTheme.elevation,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // RadioListTile untuk Mode Tema
          _buildThemeModeOption(
            context,
            'Mode Terang',
            ThemeMode.light,
            themeProvider,
            textColor,
            radioActiveColor,
          ),
          _buildThemeModeOption(
            context,
            'Mode Gelap',
            ThemeMode.dark,
            themeProvider,
            textColor,
            radioActiveColor,
          ),
          _buildThemeModeOption(
            context,
            'Ikuti Sistem',
            ThemeMode.system,
            themeProvider,
            textColor,
            radioActiveColor,
          ),
          Divider(color: dividerColor), // Divider menyesuaikan tema
          // TODO: Implementasi pilihan warna aksen
          ListTile(
            leading: Icon(
              Icons.color_lens,
              color: iconColor,
            ), // Ikon menyesuaikan tema
            title: Text(
              'Warna Aksen',
              style: TextStyle(color: textColor),
            ), // Teks menyesuaikan tema
            subtitle: Text(
              'Pilih warna aksen aplikasi Anda',
              style: TextStyle(color: subtitleColor),
            ), // Subtitle menyesuaikan tema
            trailing: CircleAvatar(
              backgroundColor: theme
                  .primaryColor, // Tampilkan warna aksen saat ini dari tema
              radius: 16,
            ),
            onTap: () {
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
    Color? textColor, // Tambahkan parameter warna teks
    Color? activeColor, // Tambahkan parameter warna aktif Radio
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ), // Teks judul RadioListTile menyesuaikan tema
      value: mode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? newMode) {
        if (newMode != null) {
          themeProvider.setThemeMode(newMode);
        }
      },
      activeColor: activeColor, // Warna dot Radio yang aktif
    );
  }

  // Fungsi untuk menampilkan dialog pemilihan warna
  void _showColorPickerDialog(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final theme = Theme.of(context); // Dapatkan tema untuk dialog
    final dialogTitleColor = theme.textTheme.titleMedium?.color;
    final dialogContentColor = theme.textTheme.bodyMedium?.color;
    final dialogButtonColor = theme.textButtonTheme.style?.foregroundColor
        ?.resolve({});

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Gunakan dialogContext
        return AlertDialog(
          backgroundColor:
              theme.cardColor, // Background AlertDialog menyesuaikan tema
          title: Text(
            'Pilih Warna Aksen',
            style: TextStyle(color: dialogTitleColor),
          ), // Judul dialog menyesuaikan tema
          content: Text(
            'Fungsionalitas pemilihan warna aksen akan datang!',
            style: TextStyle(color: dialogContentColor),
          ), // Konten dialog menyesuaikan tema
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tutup',
                style: TextStyle(color: dialogButtonColor),
              ), // Teks tombol menyesuaikan tema
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Gunakan dialogContext
              },
            ),
          ],
        );
      },
    );
  }
}
