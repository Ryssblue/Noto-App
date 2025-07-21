import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kunci untuk menyimpan preferensi tema di SharedPreferences
const String _themeModeKey = 'themeMode';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default ke sistem

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode(); // Muat preferensi tema saat inisialisasi
  }

  // Memuat preferensi tema dari SharedPreferences
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final int? themeIndex = prefs.getInt(_themeModeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    notifyListeners(); // Beri tahu pendengar setelah tema dimuat
  }

  // Mengatur tema baru dan menyimpannya
  void setThemeMode(ThemeMode newThemeMode) async {
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, newThemeMode.index);
      notifyListeners(); // Beri tahu pendengar tentang perubahan
    }
  }
}
