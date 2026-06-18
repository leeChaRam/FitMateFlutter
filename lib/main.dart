import 'package:flutter/material.dart';
import 'theme/FitMateTheme.dart';
// 대쉬보드 화면 import 
import 'screens/dashboard.dart';

void main() {
  runApp(const FitMateApp());
}

class FitMateApp extends StatelessWidget {
  const FitMateApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMate',
      theme: FitMateTheme.lightTheme,
      darkTheme: FitMateTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1; // HTML 기본 상태인 '내 기록' 탭 활성화 

  final List<Widget> _screens = [
    const Center(child: Text('홈 화면'),),
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




