import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/seller_apply_screen.dart';
import 'screens/my_page_screen.dart';
import 'widgets/bottom_tab_bar.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
          CategoryScreen(),
          SellerApplyScreen(),
          MyPageScreen(),
        ],
      ),
      // Bottom tab bar only on mobile
      bottomNavigationBar: isDesktop
          ? null
          : AppBottomTabBar(
              currentIndex: _selectedIndex,
              onTap: _onTabSelected,
            ),
    );
  }
}
