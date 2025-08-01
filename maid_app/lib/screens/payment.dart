import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// หน้าสำหรับแสดงสรุปและยืนยันการชำระเงิน (ในรูปแบบการ์ด)
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isSubmitting = false;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _submitBooking(BuildContext context) async {
    if (isSubmitting) return; // ป้องกันกดซ้ำ
    setState(() => isSubmitting = true);

    final url = Uri.parse('https://752436e70945.ngrok-free.app/api/bookings');
    final token = await getToken(); // ดึง token ที่เก็บไว้
    if (token == null) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາລ໋ອກອິນກ່ອນ')),
      );
      return;
    }
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(widget.booking),
      );
      print('Booking response: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final booking = data['booking'];
        if (booking == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เกิดข้อผิดพลาด: ไม่พบข้อมูลการจอง')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ການຈອງຂອງທ່ານສຳເລັດແລ້ວ!')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ບັນທຶກການຈອງບໍ່ສຳເລັດ: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ຜິດພາດ: $e')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('ສະຫຼຸບການຈອງ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                color: Colors.teal.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.teal, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      _row('ບໍລິການ:', widget.booking['service'] ?? '-'),
                      _row('ປະເພດທີ່ພັກ:', widget.booking['residence'] ?? '-'),
                      _row('ຈຳນວນຫ້ອງນອນ:',
                          widget.booking['bedrooms']?.toString() ?? '0'),
                      _row('ຈຳນວນຫ້ອງນ້ຳ:',
                          widget.booking['bathrooms']?.toString() ?? '0'),
                      _row(
                          'ຫ້ອງອື່ນໆ:',
                          (widget.booking['otherRooms'] as List?)?.join(', ') ??
                              'ບໍ່ມີ'),
                      _row('ວັນທີ:', widget.booking['date'] ?? '-'),
                      _row('ເວລາ:', widget.booking['time'] ?? '-'),
                      _row(
                          'ທີ່ຢູ່:', _formatAddress(widget.booking['address'])),
                      _row(
                          'ບໍລິການພິເສດ:',
                          (widget.booking['specialServices'] as List?)
                                  ?.join(', ') ??
                              'ບໍ່ມີ'),
                      _row('ລາຄາລວມ:',
                          '${widget.booking['price']?.toStringAsFixed(0) ?? "0"} ກີບ'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)
            .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isSubmitting ? null : () => _submitBooking(context),
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'ຢືນຢັນການຊຳລະເງິນ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
        ),
      ),
    );
  }
}

// Helper function สำหรับสร้างแถวในตาราง
TableRow _row(String label, String value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black54)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    ],
  );
}

// Helper function สำหรับจัดรูปแบบที่อยู่ให้สวยงาม
String _formatAddress(dynamic address) {
  if (address == null) return '-';
  if (address is String) return address;
  if (address is Map) {
    final location = address['location'];
    final lat = location is Map ? location['latitude'] : null;
    final lng = location is Map ? location['longitude'] : null;

    final parts = [
      if (address['name'] != null) 'ຊື່: ${address['name']}',
      if (address['placeName'] != null) 'ຊື່ສະຖານທີ່: ${address['placeName']}',
      if (address['phone'] != null) 'ເບີ: ${address['phone']}',
      if (address['details'] != null &&
          address['details'].toString().isNotEmpty)
        'ລາຍລະອຽດ: ${address['details']}',
      if (address['note'] != null && address['note'].toString().isNotEmpty)
        'ໝາຍເຫດ: ${address['note']}',
      if (lat != null && lng != null) 'ພິກັດ: $lat, $lng',
    ];
    return parts.join('\n');
  }
  return address.toString();
}
