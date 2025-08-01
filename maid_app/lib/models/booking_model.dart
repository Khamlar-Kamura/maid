class Booking {
  final String id;
  final DateTime bookingDate;
  final String status;
  final String userId;

  Booking({
    required this.id,
    required this.bookingDate,
    required this.status,
    required this.userId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // กรณี user_id เป็น object
    String extractUserId(dynamic user) {
      if (user is String) return user;
      if (user is Map && user['_id'] != null) return user['_id'];
      return '';
    }

    return Booking(
      id: json['_id'] ?? '',
      bookingDate: DateTime.parse(json['booking_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      userId: extractUserId(json['user_id']),
    );
  }
}