// file: lib/models/address_model.dart

import 'package:latlong2/latlong.dart';

/// คลาสสำหรับจัดเก็บข้อมูลที่อยู่ทั้งหมดที่ได้จากฟอร์ม
/// เพื่อใช้ส่งข้อมูลระหว่างหน้าจอต่างๆ ภายในแอป Flutter
class AddressModel {
  // --- Properties ---
  final String name;
  final String placeName;
  final String phone;
  final String details;
  final String note;
  final LatLng location;

  /// --- Constructor ---
  /// ใช้สำหรับสร้าง object ของ AddressModel
  const AddressModel({
    required this.name,
    required this.placeName,
    required this.phone,
    required this.details,
    required this.note,
    required this.location,
  });
}