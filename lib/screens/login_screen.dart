import 'package:flutter/material.dart';
import 'package:inventory_manager/models/user.dart';
import 'package:inventory_manager/screens/dashboard_screen.dart';
import 'package:inventory_manager/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  final testUsers = [
    const UserModel(
      id: 'USR-001',
      username: 'admin',
      displayName: 'أحمد المديراني',
      password: '123456',
      role: 'مدير النظام',
    ),
    const UserModel(
      id: 'USR-002',
      username: 'manager',
      displayName: 'محمد مدير المستودع',
      password: 'password',
      role: 'مدير المستودع',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF071A3D), Color(0xFF081326), Color(0xFF151044)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      size: 52, color: AppTheme.cyanColor),
                ),
                const SizedBox(height: 28),
                const Text(
                  'مخزني',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'نظام إدارة المخزون والمستودعات',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Column(children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'اسم المستخدم',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.94),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.94),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'دخول',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                const Text(
                  'بيانات تجريبية:\nالمستخدم: admin\nكلمة المرور: 123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final username = usernameController.text.trim();
    final password = passwordController.text;

    UserModel? user;
    for (var testUser in testUsers) {
      if (testUser.validateLogin(username, password)) {
        user = testUser;
        break;
      }
    }

    setState(() => isLoading = false);

    if (user != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(user: user!),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات دخول غير صحيحة')),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
