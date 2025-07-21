import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashSettingsPage extends StatefulWidget {
  const TrashSettingsPage({super.key});

  @override
  State<TrashSettingsPage> createState() => _TrashSettingsPageState();
}

class _TrashSettingsPageState extends State<TrashSettingsPage> {
  int _retentionDays = 30; // Default: 30 hari
  final String _trashRetentionKey = 'trashRetentionDays';

  @override
  void initState() {
    super.initState();
    _loadRetentionSetting();
  }

  // Memuat pengaturan retensi dari SharedPreferences
  Future<void> _loadRetentionSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _retentionDays = prefs.getInt(_trashRetentionKey) ?? 30;
    });
  }

  // Menyimpan pengaturan retensi ke SharedPreferences
  Future<void> _saveRetentionSetting(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trashRetentionKey, days);
    setState(() {
      _retentionDays = days;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Catatan di sampah akan dihapus setelah $_retentionDays hari.',
          ),
        ),
      );
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
    final dividerColor = theme.dividerColor;
    final radioActiveColor =
        theme.colorScheme.primary; // Color for active RadioListTile dot
    final unselectedRadioColor = theme
        .unselectedWidgetColor; // Color for unselected RadioListTile circle

    return Scaffold(
      backgroundColor: theme
          .scaffoldBackgroundColor, // Ensure Scaffold background follows theme
      appBar: AppBar(
        title: Text(
          'Pengaturan Sampah',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(
              'Hapus Otomatis Catatan Lama',
              style: TextStyle(color: textColor),
            ), // Apply theme text color
            subtitle: Text(
              'Catatan di sampah akan dihapus setelah jangka waktu tertentu.',
              style: TextStyle(color: subtitleColor),
            ), // Apply theme subtitle color
          ),
          // RadioListTiles for retention days
          _buildRadioListTile(
            context,
            '7 Hari',
            7,
            _retentionDays,
            _saveRetentionSetting,
            textColor,
            radioActiveColor,
            unselectedRadioColor,
          ),
          _buildRadioListTile(
            context,
            '30 Hari (Default)',
            30,
            _retentionDays,
            _saveRetentionSetting,
            textColor,
            radioActiveColor,
            unselectedRadioColor,
          ),
          _buildRadioListTile(
            context,
            '60 Hari',
            60,
            _retentionDays,
            _saveRetentionSetting,
            textColor,
            radioActiveColor,
            unselectedRadioColor,
          ),
          _buildRadioListTile(
            context,
            'Jangan Pernah Hapus Otomatis',
            0,
            _retentionDays,
            _saveRetentionSetting,
            textColor,
            radioActiveColor,
            unselectedRadioColor,
          ),
          Divider(color: dividerColor), // Apply theme divider color
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: iconColor,
            ), // Apply theme icon color
            title: Text(
              'Kosongkan Sampah Sekarang',
              style: TextStyle(color: textColor),
            ), // Apply theme text color
            subtitle: Text(
              'Hapus semua catatan di sampah secara permanen.',
              style: TextStyle(color: subtitleColor),
            ), // Apply theme subtitle color
            onTap: () {
              _showConfirmEmptyTrashDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to build RadioListTile with theme colors
  Widget _buildRadioListTile(
    BuildContext context,
    String title,
    int value,
    int groupValue,
    Function(int) onChanged,
    Color? textColor,
    Color? activeColor,
    Color? unselectedColor,
  ) {
    return RadioListTile<int>(
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ), // Text color follows theme
      value: value,
      groupValue: groupValue,
      onChanged: (int? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      activeColor: activeColor, // Active dot color follows theme
      fillColor: MaterialStateProperty.resolveWith<Color?>((
        Set<MaterialState> states,
      ) {
        if (states.contains(MaterialState.selected)) {
          return activeColor; // Color when selected
        }
        return unselectedColor; // Color when not selected
      }),
    );
  }

  // Dialog konfirmasi untuk mengosongkan sampah
  void _showConfirmEmptyTrashDialog(BuildContext context) {
    final theme = Theme.of(context);
    final dialogBackgroundColor = theme.cardColor;
    final dialogTitleColor = theme.textTheme.titleMedium?.color;
    final dialogContentColor = theme.textTheme.bodyMedium?.color;
    final dialogButtonColor = theme.textButtonTheme.style?.foregroundColor
        ?.resolve({});

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor:
              dialogBackgroundColor, // Dialog background follows theme
          title: Text(
            'Kosongkan Sampah?',
            style: TextStyle(
              color: dialogTitleColor,
            ), // Title text follows theme
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus semua catatan di sampah secara permanen? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              color: dialogContentColor,
            ), // Content text follows theme
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  color: dialogButtonColor,
                ), // Button text follows theme
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              // Changed ElevatedButton to TextButton for consistency with theme
              child: const Text(
                'Hapus Permanen',
                style: TextStyle(
                  color: Colors.red,
                ), // Keep red for emphasis on delete
              ),
              onPressed: () {
                // TODO: Implementasi logika untuk menghapus semua catatan di sampah
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sampah dikosongkan (fungsionalitas TODO)!'),
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
