import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/body_composition/screens/dashboard.dart';
import 'package:fitmate_flutter/features/home/screens/home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // 로그인 후 기본으로 보여줄 '홈' 탭

  final List<Widget> _screens = [
    const HomeScreen(),
    const BodyCompositionsDashboard(),
    const Center(child: Text('서클 화면')),
    const Center(child: Text('알림 화면')),
    const Center(child: Text('설정 화면')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: FitMateTheme.colorPrimary,
        unselectedItemColor: Theme.of(context).colorScheme.outlineVariant,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 22)), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: '내 기록'),
          BottomNavigationBarItem(icon: Text('👥', style: TextStyle(fontSize: 22)), label: '서클'),
          BottomNavigationBarItem(icon: Text('🔔', style: TextStyle(fontSize: 22)), label: '알림'),
          BottomNavigationBarItem(icon: Text('⚙️', style: TextStyle(fontSize: 22)), label: '설정'),
        ],
      ),
    );
  }
}