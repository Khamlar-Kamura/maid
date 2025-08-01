import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../models/user_model.dart';

class ApiService {
  final String baseUrl = "https://0eb58792378e.ngrok-free.app/api";

  Future<List<Booking>> fetchMyBookings(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/my-bookings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('status: ${response.statusCode}');
    print('body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings: ${response.body}');
    }
  }

  // --- เพิ่มฟังก์ชันนี้เข้าไป ---
  Future<User> fetchMyProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'), // สมมติว่ามี Endpoint นี้
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}
