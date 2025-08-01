import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main_screen.dart';
import 'register_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(
      {super.key}); // ເພີ່ມ super.key ເພື່ອໃຫ້ເປັນໄປຕາມຫຼັກປະຕິບັດທີ່ດີ

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String emailOrName = '', password = '';
  bool isLoading = false;
  bool _obscureText = true; // State ສຳລັບການສະແດງ/ຊ່ອນລະຫັດຜ່ານ

  Future<void> _login() async {
    setState(() => isLoading = true);
    final isEmail = emailOrName.contains('@');
    final body = isEmail
        ? {'email': emailOrName, 'password': password}
        : {'name': emailOrName, 'password': password};

    try {
      final response = await http.post(
        Uri.parse('https://0eb58792378e.ngrok-free.app/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('Login API response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final token = data['token'];
        if (user == null || token == null) {
          throw Exception('Invalid data from server');
        }
        // --- เพิ่มส่วนนี้เพื่อ save token ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        // --- จบส่วนที่เพิ่ม ---

        final name = user['name'] ?? 'ຜູ້ໃຊ້';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ຍິນດີຕ້ອນຮັບ $name')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              userData: user,
              token: token,
            ),
          ),
        );
      } else {
        final responseJson = jsonDecode(response.body);
        final message = responseJson['message'] ?? 'ເຂົ້າສູ່ລະບົບບໍ່ສຳເລັດ';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: $e')),
      );
    }
  }

  // ...existing code...
  @override
  Widget build(BuildContext context) {
    const Color primary = Colors.teal;
    const Color background = Colors.white;
    const Color text = Color(0xFF000000);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withOpacity(0.08),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Icon(Icons.cleaning_services,
                          size: 64, color: primary),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ເຂົ້າສູ່ລະບົບ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ອີເມລ ຫຼື ຊື່ຜູ້ໃຊ້',
                        prefixIcon: Icon(Icons.person, color: primary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: primary.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: primary, width: 2),
                        ),
                      ),
                      style: const TextStyle(color: text),
                      onChanged: (val) => emailOrName = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'ກະລຸນາປ້ອນອີເມລ ຫຼື ຊື່ຜູ້ໃຊ້'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ລະຫັດຜ່ານ',
                        prefixIcon: Icon(Icons.lock, color: primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: primary.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: primary, width: 2),
                        ),
                      ),
                      style: const TextStyle(color: text),
                      obscureText: _obscureText,
                      onChanged: (val) => password = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'ກະລຸນາປ້ອນລະຫັດຜ່ານ'
                          : null,
                      autofillHints: const [AutofillHints.password],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _login();
                                }
                              },
                        child: const Text('ເຂົ້າສູ່ລະບົບ',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ຍັງບໍ່ທັນມີບັນຊີ? ',
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            'ສະໝັກສະມາຊິກ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Overlay loading animation
          // filepath: c:\maid\maid_app\lib\screens\login_page.dart
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: SpinKitWaveSpinner(
                  color: Colors.teal,
                  size: 70,
                  waveColor: Color(0xFFB2DFDB),
                ),
              ),
            ),
        ],
      ),
    );
  }
// ...existing code...
}
