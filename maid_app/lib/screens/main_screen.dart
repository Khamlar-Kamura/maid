// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart'; // <-- หน้าแรกที่เราจะสร้างใหม่
import 'user_dashboard.dart'; // <-- หน้าแสดงการจองเดิม

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const MainScreen({
    super.key,
    required this.userData,
    required this.token,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomeScreen(token: widget.token), // หน้าแรก (ใหม่)
      UserDashboard(userData: widget.userData, token: widget.token), // หน้าการจอง
      const Center(child: Text('ຂໍ້ຄວາມ')), // Placeholder
      const Center(child: Text('ຮ້ານຄ້າ')), // Placeholder
      const Center(child: Text('ໂປຣໄັຟລ໌')), // Placeholder
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
         backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ໜ້າຫຼັກ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'ການຈອງ'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'ຂໍ້ຄວາມ'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'ຮ້ານຄ້າ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ໂປຣໄັຟລ໌'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal, // เปลี่ยนสีตามธีม
        onTap: _onItemTapped,
      ),
    );
  }
}