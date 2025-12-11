const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const pool = require('../database/db');
const { authenticateToken } = require('../middleware/auth');

// Get dashboard data based on user role
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const userRole = req.user.role;

    // Get user info
    const userResult = await pool.query(
      'SELECT id, name, email, role, department, id_number FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];
    let dashboardData = {};

    switch (userRole) {
      case 'student':
        dashboardData = await getStudentDashboard(userId);
        break;
      case 'coordinator':
        dashboardData = await getCoordinatorDashboard(userId);
        break;
      case 'supervisor':
        dashboardData = await getSupervisorDashboard(userId);
        break;
      case 'admin':
        dashboardData = await getAdminDashboard(userId);
        break;
      default:
        return res.status(400).json({ error: 'Invalid user role' });
    }

    res.json(dashboardData);
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Student dashboard data
async function getStudentDashboard(userId) {
  // Get attendance summary
  const attendanceResult = await pool.query(`
    SELECT
      COUNT(*) as total_days,
      COUNT(CASE WHEN status = 'present' THEN 1 END) as present_days,
      COUNT(CASE WHEN status = 'absent' THEN 1 END) as absent_days,
      COUNT(CASE WHEN status = 'late' THEN 1 END) as late_days
    FROM attendance_logs
    WHERE student_id = $1 AND DATE(created_at) >= DATE('now', '-30 days')
  `, [userId]);

  const attendance = attendanceResult.rows[0];
  const totalDays = parseInt(attendance.total_days) || 0;
  const presentDays = parseInt(attendance.present_days) || 0;
  const percentage = totalDays > 0 ? Math.round((presentDays / totalDays) * 100) : 0;

  // Get pending tasks
  const tasksResult = await pool.query(`
    SELECT COUNT(*) as pending_tasks
    FROM tasks
    WHERE assigned_to = $1 AND status = 'pending' AND due_date >= CURRENT_DATE
  `, [userId]);

  // Get completed tasks this month
  const completedTasksResult = await pool.query(`
    SELECT COUNT(*) as completed_tasks
    FROM tasks
    WHERE assigned_to = $1 AND status = 'completed'
    AND DATE(completed_at) >= DATE('now', '-30 days')
  `, [userId]);

  // Get recent activities
  const activitiesResult = await pool.query(`
    SELECT
      id,
      'task' as type,
      title,
      description,
      created_at as timestamp,
      status
    FROM tasks
    WHERE assigned_to = $1
    ORDER BY created_at DESC
    LIMIT 5
  `, [userId]);

  // Get pending tasks details
  const pendingTasksResult = await pool.query(`
    SELECT
      id,
      title,
      description,
      due_date,
      priority,
      created_at
    FROM tasks
    WHERE assigned_to = $1 AND status = 'pending' AND due_date >= CURRENT_DATE
    ORDER BY due_date ASC
    LIMIT 5
  `, [userId]);

  // Get upcoming deadlines
  const deadlinesResult = await pool.query(`
    SELECT
      id,
      title,
      due_date as date,
      'task' as type
    FROM tasks
    WHERE assigned_to = $1 AND status = 'pending' AND due_date >= CURRENT_DATE
    ORDER BY due_date ASC
    LIMIT 3
  `, [userId]);

  // Get evaluations
  const evaluationsResult = await pool.query(`
    SELECT
      e.id,
      u.name as evaluator,
      u.role as evaluator_role,
      e.rating,
      e.comments,
      e.created_at as date
    FROM evaluations e
    JOIN users u ON e.evaluator_id = u.id
    WHERE e.student_id = $1
    ORDER BY e.created_at DESC
    LIMIT 3
  `, [userId]);

  return {
    stats: {
      attendance_percentage: totalDays > 0 ? `${percentage}%` : '0%',
      pending_tasks: tasksResult.rows[0].pending_tasks || '0',
      completed_tasks: completedTasksResult.rows[0].completed_tasks || '0',
      upcoming_deadlines: deadlinesResult.rows.length.toString(),
    },
    recentActivities: activitiesResult.rows.map(activity => ({
      id: activity.id.toString(),
      type: activity.type,
      title: activity.title,
      description: activity.description,
      timestamp: activity.timestamp.toISOString(),
      status: activity.status,
    })),
    pendingTasks: pendingTasksResult.rows.map(task => ({
      id: task.id.toString(),
      title: task.title,
      description: task.description,
      due_date: task.due_date.toISOString(),
      priority: task.priority,
    })),
    upcomingDeadlines: deadlinesResult.rows.map(deadline => ({
      id: deadline.id.toString(),
      title: deadline.title,
      date: deadline.date.toISOString(),
      type: deadline.type,
    })),
    attendanceSummary: totalDays > 0 ? {
      total_days: totalDays,
      present_days: presentDays,
      absent_days: parseInt(attendance.absent_days) || 0,
      late_days: parseInt(attendance.late_days) || 0,
      percentage: percentage,
    } : null,
    evaluations: evaluationsResult.rows.map(evaluation => ({
      id: evaluation.id.toString(),
      evaluator: evaluation.evaluator,
      role: evaluation.evaluator_role,
      rating: parseFloat(evaluation.rating),
      comments: evaluation.comments,
      date: evaluation.date.toISOString(),
    })),
  };
}

// Coordinator dashboard data
async function getCoordinatorDashboard(userId) {
  // Get placement statistics
  const placementsResult = await pool.query(`
    SELECT
      COUNT(*) as total_students,
      COUNT(CASE WHEN status = 'placed' THEN 1 END) as placed_students,
      COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_students
    FROM student_placements
    WHERE coordinator_id = $1
  `, [userId]);

  const placements = placementsResult.rows[0];

  // Get recent activities
  const activitiesResult = await pool.query(`
    SELECT
      'placement' as type,
      CONCAT('Student ', sp.student_name, ' placed at ', sp.company_name) as title,
      sp.description,
      sp.created_at as timestamp,
      'completed' as status
    FROM student_placements sp
    WHERE sp.coordinator_id = $1
    ORDER BY sp.created_at DESC
    LIMIT 5
  `, [userId]);

  // Get pending tasks
  const pendingTasksResult = await pool.query(`
    SELECT
      id,
      title,
      description,
      due_date,
      priority
    FROM coordinator_tasks
    WHERE assigned_to = $1 AND status = 'pending'
    ORDER BY due_date ASC
    LIMIT 5
  `, [userId]);

  return {
    stats: {
      total_students: placements.total_students || '0',
      active_placements: placements.placed_students || '0',
      pending_applications: placements.pending_students || '0',
      completed_internships: '0', // Would need more complex query
    },
    recentActivities: activitiesResult.rows.map(activity => ({
      id: Math.random().toString(),
      type: activity.type,
      title: activity.title,
      description: activity.description,
      timestamp: activity.timestamp.toISOString(),
      status: activity.status,
    })),
    pendingTasks: pendingTasksResult.rows.map(task => ({
      id: task.id.toString(),
      title: task.title,
      description: task.description,
      due_date: task.due_date.toISOString(),
      priority: task.priority,
    })),
    upcomingDeadlines: [], // Add coordinator-specific deadlines
  };
}

// Supervisor dashboard data
async function getSupervisorDashboard(userId) {
  // Get intern statistics
  const internsResult = await pool.query(`
    SELECT COUNT(*) as total_interns
    FROM supervisor_interns
    WHERE supervisor_id = $1
  `, [userId]);

  // Get pending evaluations
  const evaluationsResult = await pool.query(`
    SELECT COUNT(*) as pending_evaluations
    FROM evaluations
    WHERE evaluator_id = $1 AND status = 'pending'
  `, [userId]);

  // Get active projects
  const projectsResult = await pool.query(`
    SELECT COUNT(*) as active_projects
    FROM projects
    WHERE supervisor_id = $1 AND status = 'active'
  `, [userId]);

  // Get recent activities
  const activitiesResult = await pool.query(`
    SELECT
      'task' as type,
      title,
      description,
      created_at as timestamp,
      status
    FROM tasks
    WHERE created_by = $1 OR assigned_to IN (
      SELECT student_id FROM supervisor_interns WHERE supervisor_id = $1
    )
    ORDER BY created_at DESC
    LIMIT 5
  `, [userId]);

  return {
    stats: {
      assigned_interns: internsResult.rows[0].total_interns || '0',
      active_projects: projectsResult.rows[0].active_projects || '0',
      pending_evaluations: evaluationsResult.rows[0].pending_evaluations || '0',
      completed_tasks: '0', // Would need more complex tracking
    },
    recentActivities: activitiesResult.rows.map(activity => ({
      id: Math.random().toString(),
      type: activity.type,
      title: activity.title,
      description: activity.description,
      timestamp: activity.timestamp.toISOString(),
      status: activity.status,
    })),
    pendingTasks: [], // Add supervisor-specific tasks
    upcomingDeadlines: [], // Add project deadlines
  };
}

// Admin dashboard data
async function getAdminDashboard(userId) {
  // Get system statistics
  const usersResult = await pool.query('SELECT COUNT(*) as total_users FROM users WHERE is_active = true');
  const internshipsResult = await pool.query('SELECT COUNT(*) as active_internships FROM student_placements WHERE status = \'active\'');
  const pendingApprovalsResult = await pool.query('SELECT COUNT(*) as pending_approvals FROM approval_requests WHERE status = \'pending\'');

  // Get recent activities
  const activitiesResult = await pool.query(`
    SELECT
      'user' as type,
      CONCAT('New user registered: ', name) as title,
      CONCAT('Email: ', email) as description,
      created_at as timestamp,
      'completed' as status
    FROM users
    WHERE role != 'admin'
    ORDER BY created_at DESC
    LIMIT 5
  `);

  return {
    stats: {
      total_users: usersResult.rows[0].total_users || '0',
      active_internships: internshipsResult.rows[0].active_internships || '0',
      system_health: '98%', // Mock system health
      pending_approvals: pendingApprovalsResult.rows[0].pending_approvals || '0',
    },
    recentActivities: activitiesResult.rows.map(activity => ({
      id: Math.random().toString(),
      type: activity.type,
      title: activity.title,
      description: activity.description,
      timestamp: activity.timestamp.toISOString(),
      status: activity.status,
    })),
    pendingTasks: [], // Add admin-specific tasks
    upcomingDeadlines: [], // Add system deadlines
  };
}

module.exports = router;
