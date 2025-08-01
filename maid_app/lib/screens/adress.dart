import '../models/addressModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class AddAddressScreen extends StatefulWidget {
final AddressModel? existingAddress;


  // ✨ 2. เพิ่ม this.existingAddress เข้าไปใน constructor
   const AddAddressScreen({Key? key, this.existingAddress}) : super(key: key);
  
  

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController nameController = TextEditingController();
  // ✨ เพิ่ม Controller สำหรับชื่อสถานที่โดยเฉพาะ
  final TextEditingController placeNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  LatLng? selectedLatLng;
  final MapController _mapController = MapController();
  bool _isSaving = false;
    @override
  void initState() {
    super.initState();
    // ถ้ามีข้อมูลที่อยู่เดิมส่งเข้ามา (โหมดแก้ไข)
    if (widget.existingAddress != null) {
      // ให้ตั้งค่าเริ่มต้นให้กับ Controllers และ LatLng จากข้อมูลเดิม
      nameController.text = widget.existingAddress!.name;
      placeNameController.text = widget.existingAddress!.placeName;
      // ลบ '+85620' ออกเพื่อให้แสดงแค่ 8 ตัวท้ายใน TextField
      phoneController.text = widget.existingAddress!.phone.replaceFirst('+85620', '');
      detailController.text = widget.existingAddress!.details;
      noteController.text = widget.existingAddress!.note;
      selectedLatLng = widget.existingAddress!.location;
    }
  }

  // ✨ แยก dispose ออกมาเพื่อความเรียบร้อย
  @override
  void dispose() {
    nameController.dispose();
    placeNameController.dispose();
    phoneController.dispose();
    detailController.dispose();
    noteController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> sendWhatsappToPhone() async {
    final phone = phoneController.text.replaceAll(' ', '');
    final whatsappNumber = '85620$phone';
    final url = Uri.parse('https://wa.me/$whatsappNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ບໍ່ສາມາດເປີດ WhatsApp ໄດ້')),
        );
      }
    }
  }

  Future<void> _pickLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ກະລຸນາເປີດ Location Service')),
        );
      }
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ບໍ່ໄດ້ຮັບອະນຸຍາດໃຫ້ເຂົ້າເຖິງຕຳແໜ່ງ')),
          );
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ບໍ່ໄດ້ຮັບອະນຸຍາດໃຫ້ເຂົ້າເຖິງຕຳແໜ່ງ (ຖາວອນ)')),
        );
      }
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        selectedLatLng = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(selectedLatLng!, 16);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ເລືອກຕຳແໜ່ງແລ້ວ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }
  }

  Future<void> _saveAddress() async {
    // ป้องกันการกดซ้ำซ้อนขณะที่กำลังบันทึก
    if (_isSaving) return;

    // ตรวจสอบข้อมูลเบื้องต้น
    final phoneInput = phoneController.text.trim();
    if (nameController.text.trim().isEmpty || placeNameController.text.trim().isEmpty || phoneInput.length != 8 || selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ ແລະ ເລືອກຕຳແໜ່ງ')),
      );
      return;
    }

    setState(() {
      _isSaving = true; // เริ่มสถานะ Loading
    });

    // กำหนด URL ของ API ที่ถูกต้อง
    // ❗️ อย่าลืมเปลี่ยน IP ให้ตรงกับเครื่องของคุณ
    // - Android Emulator: 'http://10.0.2.2:5000/api/addresses'
    // - Physical Device: 'http://<YOUR_COMPUTER_IP>:5000/api/addresses'
    const String apiUrl = 'https://752436e70945.ngrok-free.app/api/addresses';

    try {
      // สร้างข้อมูลที่จะส่งไปใน Body ของ Request
      final addressData = {
        'name': nameController.text.trim(),
        'placeName': placeNameController.text.trim(),
        'phone': '+85620$phoneInput',
        'details': detailController.text.trim(),
        'note': noteController.text.trim(),
        'latitude': selectedLatLng!.latitude,
        'longitude': selectedLatLng!.longitude,
      };
      
      // ส่ง HTTP POST Request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(addressData),
      );

      // ตรวจสอบผลลัพธ์จาก Server
      if (response.statusCode == 201 && mounted) { // 201 = Created
        print('บันทึกที่อยู่ฝั่ง Backend สำเร็จ!');

        // เมื่อสำเร็จ, สร้าง AddressModel เพื่อส่งกลับไปหน้า BookingCleaningScreen
        final newAddress = AddressModel(
            name: nameController.text.trim(),
            placeName: placeNameController.text.trim(),
            phone: '+85620$phoneInput',
            details: detailController.text.trim(),
            note: noteController.text.trim(),
            location: selectedLatLng!,
        );
        Navigator.pop(context, newAddress);

      } else if (mounted) {
        // กรณี Server ตอบกลับมาว่ามีข้อผิดพลาด
        final errorBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${errorBody['message'] ?? 'ไม่ทราบสาเหตุ'}')),
        );
      }
    } catch (e) {
      // จัดการข้อผิดพลาดด้าน Network
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e')),
        );
      }
    } finally {
      // ไม่ว่าจะสำเร็จหรือล้มเหลว ให้หยุดสถานะ Loading
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final LatLng defaultCenter = LatLng(17.9667, 102.6000);
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('ເພີ່ມທີ່ຢູ່ໃໝ່', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ຊື່ຜູ້ເອີ້ນບໍລິການ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'ຊື່ຜູ້ທີ່ຕ້ອງການໃຊ້ບໍລິການ ຫຼື ສາມາດລົມວຽກໄດ້',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('ຊື່ສະຖານທີ່',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              // ✨ ใช้ Controller ของตัวเอง
              TextField(
                controller: placeNameController,
                decoration: InputDecoration(
                  hintText: 'ຊື່ບ້ານ, ຕຶກ, ອະພາດເມັນ...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('ເບີໂທ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'ເບີຕິດຕໍ່',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: '+85620 ',
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.whatsapp,
                    color: Colors.white),
                label: const Text('ທົດສອບສົ່ງ WhatsApp'),
                onPressed: sendWhatsappToPhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('ລາຍລະອຽດ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: detailController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'ລາຍລະອຽດທີ່ຢູ່, ຈຸດສັງເກດ...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('ໝາຍເຫດ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText:
                      'ໃສ່ຄຳແນະນຳ ຫຼື ຂໍ້ມູນພິເສດເພື່ອໃຫ້ແມ່ບ້ານເຮັດວຽກງ່າຍຂຶ້ນ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('ເລືອກຕຳແໜ່ງຈາກແຜນທີ່',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect( // ClipRRect to enforce border radius on map
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: selectedLatLng ?? defaultCenter,
                          initialZoom: 14,
                          onTap: (tapPos, latlng) {
                            setState(() {
                              selectedLatLng = latlng;
                            });
                            _mapController.move(latlng, 16);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.maid_app',
                          ),
                          if (selectedLatLng != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedLatLng!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_on,
                                      color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // ปุ่มขยาย/แก้ไขแผนที่
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: () async {
                              final LatLng? result =
                                  await showModalBottomSheet<LatLng>(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  // This is a self-contained stateful widget now
                                  return FullscreenMapPicker(
                                    initialLatLng:
                                        selectedLatLng ?? defaultCenter,
                                  );
                                },
                              );

                              if (result != null) {
                                setState(() {
                                  selectedLatLng = result;
                                });
                                _mapController.move(result, 16);
                              }
                            },
                            child: const Text("ແກ້ໄຂ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.my_location),
                      label: const Text('ໃຊ້ຕຳແໜ່ງຂ້ອຍ'), // "ใช้ตำแหน่งฉัน"
                      onPressed: _pickLocation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveAddress,
                  child: const Text('ບັນທຶກທີ່ຢູ່',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// ✨ NEW WIDGET: FullscreenMapPicker
// แยก Widget ของหน้าจอเลือกแผนที่เต็มจอออกมาเพื่อจัดการ State ของตัวเอง
// =========================================================================
// =========================================================================
// ✨ WIDGET: FullscreenMapPicker (อัปเดตสำหรับภาษาลาว)
// =========================================================================
// =========================================================================
// ✨ PASTE THIS ENTIRE BLOCK TO FIX THE ERROR ✨
// =========================================================================

// ❗️❗️ THIS CLASS WAS MISSING ❗️❗️
// This is the main widget class. It must come BEFORE the _FullscreenMapPickerState class.
class FullscreenMapPicker extends StatefulWidget {
  final LatLng initialLatLng;
  const FullscreenMapPicker({super.key, required this.initialLatLng});

  @override
  State<FullscreenMapPicker> createState() => _FullscreenMapPickerState();
}

// This is the State class. It depends on the FullscreenMapPicker class above.
class _FullscreenMapPickerState extends State<FullscreenMapPicker> {
  late LatLng _currentCenter;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // ตั้งค่าจุดศูนย์กลางของแผนที่จากค่าที่ส่งเข้ามา
    _currentCenter = widget.initialLatLng;
  }
  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchPlace(String query) async {
    if (query.trim().length < 2) return;
    setState(() => _isSearching = true);
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=10&countrycodes=la&accept-language=lo');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'maid_app'});
      if (mounted && response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _searchResults = data.map<Map<String, dynamic>>((item) => {
                'name': item['display_name'],
                'latlng': LatLng(
                  double.parse(item['lat']),
                  double.parse(item['lon']),
                ),
              }).toList();
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() {
      _isReverseGeocoding = true;
      _searchResults = [];
    });
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1&accept-language=lo');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'maid_app'});
      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'] ?? 'ບໍ່ພົບຊື່ສະຖານທີ່';
        _searchController.text = displayName;
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      if (mounted) setState(() => _isReverseGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ຄົ້ນຫາ ຫຼື ເລື່ອນແຜນທີ່...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isReverseGeocoding || _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _searchPlace(value);
                    });
                  },
                ),
              ),
              if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(item['name']),
                        onTap: () {
                          _currentCenter = item['latlng'];
                          _mapController.move(_currentCenter, 16);
                          _searchController.text = item['name'];
                          setState(() => _searchResults = []);
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                ),
              Expanded(
                flex: _searchResults.isNotEmpty ? 0 : 1,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentCenter,
                        initialZoom: 16,
                        onPositionChanged: (position, hasGesture) {
                          if (hasGesture) {
                            _currentCenter = position.center;
                            if (_debounce?.isActive ?? false)
                              _debounce!.cancel();
                            _debounce =
                                Timer(const Duration(milliseconds: 500), () {
                              if (mounted) {
                                _reverseGeocode(position.center);
                              }
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.maid_app',
                        ),
                      ],
                    ),
                    const IgnorePointer(
                      child: Center(
                        child: Icon(Icons.location_on,
                            color: Colors.red, size: 48),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context, _currentCenter);
                    },
                    child: const Text('ຢືນຢັນຕຳແໜ່ງ',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}