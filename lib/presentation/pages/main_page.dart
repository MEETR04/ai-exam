import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/invoice/presentation/invoice_generator_screen.dart';
import '../../features/invoice/presentation/recents_screen.dart';
import '../theme/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  final List<Widget> _pages = [
    const InvoiceGeneratorScreen(),
    const RecentsScreen(),
  ];

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _currentIndex,
        builder: (context, index, child) {
          return IndexedStack(index: index, children: _pages);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _currentIndex,
        builder: (context, index, child) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Figma-accurate 1px top divider
                Container(height: 1.r, color: const Color(0xFFE9EBF0)),
                // Tab row
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      16.horizontalSpace,
                      Expanded(
                        child: _BottomNavItem(
                          icon: Icons.home_filled,
                          label: 'Home',
                          isSelected: index == 0,
                          onTap: () => _currentIndex.value = 0,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: _BottomNavItem(
                          icon: Icons.history,
                          label: 'Recents',
                          isSelected: index == 1,
                          onTap: () => _currentIndex.value = 1,
                        ),
                      ),
                      16.horizontalSpace,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    const inactiveColor = Color(0xFF9AA1AD);

    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: SizedBox(
        height: 42.r,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 6.r),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFECF0FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18.r,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                6.horizontalSpace,
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
