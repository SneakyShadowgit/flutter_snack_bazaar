import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snack_bazaar/core/theme/app_theme.dart';
import 'package:snack_bazaar/features/auth/screens/auth_screen.dart';
import 'package:snack_bazaar/features/auth/services/account_service.dart';
import 'package:snack_bazaar/features/admin/screens/admin_home_screen.dart';
import 'package:snack_bazaar/features/seller/screens/seller_home_screen.dart';
import 'package:snack_bazaar/features/buyer/screens/buyer_home_screen.dart';

class SnackBazaarApp extends StatelessWidget {
  const SnackBazaarApp({super.key});

  static final _accountService = AccountService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack Bazaar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: _accountService.authStateChanges,
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const _StartupScreen();
          }
          final user = authSnapshot.data;
          if (user == null) return AuthScreen(accountService: _accountService);
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _accountService.watchProfile(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const _StartupScreen();
              }
              if (profileSnapshot.hasError) {
                return _AccessMessage(
                  message: 'We could not load your account. Check your connection and try again.',
                  onSignOut: _accountService.signOut,
                );
              }
              if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
                return _AccessMessage(
                  message: 'Your account profile is not set up. Contact support to restore access.',
                  onSignOut: _accountService.signOut,
                );
              }
              final data = profileSnapshot.data!.data()!;
              final role = data['role'];
              final status = data['status'];
              if (role == 'seller' && status == 'approved') return const SellerHomeScreen();
              if (role == 'admin') return const AdminHomeScreen();
              if (role == 'buyer') return const BuyerHomeScreen();
              return _AccessMessage(
                message: role == 'seller'
                    ? 'Your seller account is awaiting approval.'
                    : 'This account does not have access to a portal.',
                onSignOut: _accountService.signOut,
              );
            },
          );
        },
      ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class _AccessMessage extends StatelessWidget {
  const _AccessMessage({required this.message, required this.onSignOut});

  final String message;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(onPressed: onSignOut, child: const Text('Sign out')),
              ],
            ),
          ),
        ),
      );
}
