import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home))        return 0;
    if (location.startsWith(AppRoutes.productList)) return 1;
    if (location.startsWith(AppRoutes.cart))        return 2;
    if (location.startsWith(AppRoutes.mypage))      return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          backgroundColor: AppColors.cardBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSub,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (i) {
            switch (i) {
              case 0: context.go(AppRoutes.home); break;
              case 1: context.go(AppRoutes.productList); break;
              case 2: context.go(AppRoutes.cart); break;
              case 3: context.go(AppRoutes.mypage); break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),      activeIcon: Icon(Icons.home),             label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined),  activeIcon: Icon(Icons.grid_view),        label: '카테고리'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined),activeIcon: Icon(Icons.shopping_bag),    label: '장바구니'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),      activeIcon: Icon(Icons.person),           label: '마이페이지'),
          ],
        ),
      ),
    );
  }
}
