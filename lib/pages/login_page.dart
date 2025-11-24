import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final _accentColor = const Color(0xFF7CAFA4);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password harus diisi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (result['token'] != null) {
        // Jika sukses → pindah ke Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(username: _usernameController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Login gagal. Cek kredensial Anda.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan koneksi. ($e)')),
      );
    }

    setState(() => _isLoading = false);
  }

  // --- Widget Kustom untuk Text Field Modern ---
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          // Hapus semua border default untuk tampilan yang lebih bersih
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
  // ---------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Background sangat terang
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Icon & Title
              Icon(
                Icons.security_rounded, // Icon yang lebih modern
                size: 80, 
                color: _accentColor,
              ),
              const SizedBox(height: 10),
              const Text(
                'Smart Door System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800, // Tebal dan jelas
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Masuk untuk memantau aktivitas pintu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // 2. Input Fields
              _buildModernTextField(
                controller: _usernameController,
                labelText: 'Username',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // 3. Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55), // Lebih tinggi
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Sudut lebih besar
                  ),
                  elevation: 5, // Tambahkan sedikit shadow pada tombol
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'MASUK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),

              const SizedBox(height: 20),
              
              // 4. Register Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: Text(
                  "Belum punya akun? Daftar di sini",
                  style: TextStyle(
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}