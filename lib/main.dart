import 'package:flutter/material.dart';
import 'package:inventory_manager/database/database_helper.dart';
import 'package:inventory_manager/screens/login_screen.dart';
import 'package:inventory_manager/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.initialize();

  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const LoginScreen(),
    );
  }
}
