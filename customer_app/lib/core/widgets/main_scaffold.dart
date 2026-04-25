import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: child,
          bottomNavigationBar: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: AppColors.surface,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primaryGold,
                unselectedItemColor: AppColors.textHint,
                currentIndex: _calculateSelectedIndex(context),
                onTap: (index) => _onItemTapped(index, context),
                items: [
                  BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: context.tr('nav_home')),
                  BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: context.tr('nav_bookings')),
                  BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: context.tr('nav_profile')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/history'); break;
      case 2: context.go('/profile'); break;
    }
  }
}
