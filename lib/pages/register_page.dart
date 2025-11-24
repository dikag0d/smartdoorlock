import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  // Tambahkan validasi sederhana sebelum registrasi
  Future<void> _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password harus diisi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register(
        _usernameController.text,
        _passwordController.text,
      );

      // Cek apakah ada pesan sukses atau error dari server
      final message = result['message'] ?? result['error'] ?? 'Registrasi berhasil. Silakan Login.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      if (result['message'] != null && result['message'].toLowerCase().contains('berhasil')) {
        Navigator.pop(context); // Kembali ke login jika berhasil
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal registrasi: $e')),
      );
    }

    setState(() => _isLoading = false);
  }
  
  // --- Widget Kustom untuk Text Field Modern (Diambil dari LoginPage) ---
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
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Icon & Title
              Icon(
                Icons.person_add_alt_1_rounded,
                size: 70, 
                color: _accentColor,
              ),
              const SizedBox(height: 15),
              const Text(
                'Pendaftaran Pengguna',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Silakan isi detail akun yang akan digunakan.',
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
                icon: Icons.vpn_key_outlined,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // 3. Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
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
                        'DAFTAR SEKARANG',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),

              const SizedBox(height: 20),
              
              // 4. Kembali ke Login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Sudah punya akun? Kembali ke Login",
                  style: TextStyle(
                    color: Colors.grey.shade600,
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