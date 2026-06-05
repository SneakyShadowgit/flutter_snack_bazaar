import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/screens/seller_dashboard_tab.dart';
import 'package:snack_bazaar/features/seller/screens/product_management_tab.dart';
import 'package:snack_bazaar/features/seller/screens/orders_management_tab.dart';
import 'package:snack_bazaar/features/seller/screens/business_insights_tab.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _currentTabIndex = 0;

  final List<String> _tabTitles = [
    "Baker's Portal",
    "Baker's Portal",
    "Baker's Portal",
    "Baker's Portal",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentTabIndex,
        children: const [
          SellerDashboardTab(),
          ProductManagementTab(),
          OrdersManagementTab(),
          BusinessInsightsTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        tooltip: 'Change Portal',
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        _tabTitles[_currentTabIndex],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications loaded locally'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          icon: const Icon(Icons.notifications_outlined, size: 24),
          color: AppColors.textPrimary,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) => setState(() => _currentTabIndex = index),
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.dashboard_outlined, 0),
                activeIcon: _buildNavIcon(Icons.dashboard, 0, isActive: true),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.inventory_2_outlined, 1),
                activeIcon: _buildNavIcon(Icons.inventory_2, 1, isActive: true),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.assignment_outlined, 2),
                activeIcon: _buildNavIcon(Icons.assignment, 2, isActive: true),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.insights_outlined, 3),
                activeIcon: _buildNavIcon(Icons.insights, 3, isActive: true),
                label: 'Insights',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 24),
      );
    }
    return Icon(icon, size: 24);
  }
}
