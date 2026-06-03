import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_theme.dart';
import 'package:snack_bazaar/features/admin/screens/admin_home_screen.dart';

class SnackBazaarApp extends StatelessWidget {
  const SnackBazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack Bazaar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdminHomeScreen(),
    );
  }
}
