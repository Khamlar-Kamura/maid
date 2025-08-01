import 'package:flutter/material.dart';
/*import 'package:flutter_map/flutter_map.dart';*/
/*import 'package:latlong2/latlong.dart';*/
import 'home_screen.dart';
/*import 'package:geolocator/geolocator.dart';*/
import 'multi_booking_content.dart';
import 'adress.dart';
import '../models/addressModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment.dart';

// ...existing import...
class BookingCleaningScreen extends StatefulWidget {
  final Service service;
  const BookingCleaningScreen({super.key, required this.service});

  @override
  State<BookingCleaningScreen> createState() => _BookingCleaningScreenState();
}

class _BookingCleaningScreenState extends State<BookingCleaningScreen> {
  final TextEditingController locationController = TextEditingController();

  /*LatLng? _selectedPosition;*/
  int selectedTab = 0;
  double? _selectedHour;
  int _bedroomCount = 1; // เดิม 1
  int _bathroomCount = 1;
  bool _isIroningSelected = false;
  bool _isCookingSelected = false;
  bool _isDishwashingSelected = false;
  bool _isBabysittingSelected = false;
  double? _backendPrice;
  bool _isLoadingPrice = false;

  String? _selectedResidence; // ค่าเริ่มต้น
  final List<String> _residenceTypes = [
    'ບ້ານຊັ້ນດຽວ',
    'ບ້ານສອງຊັ້ນ',
    'ຫໍພັກໜື່ງຫ້ອງນອນ',
    'ຫໍພັກສອງຫ້ອງນອນ',
    'ສຳນັກງານ'
  ]; // ประเภทที่พัก
  final List<String> _otherRoomOptions = [
    'ຫ້ອງຄົວ',
    'ຫ້ອງຮັບແຂກ',
    'ຫ້ອງທຳອິດ',
    'ຫ້ອງກັບເກີບ',
    'ຫ້ອງອື່ນໆ'
  ];
  List<String> _selectedOtherRooms = [];

