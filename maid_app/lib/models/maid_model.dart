// lib/models/maid_model.dart

// ฟังก์ชันสำหรับแปลงข้อมูลที่อาจจะไม่ใช่ List ให้เป็น List<String> เสมอ
List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return List<String>.from(value.map((item) => item.toString()));
  }
  return [];
}

class Maid {
  final String id; // ใช้ _id จาก MongoDB
  final String maidId;
  final String fullName;
  final String? profileImage;
  final List<String> skills;
  final String status;

  Maid({
    required this.id,
    required this.maidId,
    required this.fullName,
    this.profileImage,
    required this.skills,
    required this.status,
  });

  factory Maid.fromJson(Map<String, dynamic> json) {
    return Maid(
      id: json['_id'] ?? '',
      maidId: json['maid_id'] ?? '',
      fullName: json['full_name'] ?? 'ไม่มีชื่อ',
      profileImage: json['profile_image'],
      skills: _parseStringList(json['skills']),
      status: json['status'] ?? 'ไม่ระบุ',
    );
  }
}