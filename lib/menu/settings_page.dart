import 'package:flutter/material.dart';
import 'package:noto_app/menu/theme_settings_page.dart';
import 'package:noto_app/menu/sync_backup_page.dart'; // Import halaman sinkronisasi
import 'package:noto_app/menu/trash_settings_page.dart'; // Import halaman pengaturan sampah
import 'package:noto_app/menu/export_data_page.dart'; // Import halaman ekspor data
import 'package:noto_app/menu/import_data_page.dart'; // Import halaman impor data

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Tampilan & Tema'),
            subtitle: const Text('Ubah mode terang/gelap dan warna aksen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sinkronisasi & Cadangan'),
            subtitle: const Text('Kelola sinkronisasi data dan cadangan cloud'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncBackupPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Pengaturan Sampah'),
            subtitle: const Text('Konfigurasi retensi catatan yang dihapus'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrashSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Ekspor Data'),
            subtitle: const Text('Ekspor catatan Anda ke berkas'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportDataPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Impor Data'),
            subtitle: const Text('Impor catatan dari berkas'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImportDataPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Informasi versi dan pengembang'),
            onTap: () {
              _showAboutAppDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Fungsi pembantu untuk menampilkan dialog Tentang Aplikasi
  void _showAboutAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Noto App',
      applicationVersion: '1.0.0', // Ganti dengan versi aplikasi Anda
      applicationLegalese: '© 2024 Noto App. All rights reserved.',
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            'Aplikasi catatan sederhana untuk membantu Anda mengatur pikiran.',
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Dikembangkan oleh: Your Name/Team Name', // Ganti dengan nama Anda/tim Anda
            style: TextStyle(fontSize: 12.0),
          ),
        ),
      ],
    );
  }
}
