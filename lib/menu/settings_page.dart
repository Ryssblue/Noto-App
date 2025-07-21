import 'package:flutter/material.dart';
import 'package:noto_app/menu/theme_settings_page.dart';
import 'package:noto_app/menu/sync_backup_page.dart';
import 'package:noto_app/menu/trash_settings_page.dart';
import 'package:noto_app/menu/export_data_page.dart';
import 'package:noto_app/menu/import_data_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final subtitleColor = theme.textTheme.bodyMedium?.color;
    final iconColor = theme.iconTheme.color;
    final dividerColor = theme.dividerColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pengaturan', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.palette, color: iconColor),
            title: Text('Tampilan & Tema', style: TextStyle(color: textColor)),
            subtitle: Text(
              'Ubah mode terang/gelap dan warna aksen',
              style: TextStyle(color: subtitleColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsPage(),
                ),
              );
            },
          ),
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.sync, color: iconColor),
            title: Text(
              'Sinkronisasi & Cadangan',
              style: TextStyle(color: textColor),
            ),
            subtitle: Text(
              'Kelola sinkronisasi data dan cadangan cloud',
              style: TextStyle(color: subtitleColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SyncBackupPage()),
              );
            },
          ),
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.delete_sweep, color: iconColor),
            title: Text(
              'Pengaturan Sampah',
              style: TextStyle(color: textColor),
            ),
            subtitle: Text(
              'Konfigurasi retensi catatan yang dihapus',
              style: TextStyle(color: subtitleColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrashSettingsPage(),
                ),
              );
            },
          ),
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.file_upload, color: iconColor),
            title: Text('Ekspor Data', style: TextStyle(color: textColor)),
            subtitle: Text(
              'Ekspor catatan Anda ke berkas',
              style: TextStyle(color: subtitleColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportDataPage()),
              );
            },
          ),
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.file_download, color: iconColor),
            title: Text('Impor Data', style: TextStyle(color: textColor)),
            subtitle: Text(
              'Impor catatan dari berkas',
              style: TextStyle(color: subtitleColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImportDataPage()),
              );
            },
          ),
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: Text('Tentang Aplikasi', style: TextStyle(color: textColor)),
            subtitle: Text(
              'Informasi versi dan pengembang',
              style: TextStyle(color: subtitleColor),
            ),
            onTap: () {
              _showAboutAppDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    final theme = Theme.of(context);
    final dialogBackgroundColor = theme.cardColor;
    final dialogTitleColor = theme.textTheme.titleMedium?.color;
    final dialogContentColor = theme.textTheme.bodyMedium?.color;
    final dialogButtonColor = theme.textButtonTheme.style?.foregroundColor
        ?.resolve({});

    // Use showDialog to customize the AlertDialog properties directly
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Directly set background color
          backgroundColor: dialogBackgroundColor,
          // Set the title
          title: Text(
            'Tentang Aplikasi Noto', // More specific title for AboutDialog
            style: TextStyle(color: dialogTitleColor),
          ),
          // Set the content
          content: SingleChildScrollView(
            // Use SingleChildScrollView if content might overflow
            child: ListBody(
              children: <Widget>[
                // Optional: Add an application icon at the top of the content
                Center(
                  child: Icon(
                    Icons.info,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aplikasi catatan sederhana untuk membantu Anda mengatur pikiran.',
                  style: TextStyle(color: dialogContentColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Versi: 1.0.0', // Directly show version here if needed
                  style: TextStyle(fontSize: 12.0, color: dialogContentColor),
                ),
                Text(
                  '© 2025 Noto App. All rights reserved.',
                  style: TextStyle(fontSize: 12.0, color: dialogContentColor),
                ),
                Text(
                  'Dikembangkan oleh: DPM Barokah',
                  style: TextStyle(fontSize: 12.0, color: dialogContentColor),
                ),
              ],
            ),
          ),
          // Set actions (buttons)
          actions: <Widget>[
            TextButton(
              child: Text('Tutup', style: TextStyle(color: dialogButtonColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
