import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OtpPage extends StatefulWidget {
  final Map<String, dynamic> registerData;
  const OtpPage({super.key, required this.registerData});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String otp = '';
  bool isVerifyingOtp = false;

  Future<void> _registerWithOtp() async {
    setState(() => isVerifyingOtp = true);
    final response = await http.post(
      Uri.parse('https://752436e70945.ngrok-free.app/auth/register-with-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...widget.registerData, 'otp': otp}),
    );
    setState(() => isVerifyingOtp = false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ສະໝັກສະມາຊິກສຳເລັດ!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ຢືນຢັນ OTP ບໍ່ສຳເລັດ: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Colors.teal;
    const accent = Color(0xFFFFFFFF);
    const Color text = Color(0xFF000000);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ຢືນຢັນ OTP'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('ກະລຸນາປ້ອນ OTP ທີ່ສົ່ງໄປຫາເບີໂທຂອງທ່ານ'),
                  const SizedBox(height: 24),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      prefixIcon: Icon(Icons.sms, color: primary),
                      filled: true,
                      fillColor: accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary),
                      ),
                    ),
                    style: TextStyle(color: text),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => otp = val,
                  ),
                  const SizedBox(height: 24),
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
                      child: isVerifyingOtp
                          ? const SpinKitWaveSpinner(
                              color: Colors.white,
                              size: 40,
                              waveColor: Color(0xFFB2DFDB),
                            )
                          : const Text(
                              'ຢືນຢັນ OTP ແລະ ສະໝັກສະມາຊິກ',
                              style: TextStyle(fontSize: 18),
                            ),
                      onPressed: isVerifyingOtp
                          ? null
                          : () {
                              if (otp.isNotEmpty) {
                                _registerWithOtp();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isVerifyingOtp)
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
}
