import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart';
import 'package:ecomart/models/user_model.dart'; // Pastikan path ke UserModel benar

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // State untuk form
  String _selectedGender = 'Laki-laki';
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validator functions
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    // Asumsi format nomor telepon yang lebih fleksibel
    final phoneRegex = RegExp(r'^[0-9]{10,14}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Nomor telepon minimal 10 digit dan maksimal 14 digit';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat harus diisi';
    }
    if (value.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui syarat dan ketentuan'),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Berhenti jika belum menyetujui
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Membuat UserModel (tanpa ID/isAdmin, akan diisi di AuthProvider)
      final userModelData = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        gender: _selectedGender,
        // PERBAIKAN: agreeToTerms harus disertakan karena merupakan required parameter
        agreeToTerms: _agreeToTerms,
        // ID dan isAdmin akan diisi/default di constructor atau AuthProvider
      );

      try {
        final success = await authProvider.register(
          userModelData, // Mengirim data user model lengkap
          _emailController.text, // Email untuk Firebase Auth
          _passwordController.text, // Password untuk Firebase Auth
        );

        if (success) {
          // Navigasi ke /wrapper untuk menentukan layar beranda yang tepat
          // dan menghapus semua rute sebelumnya
          Navigator.of(context).pushNamedAndRemoveUntil('/wrapper', (route) => false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registrasi berhasil! Selamat datang ${userModelData.name}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Jika gagal, tampilkan pesan error dari provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Registrasi gagal. Coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registrasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Ecomart'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Nama Lengkap
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        validator: _validateName,
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Masukkan email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        prefixIcon: Icons.email,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Masukkan password',
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        prefixIcon: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Konfirmasi Password
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Password',
                        hint: 'Masukkan ulang password',
                        obscureText: _obscureConfirmPassword,
                        validator: _validateConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nomor Telepon
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        hint: 'Masukkan nomor telepon',
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        prefixIcon: Icons.phone,
                      ),
                      const SizedBox(height: 16),

                      // Alamat
                      CustomTextField(
                        controller: _addressController,
                        label: 'Alamat',
                        hint: 'Masukkan alamat lengkap',
                        maxLines: 3,
                        validator: _validateAddress,
                        prefixIcon: Icons.home,
                      ),
                      const SizedBox(height: 16),

                      // Jenis Kelamin (Dropdown)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jenis Kelamin',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            items: ['Laki-laki', 'Perempuan']
                                .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Syarat dan Ketentuan (Checkbox)
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeToTerms = !_agreeToTerms;
                                });
                              },
                              child: const Text(
                                'Saya menyetujui syarat dan ketentuan yang berlaku',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun?'),
                          TextButton(
                            onPressed: () {
                              // Navigasi ke layar login
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text('Login di sini'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Loading overlay saat memproses
              if (authProvider.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}