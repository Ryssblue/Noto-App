import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void _toggleForm() {
    setState(() => isLogin = !isLogin);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (isLogin) {
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');

      if (email == savedEmail && password == savedPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        _showSnackBar('Login gagal! Email atau password salah.');
      }
    } else {
      final confirmPassword = confirmPasswordController.text;

      if (name.isEmpty) {
        _showSnackBar('Nama tidak boleh kosong');
        return;
      }

      if (password != confirmPassword) {
        _showSnackBar('Password tidak cocok');
        return;
      }

      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);

      _showSnackBar('Registrasi berhasil! Silakan login.');
      setState(() => isLogin = true);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is active
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme.
    // Ensure these are always non-null Colors.
    final Color cardColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color hintColor = isDarkMode
        ? Colors
              .grey[400]! // Using ! because Colors.grey[shade] can return null. Here we assert it won't.
        : Colors.grey[700]!; // It's safer to use .shadeValue if you're sure.
    final Color borderColor = isDarkMode
        ? Colors.grey[600]!
        : Colors.grey; // Colors.grey is non-nullable.
    final Color iconColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Noto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Pass theme colors directly without null assertion operator (!)
                  _buildAuthCard(
                    isDarkMode,
                    cardColor,
                    textColor,
                    hintColor,
                    borderColor,
                    iconColor,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _toggleForm,
                    child: Text(
                      isLogin ? 'Daftar akun baru' : 'Sudah punya akun? Login',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color hintColor,
    Color borderColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.blue.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isLogin ? 'Selamat Datang Kembali!' : 'Buat Akun Baru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          if (!isLogin) ...[
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nama Lengkap',
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              style: TextStyle(color: textColor),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Nama tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(color: hintColor),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            style: TextStyle(color: textColor),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value.trim())) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: hintColor),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: iconColor,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
            style: TextStyle(color: textColor),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Password tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 16),
          if (!isLogin)
            TextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Konfirmasi Password',
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(
                      () => obscureConfirmPassword = !obscureConfirmPassword,
                    );
                  },
                ),
              ),
              style: TextStyle(color: textColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLogin ? 'Login' : 'Daftar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
