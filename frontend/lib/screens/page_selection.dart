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
      backgroundColor: AppColors.background,
      body: pages[_page],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: StylishBottomBar(
          backgroundColor: AppColors.surface,
          option: BubbleBarOptions(
            barStyle: BubbleBarStyle.horizontal,
            bubbleFillStyle: BubbleFillStyle.fill,
            opacity: 0.3,
          ),
          currentIndex: _page,
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          items: [
            BottomBarItem(
              icon: const Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.home, color: AppColors.primaryLight),
              title: const Text('Home', style: TextStyle(color: AppColors.textPrimary)),
              backgroundColor: AppColors.primary,
              badge: const SizedBox.shrink(),
            ),
            BottomBarItem(
              icon: const Icon(Icons.attach_money_outlined, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.attach_money, color: AppColors.primaryLight),
              title: const Text('Transactions', style: TextStyle(color: AppColors.textPrimary)),
              backgroundColor: AppColors.primary,
              badge: const SizedBox.shrink(),
            ),
            BottomBarItem(
              icon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.person, color: AppColors.primaryLight),
              title: const Text('Profile', style: TextStyle(color: AppColors.textPrimary)),
              backgroundColor: AppColors.primary,
              badge: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}