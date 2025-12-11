class DashboardData {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> pendingTasks;
  final List<Map<String, dynamic>> upcomingDeadlines;
  final Map<String, dynamic>? attendanceSummary;
  final List<Map<String, dynamic>>? evaluations;

  DashboardData({
    required this.stats,
    required this.recentActivities,
    required this.pendingTasks,
    required this.upcomingDeadlines,
    this.attendanceSummary,
    this.evaluations,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: Map<String, dynamic>.from(json['stats']),
      recentActivities: List<Map<String, dynamic>>.from(json['recent_activities']),
      pendingTasks: List<Map<String, dynamic>>.from(json['pending_tasks']),
      upcomingDeadlines: List<Map<String, dynamic>>.from(json['upcoming_deadlines']),
      attendanceSummary: json['attendance_summary'] != null 
          ? Map<String, dynamic>.from(json['attendance_summary']) 
          : null,
      evaluations: json['evaluations'] != null 
          ? List<Map<String, dynamic>>.from(json['evaluations']) 
          : null,
    );
  }
}