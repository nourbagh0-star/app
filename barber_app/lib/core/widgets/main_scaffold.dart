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
                  BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), label: context.tr('nav_dashboard')),
                  BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_outlined), label: context.tr('nav_schedule')),
                  BottomNavigationBarItem(icon: const Icon(Icons.cut_outlined), label: context.tr('nav_services')),
                  BottomNavigationBarItem(icon: const Icon(Icons.groups_outlined), label: context.tr('nav_staff')),
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
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/services')) return 2;
    if (location.startsWith('/staff')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/schedule'); break;
      case 2: context.go('/services'); break;
      case 3: context.go('/staff'); break;
      case 4: context.go('/profile'); break;
    }
  }
}
