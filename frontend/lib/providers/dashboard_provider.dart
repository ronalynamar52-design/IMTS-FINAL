import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/dashboard.dart';
import '../models/user.dart' as UserModel;
import '../config/api_config.dart';

class DashboardProvider with ChangeNotifier {
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData(UserModel.User user, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _dashboardData = DashboardData.fromJson(data);
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Failed to load dashboard data';
        _dashboardData = null;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _dashboardData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DashboardData _generateMockDataForUser(UserModel.User user) {
    switch (user.role) {
      case 'student':
        return _generateStudentDashboardData(user);
      case 'coordinator':
        return _generateCoordinatorDashboardData(user);
      case 'supervisor':
        return _generateSupervisorDashboardData(user);
      case 'admin':
        return _generateAdminDashboardData(user);
      default:
        return _generateStudentDashboardData(user);
    }
  }

  DashboardData _generateStudentDashboardData(UserModel.User user) {
    // Simulate dynamic data - in real app this would come from API
    final hasRecentActivity = DateTime.now().day % 3 != 0; // Some days have no activity
    final hasPendingTasks = DateTime.now().day % 4 != 0; // Some days have no pending tasks
    final hasAttendanceData = DateTime.now().day % 5 != 0; // Some days have no attendance
    final hasEvaluations = DateTime.now().day % 6 != 0; // Some days have no evaluations

    return DashboardData(
      stats: {
        'attendance_percentage': hasAttendanceData ? '85%' : '0%',
        'pending_tasks': hasPendingTasks ? '3' : '0',
        'completed_tasks': hasRecentActivity ? '12' : '0',
        'upcoming_deadlines': hasPendingTasks ? '2' : '0',
      },
      recentActivities: hasRecentActivity ? [
        {
          'id': '1',
          'type': 'attendance',
          'title': 'Attendance Submitted',
          'description': 'Daily attendance logged successfully',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'status': 'completed',
        },
        {
          'id': '2',
          'type': 'task',
          'title': 'Weekly Report Submitted',
          'description': 'Submitted internship progress report',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'status': 'completed',
        },
        {
          'id': '3',
          'type': 'evaluation',
          'title': 'Mid-term Evaluation',
          'description': 'Supervisor evaluation completed',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'status': 'pending',
        },
      ] : [], // Empty list when no activity
      pendingTasks: hasPendingTasks ? [
        {
          'id': '1',
          'title': 'Complete Project Documentation',
          'description': 'Document the internship project with detailed specifications',
          'due_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          'priority': 'high',
        },
        {
          'id': '2',
          'title': 'Update Portfolio',
          'description': 'Add recent project work to personal portfolio',
          'due_date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
          'priority': 'medium',
        },
        {
          'id': '3',
          'title': 'Prepare Presentation',
          'description': 'Prepare slides for final internship presentation',
          'due_date': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
          'priority': 'high',
        },
      ] : [], // Empty list when no pending tasks
      upcomingDeadlines: hasPendingTasks ? [
        {
          'id': '1',
          'title': 'Final Report Due',
          'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'type': 'report',
        },
        {
          'id': '2',
          'title': 'Internship End',
          'date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'type': 'milestone',
        },
      ] : [], // Empty list when no deadlines
      attendanceSummary: hasAttendanceData ? {
        'total_days': 45,
        'present_days': 38,
        'absent_days': 2,
        'late_days': 5,
        'percentage': 85,
      } : null, // Null when no attendance data
      evaluations: hasEvaluations ? [
        {
          'id': '1',
          'evaluator': 'John Smith',
          'role': 'Supervisor',
          'rating': 4.5,
          'comments': 'Excellent work ethic and technical skills. Shows great initiative.',
          'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        },
        {
          'id': '2',
          'evaluator': 'Sarah Johnson',
          'role': 'Coordinator',
          'rating': 4.2,
          'comments': 'Good progress made. Could improve on documentation skills.',
          'date': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
        },
      ] : [], // Empty list when no evaluations
    );
  }

  DashboardData _generateCoordinatorDashboardData(UserModel.User user) {
    return DashboardData(
      stats: {
        'total_students': '45',
        'active_placements': '38',
        'pending_applications': '7',
        'completed_internships': '156',
      },
      recentActivities: [
        {
          'id': '1',
          'type': 'placement',
          'title': 'New Student Placed',
          'description': 'John Doe assigned to Tech Solutions Inc.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
          'status': 'completed',
        },
        {
          'id': '2',
          'type': 'evaluation',
          'title': 'Monthly Report Reviewed',
          'description': 'Reviewed internship progress reports',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'status': 'completed',
        },
      ],
      pendingTasks: [
        {
          'id': '1',
          'title': 'Review Pending Applications',
          'description': 'Review 7 pending internship applications',
          'due_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          'priority': 'high',
        },
        {
          'id': '2',
          'title': 'Schedule Interviews',
          'description': 'Schedule interviews for qualified candidates',
          'due_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          'priority': 'medium',
        },
      ],
      upcomingDeadlines: [
        {
          'id': '1',
          'title': 'Monthly Placement Report',
          'date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
          'type': 'report',
        },
      ],
    );
  }

  DashboardData _generateSupervisorDashboardData(UserModel.User user) {
    return DashboardData(
      stats: {
        'assigned_interns': '5',
        'active_projects': '3',
        'pending_evaluations': '2',
        'completed_tasks': '28',
      },
      recentActivities: [
        {
          'id': '1',
          'type': 'task',
          'title': 'Task Reviewed',
          'description': 'Reviewed database optimization task by Jane Smith',
          'timestamp': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
          'status': 'completed',
        },
        {
          'id': '2',
          'type': 'meeting',
          'title': 'Weekly Check-in',
          'description': 'Conducted weekly progress meeting with interns',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'status': 'completed',
        },
      ],
      pendingTasks: [
        {
          'id': '1',
          'title': 'Evaluate Performance',
          'description': 'Complete performance evaluations for 2 interns',
          'due_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
          'priority': 'high',
        },
        {
          'id': '2',
          'title': 'Assign New Tasks',
          'description': 'Assign new development tasks to interns',
          'due_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'priority': 'medium',
        },
      ],
      upcomingDeadlines: [
        {
          'id': '1',
          'title': 'Project Milestone',
          'date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
          'type': 'project',
        },
      ],
    );
  }

  DashboardData _generateAdminDashboardData(UserModel.User user) {
    return DashboardData(
      stats: {
        'total_users': '234',
        'active_internships': '89',
        'system_health': '98%',
        'pending_approvals': '12',
      },
      recentActivities: [
        {
          'id': '1',
          'type': 'system',
          'title': 'New User Registered',
          'description': 'Sarah Wilson registered as a student',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'status': 'completed',
        },
        {
          'id': '2',
          'type': 'approval',
          'title': 'Placement Approved',
          'description': 'Approved internship placement for Mike Johnson',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          'status': 'completed',
        },
      ],
      pendingTasks: [
        {
          'id': '1',
          'title': 'Review System Logs',
          'description': 'Review recent system activity and error logs',
          'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'priority': 'medium',
        },
        {
          'id': '2',
          'title': 'Approve Pending Applications',
          'description': 'Review and approve 12 pending internship applications',
          'due_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          'priority': 'high',
        },
      ],
      upcomingDeadlines: [
        {
          'id': '1',
          'title': 'Quarterly Report',
          'date': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
          'type': 'report',
        },
      ],
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
