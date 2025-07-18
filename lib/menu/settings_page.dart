import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tampilan & Tema'),
            onTap: () { /* TODO: Buka halaman pengaturan tema */ },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Sinkronisasi & Backup'),
            subtitle: const Text('Terakhir sinkronisasi: 5 menit lalu'),
            onTap: () { /* TODO: Buka halaman status sinkronisasi */ },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Pengaturan Sampah'),
            subtitle: Text('Hapus otomatis setelah 30 hari'),
            onTap: () { /* TODO: Buka dialog untuk ubah retensi */ },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Ekspor Data'),
            onTap: () { /* TODO: Implementasi logika ekspor */ },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Impor Data'),
            onTap: () { /* TODO: Implementasi logika impor */ },
          ),
          const Divider(),
           ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            onTap: () { /* TODO: Buka halaman 'Tentang' */ },
          ),
        ],
      ),
    );
  }
}