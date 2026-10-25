import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/admin/models/seller_request.dart';
import 'package:snack_bazaar/features/admin/widgets/stat_card.dart';
import 'package:snack_bazaar/features/admin/widgets/seller_request_card.dart';
import 'package:snack_bazaar/features/admin/screens/sellers_list_screen.dart';
import 'package:snack_bazaar/features/admin/screens/insights_screen.dart';
import 'package:snack_bazaar/features/seller/services/seller_application_repository.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentNavIndex = 0;
  final SellerApplicationRepository _applications = SellerApplicationRepository();

  Future<void> _handleReview(SellerRequest request, {required bool approve}) async {
    try {
      await _applications.review(request, approve: approve);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? '${request.businessName} approved.'
                : '${request.businessName} rejected.',
          ),
          backgroundColor: approve ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not review application: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildCurrentTab(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Admin Portal',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout, size: 24),
          color: AppColors.textPrimary,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined, size: 26),
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentNavIndex) {
      case 1:
        return const SellersListScreen();
      case 2:
        return const InsightsScreen();
      case 0:
      default:
        return _buildRequestsBody();
    }
  }

  Widget _buildRequestsBody() {
    return StreamBuilder<List<SellerRequest>>(
      stream: _applications.watchPending(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Could not load applications: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? const <SellerRequest>[];
        return _buildRequestsContent(requests);
      },
    );
  }

  Widget _buildRequestsContent(List<SellerRequest> requests) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Stats row —
          _buildStatsRow(requests.length),
          const SizedBox(height: 28),

          // — Verification Queue header —
          _buildQueueHeader(),
          const SizedBox(height: 16),

          // — Seller request cards —
          ...requests.map(
            (request) => SellerRequestCard(
              request: request,
              onApprove: () => _handleReview(request, approve: true),
              onReject: () => _handleReview(request, approve: false),
            ),
          ),

          // Empty state
          if (requests.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int pendingCount) {
    return Row(
      children: [
        StatCard(
          title: 'Pending Requests',
          value: pendingCount.toString(),
          subtitle: 'Current review queue',
          valueColor: AppColors.primary,
          subtitleIcon: Icons.schedule,
          subtitleIconColor: AppColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildQueueHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Verification Queue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No pending verification requests.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
            currentIndex: _currentNavIndex,
            onTap: (index) => setState(() => _currentNavIndex = index),
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.assignment_outlined, 0),
                activeIcon: _buildNavIcon(Icons.assignment, 0, isActive: true),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.store_outlined, 1),
                activeIcon: _buildNavIcon(Icons.store, 1, isActive: true),
                label: 'Sellers',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.insights_outlined, 2),
                activeIcon: _buildNavIcon(Icons.insights, 2, isActive: true),
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
