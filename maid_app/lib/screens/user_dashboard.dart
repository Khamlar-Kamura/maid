import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';

class UserDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const UserDashboard({super.key, required this.userData, required this.token});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final ApiService _apiService = ApiService();
  late User _user;
  Future<List<Booking>>? _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _user = User.fromJson(widget.userData);
    _bookingsFuture = _apiService.fetchMyBookings(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ການຈອງຂອງ ${_user.fullName}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.teal.withOpacity(0.07),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            Text(
              'ປະຫວັດການຈອງ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
            const SizedBox(height: 12),
            _buildBookingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Colors.teal,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                _user.fullName.isNotEmpty
                    ? _user.fullName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.teal),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ຍິນດີຕ້ອນຮັບ,', style: TextStyle(color: Colors.white)),
                Text(
                  _user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    return FutureBuilder<List<Booking>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('ເກີດຂໍ້ຜິດພາດໃນການດືງຂໍ້ມູນ: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('ເຈົ້າຍັງບໍ່ມີລາຍການຈອງໃນລະບົບ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        // กรองเฉพาะ booking ของ user นี้ (ถ้า fetchMyBookings ไม่กรองให้)
        final bookings = snapshot.data!
            .where((b) => b.userId == _user.id)
            .toList();

        return Column(
          children: bookings
              .map((booking) => _buildBookingCard(booking))
              .toList(),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    switch (booking.status) {
      case 'ຢືນຢັນແລ້ວ':
        statusColor = Colors.green;
        break;
      case 'ລໍຖ້າດຳເນີນການ':
        statusColor = Colors.orange;
        break;
      case 'ຍົກເລີກ':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        tileColor: Colors.white,
        title: Text(
          "ລະຫັດການຈອງ: ${booking.id}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "ວັນທີ່: ${booking.bookingDate.toLocal().toString().split(' ')[0]}",
        ),
        trailing: Chip(
          label: Text(
            booking.status,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: statusColor,
        ),
        onTap: () {
          // ไปหน้ารายละเอียดการจอง
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(booking: booking),
            ),
          );
        },
      ),
    );
  }
}

// สร้างหน้ารายละเอียดการจองแบบง่าย
class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ລາຍລະອຽດການຈອງ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ລະຫັດການຈອງ: ${booking.id}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("ວັນທີ່: ${booking.bookingDate.toLocal().toString().split(' ')[0]}"),
            const SizedBox(height: 12),
            Text("ສະຖານະ: ${booking.status}"),
            const SizedBox(height: 12),
            // เพิ่ม field อื่นๆ ตามต้องการ
          ],
        ),
      ),
    );
  }
}