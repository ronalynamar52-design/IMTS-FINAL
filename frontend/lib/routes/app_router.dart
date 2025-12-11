import 'package:flutter/material.dart';
import 'package:imts_frontend/screens/auth/login_screen.dart';
import 'package:imts_frontend/screens/auth/register_screen.dart';
import 'package:imts_frontend/screens/dashboard/student_dashboard.dart';
import 'package:imts_frontend/screens/dashboard/coordinator_dashboard.dart';
import 'package:imts_frontend/screens/dashboard/supervisor_dashboard.dart';
import 'package:imts_frontend/screens/dashboard/admin_dashboard.dart';
import 'package:imts_frontend/screens/profile/profile_screen.dart';
import 'package:imts_frontend/screens/attendance/submit_log_screen.dart';
import 'package:imts_frontend/screens/messages/messages_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/student-dashboard':
        return MaterialPageRoute(builder: (_) => const StudentDashboardScreen());
      case '/coordinator-dashboard':
        return MaterialPageRoute(builder: (_) => const CoordinatorDashboardScreen());
      case '/supervisor-dashboard':
        return MaterialPageRoute(builder: (_) => const SupervisorDashboardScreen());
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/submit-log':
        return MaterialPageRoute(builder: (_) => const SubmitLogScreen());
      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessagesScreen());
      // Add more routes as needed
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static void navigateToDashboard(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'student':
        Navigator.pushReplacementNamed(context, '/student-dashboard');
        break;
      case 'coordinator':
        Navigator.pushReplacementNamed(context, '/coordinator-dashboard');
        break;
      case 'supervisor':
        Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/login');
    }
  }
}