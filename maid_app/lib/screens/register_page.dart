import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'otp_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:crop_your_image/crop_your_image.dart' as cyi;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', password = '';
  String village = '', city = '', province = '';
  String phone = '';
  int age = 0;
  bool isLoading = false;
  bool otpSent = false;
  String otp = '';
  bool isVerifyingOtp = false;
  String? _profileImageBase64;
  bool isUploadingImage = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // 1. เลือกรูปก่อน
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);

    if (!mounted || picked == null) return;

    setState(() => isUploadingImage = true); // เปิด overlay loading

    final originalBytes = await picked.readAsBytes();

    setState(() => isUploadingImage = false); // ปิด overlay loading

    if (!mounted) return;
    final controller = cyi.CropController();

    // เปิดหน้า crop
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.only(top: 24),
        title: const Center(
          child: Text(
            'ຕັດຮູບພາບ',
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: SizedBox(
          width: 350,
          height: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: cyi.Crop(
                  image: originalBytes,
                  controller: controller,
                  onCropped: (Uint8List croppedBytes) async {
                    img.Image? decoded = img.decodeImage(croppedBytes);
                    Uint8List finalBytes;
                    if (decoded != null) {
                      int maxSize = 600;
                      int width = decoded.width, height = decoded.height;
                      if (width > maxSize || height > maxSize) {
                        if (width > height) {
                          height = (height * maxSize / width).round();
                          width = maxSize;
                        } else {
                          width = (width * maxSize / height).round();
                          height = maxSize;
                        }
                      }
                      img.Image resized =
                          img.copyResize(decoded, width: width, height: height);
                      finalBytes = Uint8List.fromList(
                          img.encodeJpg(resized, quality: 85));
                    } else {
                      finalBytes = croppedBytes;
                    }

                    if (!mounted) return;
                    setState(() {
                      _profileImageBase64 = base64Encode(finalBytes);
                      isUploadingImage = false;
                    });
                  },
                  withCircleUi: true,
                  baseColor: Colors.white,
                  maskColor: Colors.teal.withOpacity(0.15),
                  radius: 120,
                  interactive: true,
                  cornerDotBuilder: (size, edgeAlignment) => Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // ปิดหน้า crop ก่อน
                    // รอให้ dialog ปิดก่อน แล้วค่อย setState และ crop
                    Future.delayed(const Duration(milliseconds: 10), () {
                      if (!mounted) return;
                      setState(() => isUploadingImage = true);
                      controller.crop();
                    });
                  },
                  child: const Text('ຢືນຢັນ', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    // ตรวจสอบก่อนเริ่ม
    if (!_formKey.currentState!.validate() || !mounted) return;

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://752436e70945.ngrok-free.app/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        setState(() => otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP ສົ່ງໄປເບີໂທແລ້ວ')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpPage(
              registerData: {
                'name': name,
                'age': age,
                'village': village,
                'city': city,
                'province': province,
                'phone': phone,
                'email': email,
                'password': password,
                'profile_image': _profileImageBase64,
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ສົ່ງ OTP ບໍ່ສຳເລັດ: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  // ... ส่วนของ _registerWithOtp และ build method ใช้เหมือนเดิมได้ ...
  Future<void> _registerWithOtp() async {
    if (!_formKey.currentState!.validate() || !mounted) return;

    setState(() => isVerifyingOtp = true);
    try {
      final response = await http.post(
        Uri.parse('https://752436e70945.ngrok-free.app/auth/register-with-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'age': age,
          'village': village,
          'city': city,
          'province': province,
          'phone': phone,
          'email': email,
          'password': password,
          'otp': otp,
        }),
      );

      if (!mounted) return;
      setState(() => isVerifyingOtp = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ສະໝັກສະມາຊິກສຳເລັດ!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ຢືນຢັນ OTP ບໍ່ສຳເລັດ: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isVerifyingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.white;
    const primary = Colors.teal;
    const accent = Color(0xFFFFFFFF);
    const Color text = Color(0xFF000000);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('ສະໝັກສະມາຊິກ'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      'ສ້າງບັນຊີໃໝ່',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.teal.withOpacity(0.15),
                              backgroundImage: _profileImageBase64 != null
                                  ? MemoryImage(
                                      base64Decode(_profileImageBase64!))
                                  : const AssetImage(
                                          'assets/default-avatar.png')
                                      as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ເລືອກຮູບໂປຣໄຟລ',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ຊື່ ແລະ ນາມສະກຸນ',
                        prefixIcon: Icon(Icons.person, color: primary),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      onChanged: (val) => name = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'ກະລຸນາປ້ອນຊື່ຂອງທ່ານ'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ອາຍຸ',
                        prefixIcon: Icon(Icons.cake, color: primary),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => age = int.tryParse(val) ?? 0,
                      validator: (val) => val == null || val.isEmpty
                          ? 'ກະລຸນາປ້ອນອາຍຸຂອງທ່ານ'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ບ້ານ',
                        prefixIcon: Icon(Icons.home, color: primary),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      onChanged: (val) => village = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'ກະລຸນາປ້ອນບ້ານ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ເມືອງ',
                        prefixIcon: Icon(Icons.location_city, color: primary),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      onChanged: (val) => city = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'ກະລຸນາປ້ອນເມືອງ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ແຂວງ',
                        prefixIcon: Icon(Icons.map, color: primary),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      onChanged: (val) => province = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'ກະລຸນາປ້ອນແຂວງ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ເບີໂທ',
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8, right: 4),
                              child:
                                  Text('🇱🇦', style: TextStyle(fontSize: 20)),
                            ),
                            const Text(
                              '+856',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      keyboardType: TextInputType.phone,
                      onChanged: (val) => phone = val,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'ກະລຸນາປ້ອນເບີໂທ';
                        }
                        if (!RegExp(r'^20\d{8,9}$').hasMatch(val)) {
                          return 'ເບີຕ້ອງເລີ່ມ 20... ແລະມີ 10-11 ຕົວເລກ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ອີເມລ',
                        prefixIcon: Icon(Icons.email, color: primary),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      onChanged: (val) => email = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'ກະລຸນາປ້ອນອີເມລ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ລະຫັດຜ່ານ',
                        prefixIcon: Icon(Icons.lock, color: primary),
                        filled: true,
                        fillColor: accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                      style: TextStyle(color: text),
                      obscureText: true,
                      onChanged: (val) => password = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'ກະລຸນາປ້ອນລະຫັດຜ່ານ'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    if (!otpSent)
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
                          onPressed: isLoading ? null : _sendOtp,
                          child: const Text(
                            'ສົ່ງ OTP',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    if (otpSent) ...[
                      const SizedBox(height: 18),
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
                        validator: (val) => val == null || val.isEmpty
                            ? 'ກະລຸນາປ້ອນ OTP'
                            : null,
                      ),
                      const SizedBox(height: 18),
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
                          onPressed: isVerifyingOtp ? null : _registerWithOtp,
                          child: const Text(
                            'ຢືນຢັນ OTP ແລະ ສະໝັກສະມາຊິກ',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isLoading || isUploadingImage || isVerifyingOtp)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitWaveSpinner(
                      color: Colors.teal,
                      size: 70,
                      waveColor: Color(0xFFB2DFDB),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ກຳລັງໂຫຼດ...',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
