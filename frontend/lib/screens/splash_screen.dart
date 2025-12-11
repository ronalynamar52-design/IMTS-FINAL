import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'dashboard/student_dashboard.dart';
import 'dashboard/coordinator_dashboard.dart';
import 'dashboard/supervisor_dashboard.dart';
import 'dashboard/admin_dashboard.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.autoLogin();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (isLoggedIn && authProvider.user != null) {
      _navigateToDashboard(authProvider.user!.role);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _navigateToDashboard(String role) {
    Widget screen;
    switch (role.toLowerCase()) {
      case 'student':
        screen = const StudentDashboardScreen();
        break;
      case 'coordinator':
        screen = const CoordinatorDashboardScreen();
        break;
      case 'supervisor':
        screen = const SupervisorDashboardScreen();
        break;
      case 'admin':
        screen = const AdminDashboardScreen();
        break;
      default:
        screen = const LoginScreen();
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF047857),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: Color(0xFF047857),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'IMTS',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Internship Management System',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
