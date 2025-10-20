import 'package:flutter/material.dart';
import 'package:money_mate/screens/home_screen.dart';
import 'package:money_mate/screens/profile_screen.dart';
import 'package:money_mate/screens/transaction_screen.dart';
import 'package:money_mate/utils/colors.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class PageSelection extends StatefulWidget {
  const PageSelection({super.key});

  @override
  State<PageSelection> createState() => _PageSelectionState();
}

class _PageSelectionState extends State<PageSelection> {
  int _page = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const TransactionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: const Color(0xFF252525),
        option: BubbleBarOptions(
          barStyle: BubbleBarStyle.horizontal,
          bubbleFillStyle: BubbleFillStyle.fill,
        ),
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        items: [
          BottomBarItem(
            icon: const Icon(Icons.home_outlined, color: Colors.grey),
            selectedIcon: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            backgroundColor: buttonColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.attach_money_outlined, color: Colors.grey),
            selectedIcon: const Icon(Icons.attach_money, color: Colors.white),
            title: const Text('Transactions', style: TextStyle(color: Colors.white)),
            backgroundColor: buttonColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            selectedIcon: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            backgroundColor: buttonColor,
          ),
        ],
      ),
    );
  }
}