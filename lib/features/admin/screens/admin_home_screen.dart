import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/admin/models/seller_request.dart';
import 'package:snack_bazaar/features/admin/widgets/stat_card.dart';
import 'package:snack_bazaar/features/admin/widgets/seller_request_card.dart';
import 'package:snack_bazaar/features/admin/screens/sellers_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentNavIndex = 0;
  late List<SellerRequest> _pendingRequests;

  @override
  void initState() {
    super.initState();
    _pendingRequests = List.from(sampleSellerRequests);
  }

  void _handleApprove(SellerRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request.businessName} approved!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
    setState(() {
      _pendingRequests.removeWhere((r) => r.id == request.id);
    });
  }

  void _handleReject(SellerRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request.businessName} rejected.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
    setState(() {
      _pendingRequests.removeWhere((r) => r.id == request.id);
    });
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
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, size: 24),
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
        // Insights tab placeholder
        return const Center(
          child: Text(
            'Insights coming soon',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        );
      case 0:
      default:
        return _buildRequestsBody();
    }
  }

  Widget _buildRequestsBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Stats row —
          _buildStatsRow(),
          const SizedBox(height: 28),

          // — Verification Queue header —
          _buildQueueHeader(),
          const SizedBox(height: 16),

          // — Seller request cards —
          ..._pendingRequests.map(
            (request) => SellerRequestCard(
              request: request,
              onApprove: () => _handleApprove(request),
              onReject: () => _handleReject(request),
            ),
          ),

          // Empty state
          if (_pendingRequests.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        StatCard(
          title: 'Pending Requests',
          value: '${_pendingRequests.length > 9 ? _pendingRequests.length : "24"}',
          subtitle: 'Updated 5m ago',
          valueColor: AppColors.primary,
          subtitleIcon: Icons.schedule,
          subtitleIconColor: AppColors.textTertiary,
        ),
        const SizedBox(width: 12),
        const StatCard(
          title: 'Approved Today',
          value: '12',
          subtitle: '+15% from yesterday',
          valueColor: AppColors.textPrimary,
          subtitleIcon: Icons.trending_up,
          subtitleIconColor: AppColors.success,
        ),
        const SizedBox(width: 12),
        const StatCard(
          title: 'Rejected Today',
          value: '2',
          subtitle: 'Mostly policy violations',
          valueColor: AppColors.error,
          subtitleIcon: Icons.info_outline,
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
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filter'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
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
