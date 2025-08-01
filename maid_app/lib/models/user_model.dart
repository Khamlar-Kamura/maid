// lib/models/user_model.dart

class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final List<Address> addresses;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    required this.addresses,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // แปลง List ของ JSON addresses ให้เป็น List ของ Address object
    var addressList =
        (json['addresses'] as List<dynamic>?)
            ?.map((item) => Address.fromJson(item))
            .toList() ??
        [];

    return User(
      // เพิ่ม `?? ''` หรือค่าสำรองอื่นๆ เพื่อป้องกันค่า null ทั้งหมด
      id: json['_id'] ?? '',
      fullName: json['name'] ?? 'ผู้ใช้ไม่มีชื่อ',
      email: json['email'] ?? '',
      phoneNumber: json['phone'] ?? '',
      profileImage:
          json['profile_image'], // field นี้เป็น String? อยู่แล้ว จึงรับ null ได้
      addresses: addressList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class Address {
  final String label;
  final String fullAddress;
  final Location? location; // ทำให้ location เป็น nullable เพื่อความปลอดภัย
  final String? note;

  Address({
    required this.label,
    required this.fullAddress,
    this.location,
    this.note,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      label: json['label'] ?? '',
      fullAddress: json['full_address'] ?? '',
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      note: json['note'],
    );
  }
}

class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}