  DateTime? selectedDate;
  String? selectedTime;
  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    /*_getCurrentLocation();*/
  }

  // แก้ไขในฟังก์ชัน fetchBackendPrice()

  Future<void> fetchBackendPrice() async {
    // ตรวจสอบก่อนว่าข้อมูลสำคัญถูกเลือกแล้วหรือยัง
    if (_selectedHour == null) {
      // ถ้ายังไม่ได้เลือกชั่วโมง ให้ออกจากฟังก์ชันไปเลย ไม่ต้องทำอะไรต่อ
      return;
    }

    setState(() => _isLoadingPrice = true);
    final url =
        Uri.parse('https://752436e70945.ngrok-free.app/api/pricing/calculate');
    final body = {
      "hours": _selectedHour,
      "residence": _selectedResidence,
      "bedrooms": _bedroomCount,
      "bathrooms": _bathroomCount,
      "otherRooms": _selectedOtherRooms,
      "specialServices": [
        if (_isIroningSelected) "ironing",
        if (_isCookingSelected) "cooking",
        if (_isDishwashingSelected) "dishwashing",
        if (_isBabysittingSelected) "babysitting",
      ]
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // พิมพ์ Response ที่ได้รับจาก Backend เพื่อตรวจสอบ
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          // ▼▼▼▼▼▼ แก้ไขกลับมาให้ตรงกับ Backend ใหม่ของคุณ ▼▼▼▼▼▼
          _backendPrice = data['price']?.toDouble();
          // ▲▲▲▲▲▲ แก้ไขกลับมาให้ตรงกับ Backend ใหม่ของคุณ ▲▲▲▲▲▲
        });
      } else {
        // หากเกิดข้อผิดพลาด ให้แน่ใจว่าราคาเป็น null เพื่อซ่อนแถบ
        setState(() {
          _backendPrice = null;
        });
        print('Failed to fetch price. Status code: ${res.statusCode}');
      }
    } catch (e) {
      setState(() {
        _backendPrice = null;
      });
      print('Error fetching price: $e');
    }

    setState(() => _isLoadingPrice = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // ปุ่มสลับหน้า
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.teal),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            color:
                                selectedTab == 0 ? Colors.teal : Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ລາຍມື້',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedTab == 0
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.teal),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            color:
                                selectedTab == 1 ? Colors.teal : Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ຈອງຫຼາຍມື້',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedTab == 1
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // เนื้อหาสลับตาม tab
                if (selectedTab == 0) ...[
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'ກະລຸນາເລືອກເວລາບໍລິການ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<double>(
                                value: _selectedHour,
                                isExpanded: true,
                                hint: const Text('ເລືອກເວລາບໍລິການ',
                                    style: TextStyle(color: Colors.grey)),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                items: [
                                  DropdownMenuItem(
                                    value: 2.0,
                                    child: Text(
                                      '2 ຊົ່ວໂມງ',
                                      style: TextStyle(
                                        color: _selectedHour == 2.0
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2.5,
                                    child: Text(
                                      '2ຊົ່ວໂມງ ເຄີ່ງ',
                                      style: TextStyle(
                                        color: _selectedHour == 2.5
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Text(
                                      '3ຊົ່ວໂມງ',
                                      style: TextStyle(
                                        color: _selectedHour == 3
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 3.5,
                                    child: Text(
                                      '3ຊົ່ວໂມງ ເຄີ່ງ',
                                      style: TextStyle(
                                        color: _selectedHour == 3.5
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 4,
                                    child: Text(
                                      '4ຊົ່ວໂມງ',
                                      style: TextStyle(
                                        color: _selectedHour == 4
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 4.5,
                                    child: Text(
                                      '4ຊົ່ວໂມງ ເຄີ່ງ',
                                      style: TextStyle(
                                        color: _selectedHour == 4.5
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 6,
                                    child: Text(
                                      '6ຊົ່ວໂມງ',
                                      style: TextStyle(
                                        color: _selectedHour == 6
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 8,
                                    child: Text(
                                      '8ຊົ່ວໂມງ',
                                      style: TextStyle(
                                        color: _selectedHour == 8
                                            ? Colors.teal
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedHour = value!;
                                  });
                                  fetchBackendPrice();
                                },
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'ກະລຸນາເລືອກປະເພດທີ່ພັກ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedResidence,
                              isExpanded: true,
                              hint: const Text('ເລືອກປະເພດທີ່ພັກ',
                                  style: TextStyle(color: Colors.grey)),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              items: _residenceTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: _selectedResidence == type
                                          ? Colors.teal
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedResidence = value!;
                                });
                                fetchBackendPrice();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ...existing code...
                  // เพิ่มไว้ใน State class

// ...existing code...
                  const SizedBox(height: 25),
// กรอบกรอกจำนวนห้องนอน
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ห้องนอน
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ຫ້ອງນອນ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.black, size: 28),
                                  onPressed: _bedroomCount > 0
                                      ? () {
                                          setState(() {
                                            _bedroomCount--;
                                          });
                                          fetchBackendPrice();
                                        }
                                      : null,
                                ),
                                Container(
                                  width: 36,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_bedroomCount',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.black, size: 28),
                                  onPressed: _bedroomCount < 5
                                      ? () {
                                          setState(() {
                                            _bedroomCount++;
                                          });
                                          fetchBackendPrice();
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          height: 16,
                          thickness: 1,
                          color: Colors.black,
                        ),
                        // ห้องน้ำ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ຫ້ອງນ້ຳ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.black, size: 28),
                                  onPressed: _bathroomCount > 0
                                      ? () {
                                          setState(() {
                                            _bathroomCount--;
                                          });
                                          fetchBackendPrice();
                                        }
                                      : null,
                                ),
                                Container(
                                  width: 36,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_bathroomCount',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.black, size: 28),
                                  onPressed: _bathroomCount < 5
                                      ? () {
                                          setState(() {
                                            _bathroomCount++;
                                          });
                                          fetchBackendPrice();
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          height: 16,
                          thickness: 1,
                          color: Colors.black,
                        ),
                        // ห้องอื่นๆ (checkbox)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ຫ້ອງອື່ນໆ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 220, // ปรับความกว้างให้ยาวขึ้น
                              child: GestureDetector(
                                onTap: () async {
                                  List<String> tempSelected =
                                      List.from(_selectedOtherRooms);
                                  final result = await showDialog<List<String>>(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setStateDialog) {
                                          return AlertDialog(
                                            title: const Text('ເລືອກຫ້ອງອື່ນໆ'),
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: _otherRoomOptions
                                                    .map((room) {
                                                  return CheckboxListTile(
                                                    title: Text(room),
                                                    value: tempSelected
                                                        .contains(room),
                                                    onChanged: (checked) {
                                                      setStateDialog(() {
                                                        if (checked == true) {
                                                          tempSelected
                                                              .add(room);
                                                        } else {
                                                          tempSelected
                                                              .remove(room);
                                                        }
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('ตกลง'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(tempSelected);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                  if (result != null) {
                                    setState(() {
                                      _selectedOtherRooms = result;
                                    });
                                    fetchBackendPrice();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1.2),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    _selectedOtherRooms.isEmpty
                                        ? 'ເລືອກຫ້ອງ'
                                        : _selectedOtherRooms.join(', '),
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // กรอบกรอกตำแหน่งที่อยู่

                  const SizedBox(height: 20),
                  // ...existing code...
                  if (_selectedAddress == null) ...[
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push<AddressModel>(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddAddressScreen()),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedAddress = result;
                          });
                        }
                      },
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '+ ເພີ່ມທີ່ຢູ່ໃໝ່ຂອງທ່ານ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'ລາຍລະອຽດທີ່ຢູ່',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.08),
                        border: Border.all(color: Colors.teal, width: 1.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAddressRow('ຊື່:', _selectedAddress!.name),
                              _buildAddressRow(
                                  'ຊື່ສະຖານທີ່:', _selectedAddress!.placeName),
                              _buildAddressRow('ເບີ:', _selectedAddress!.phone),
                              if (_selectedAddress!.details.isNotEmpty)
                                _buildAddressRow(
                                    'ລາຍລະອຽດ:', _selectedAddress!.details),
                              if (_selectedAddress!.note.isNotEmpty)
                                _buildAddressRow(
                                    'ໝາຍເຫດ:', _selectedAddress!.note),
                              _buildAddressRow(
                                'ພິກັດ:',
                                '${_selectedAddress!.location.latitude}, ${_selectedAddress!.location.longitude}',
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                          Positioned(
                            bottom: -8,
                            right: -8,
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () async {
                                final result =
                                    await Navigator.push<AddressModel>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddAddressScreen(
                                      existingAddress: _selectedAddress,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    _selectedAddress = result;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
// ...existing code...
// ...existing code...

                  const Text(
                    'ທ່ານຢາກໃຫ້ບໍລິການຕອນໃດ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              locale: const Locale('lo', 'LA'),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors
                                          .teal, // สี header, ปุ่ม ok/cancel, วงกลมวันที่เลือก
                                      onPrimary:
                                          Colors.white, // สีตัวอักษรบน header
                                      onSurface:
                                          Colors.black, // สีตัวอักษรวันที่
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Colors.teal, // สีปุ่ม ok/cancel
                                      ),
                                    ),
                                    datePickerTheme: const DatePickerThemeData(
                                      todayBackgroundColor:
                                          MaterialStatePropertyAll(Colors
                                              .transparent), // สีพื้นหลังวงกลมวันนี้
                                      todayForegroundColor:
                                          MaterialStatePropertyAll(
                                              Colors.black), // สีตัวอักษรวันนี้
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)), // กรอบวงกลม
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                              fetchBackendPrice();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.teal),
                                const SizedBox(width: 8),
                                Text(
                                  selectedDate == null
                                      ? 'ເລືອກວັນ'
                                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButton<String>(
                              value: selectedTime,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              items: [
                                '10:00',
                                '11:00',
                                '12:00',
                                '13:00',
                                '14:00',
                                '15:00',
                                '16:00',
                                '17:00',
                                '18:00',
                                '19:00',
                                '19:30'
                              ]
                                  .map((time) => DropdownMenuItem(
                                        value: time,
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                            color: selectedTime == time
                                                ? Colors.teal
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedTime = value!;
                                });
                                fetchBackendPrice();
                              },
                              hint: const Text('ເລືອກເວລາ'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  const Text(
                    'ບໍລິການພິເສດ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // วาง Column นี้ต่อจาก Text 'ບໍລິການພິເສດ' ของคุณ
                  // ...existing code...
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ซ้าย
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedCheckboxTile(
                              title: 'ລີດເຄື່ອງ +20.000Kip (รีดผ้า)',
                              value: _isIroningSelected,
                              icon: Icons.iron,
                              color: Colors.orange,
                              onChanged: (val) {
                                setState(() => _isIroningSelected = val);
                                fetchBackendPrice();
                              },
                            ),
                            AnimatedCheckboxTile(
                              title: 'ແຕ່ງກິນ +20.000Kip (ทำอาหาร)',
                              value: _isCookingSelected,
                              icon: Icons.restaurant_menu,
                              color: Colors.redAccent,
                              onChanged: (val) {
                                setState(() => _isCookingSelected = val);
                                fetchBackendPrice();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ขวา
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedCheckboxTile(
                              title: 'ລ້າງຈານ +20.000Kip (ล้างจาน)',
                              value: _isDishwashingSelected,
                              icon: Icons.local_dining,
                              color: Colors.blue,
                              onChanged: (val) {
                                setState(() => _isDishwashingSelected = val);
                                fetchBackendPrice();
                              },
                            ),
                            AnimatedCheckboxTile(
                              title: 'ດູແລເດັກນ້ອຍ +20.000Kip (ดูแลเด็กเล็ก)',
                              value: _isBabysittingSelected,
                              icon: Icons.child_friendly,
                              color: Colors.green,
                              onChanged: (val) {
                                setState(() => _isBabysittingSelected = val);
                                fetchBackendPrice();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
// ...existing code...
                ] else ...[
                  // เนื้อหาของ "ຈອງຫຼາຍມື້" (ใส่ widget ที่ต้องการแทน)
                  const MultiBookingContent(),
                ]
              ]))),
      bottomNavigationBar: (_selectedHour != null ||
              _selectedResidence != null ||
              selectedDate != null ||
              selectedTime != null ||
              _selectedAddress != null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(
                  color: Colors.teal,
                  thickness: 2,
                  height: 0,
                ),
                Container(
                  color: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'ຄ່າບໍລິການ: ${_backendPrice?.toStringAsFixed(0) ?? "-"} ກີບ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      _isLoadingPrice
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              // ปุ่มจะกดได้เมื่อเลือกครบทุกช่อง
                              onPressed: (_selectedHour == null ||
                                      _selectedResidence == null ||
                                      selectedDate == null ||
                                      selectedTime == null ||
                                      _selectedAddress == null)
                                  ? null
                                  : () async {
                                      final bookingData = {
                                        "service": widget.service.name,
                                        "hours": _selectedHour,
                                        "residence": _selectedResidence,
                                        "bedrooms": _bedroomCount,
                                        "bathrooms": _bathroomCount,
                                        "otherRooms": _selectedOtherRooms,
                                        "date": selectedDate != null
                                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                            : null,
                                        "time": selectedTime,
                                        "address": {
                                          "name": _selectedAddress!.name,
                                          "placeName":
                                              _selectedAddress!.placeName,
                                          "phone": _selectedAddress!.phone,
                                          "details": _selectedAddress!.details,
                                          "note": _selectedAddress!.note,
                                          "lat": _selectedAddress!
                                              .location.latitude,
                                          "lng": _selectedAddress!
                                              .location.longitude,
                                        },
                                        "specialServices": [
                                          if (_isIroningSelected) "ironing",
                                          if (_isCookingSelected) "cooking",
                                          if (_isDishwashingSelected)
                                            "dishwashing",
                                          if (_isBabysittingSelected)
                                            "babysitting",
                                        ]
                                      };

                                      final url = Uri.parse(
                                          'https://752436e70945.ngrok-free.app/api/pricing/calculate');
                                      final res = await http.post(
                                        url,
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                        body: jsonEncode(bookingData),
                                      );

                                      if (res.statusCode == 200) {
                                        final data = jsonDecode(res.body);
                                        final price = data['price'];
                                        if (price == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'เกิดข้อผิดพลาด: ไม่พบราคาคำนวณ')),
                                          );
                                          return;
                                        }
                                        // เพิ่ม price เข้า bookingData
                                        final booking = {
                                          ...bookingData,
                                          'price': price
                                        };
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PaymentScreen(booking: booking),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'เกิดข้อผิดพลาดในการคำนวณราคา')),
                                        );
                                      }
                                    },
                              child: const Text(
                                'ຊຳລະເງິນ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

Widget _buildAddressRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}

class AnimatedCheckboxTile extends StatelessWidget {
  final String title;
  final bool value;
  final IconData icon;
  final Color color;
  final ValueChanged<bool> onChanged;

  const AnimatedCheckboxTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key == const ValueKey('on')
                  ? anim
                  : Tween<double>(begin: 0.8, end: 1).animate(anim),
              child: child,
            ),
            child: Icon(
              icon,
              key: ValueKey(value ? 'on' : 'off'),
              color: value ? color : Colors.grey,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      activeColor: color,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}



// ...existing code...