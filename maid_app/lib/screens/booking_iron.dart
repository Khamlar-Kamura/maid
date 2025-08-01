import 'package:flutter/material.dart';
import 'home_screen.dart';

class BookingIronScreen extends StatelessWidget {
  final Service service;
  const BookingIronScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(service.imageUrl, height: 180),
            const SizedBox(height: 16),
            const Text('Coming soon...'),
            // เพิ่ม widget เลือกวัน/เวลา/ขนาดห้องที่นี่
          ],
        ),
      ),
    );
  }
}