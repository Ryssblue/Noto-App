import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal dan waktu

class SyncBackupPage extends StatefulWidget {
  const SyncBackupPage({super.key});

  @override
  State<SyncBackupPage> createState() => _SyncBackupPageState();
}

class _SyncBackupPageState extends State<SyncBackupPage> {
  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadLastSyncTime();
  }

  // Memuat waktu sinkronisasi terakhir dari SharedPreferences
  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastSyncTimeString = prefs.getString('lastSyncTime');
    if (lastSyncTimeString != null) {
      setState(() {
        _lastSyncTime = DateTime.parse(lastSyncTimeString);
      });
    }
  }

  // Mensimulasikan proses sinkronisasi
  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    // TODO: Implementasi logika sinkronisasi data yang sebenarnya di sini.
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('lastSyncTime', now.toIso8601String());

    setState(() {
      _lastSyncTime = now;
      _isSyncing = false;
    });

    // Tampilkan pesan sukses
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sinkronisasi selesai!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);

    // Define colors based on the theme
    final textColor = theme.textTheme.bodyLarge?.color;
    final subtitleColor = theme.textTheme.bodyMedium?.color;
    final iconColor = theme.iconTheme.color;
    final buttonColor = theme.elevatedButtonTheme.style?.backgroundColor
        ?.resolve({});
    final buttonTextColor = theme.elevatedButtonTheme.style?.foregroundColor
        ?.resolve({});
    final switchActiveColor = theme.colorScheme.primary; // For active switch
    final switchInactiveThumbColor = theme.colorScheme.onSurface.withOpacity(
      0.6,
    ); // For inactive switch thumb
    final switchInactiveTrackColor = theme.colorScheme.surface.withOpacity(
      0.5,
    ); // For inactive switch track

    return Scaffold(
      backgroundColor: theme
          .scaffoldBackgroundColor, // Ensure Scaffold background follows theme
      appBar: AppBar(
        title: Text(
          'Sinkronisasi & Cadangan',
          style: theme
              .appBarTheme
              .titleTextStyle, // Use titleTextStyle from AppBarTheme
        ),
        backgroundColor: theme
            .appBarTheme
            .backgroundColor, // Ensure AppBar background follows theme
        foregroundColor: theme
            .appBarTheme
            .foregroundColor, // Ensure AppBar icons/text follow theme
        elevation: theme.appBarTheme.elevation,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.history,
                color: iconColor,
              ), // Apply theme icon color
              title: Text(
                'Waktu Sinkronisasi Terakhir',
                style: TextStyle(color: textColor),
              ), // Apply theme text color
              subtitle: Text(
                _lastSyncTime == null
                    ? 'Belum pernah disinkronkan'
                    : 'Terakhir: ${DateFormat('dd MMMM yyyy, HH:mm').format(_lastSyncTime!)}',
                style: TextStyle(
                  color: subtitleColor,
                ), // Apply theme subtitle color
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _performSync,
                icon: _isSyncing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            buttonTextColor ?? Colors.white,
                          ), // Progress indicator color
                        ),
                      )
                    : Icon(
                        Icons.sync,
                        color: buttonTextColor,
                      ), // Icon color for button
                label: Text(
                  _isSyncing ? 'Mensinkronkan...' : 'Sinkronkan Sekarang',
                  style: TextStyle(
                    color: buttonTextColor,
                  ), // Text color for button
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      buttonColor, // Button background color from theme
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Pengaturan Cadangan Otomatis (TODO):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ), // Apply theme text color
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.cloud_upload,
                color: iconColor,
              ), // Apply theme icon color
              title: Text(
                'Cadangan Otomatis ke Cloud',
                style: TextStyle(color: textColor),
              ), // Apply theme text color
              trailing: Switch(
                value: false, // TODO: Ganti dengan nilai dari SharedPreferences
                onChanged: (bool value) {
                  // TODO: Implementasi logika untuk mengaktifkan/menonaktifkan cadangan otomatis
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur cadangan otomatis akan datang!'),
                    ),
                  );
                },
                activeColor: switchActiveColor, // Active color for the switch
                inactiveThumbColor:
                    switchInactiveThumbColor, // Thumb color when inactive
                inactiveTrackColor:
                    switchInactiveTrackColor, // Track color when inactive
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.timer,
                color: iconColor,
              ), // Apply theme icon color
              title: Text(
                'Frekuensi Cadangan',
                style: TextStyle(color: textColor),
              ), // Apply theme text color
              subtitle: Text(
                'Setiap hari',
                style: TextStyle(color: subtitleColor),
              ), // Apply theme subtitle color
              onTap: () {
                // TODO: Implementasi dialog untuk memilih frekuensi cadangan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan frekuensi cadangan akan datang!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
