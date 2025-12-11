import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDashboardData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);

    if (authProvider.user != null && authProvider.token != null) {
      dashboardProvider.fetchDashboardData(authProvider.user!, authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'S',
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Attendance'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Documents'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                    Tab(icon: Icon(Icons.person), text: 'Profile'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(dashboardProvider, user),
                      _buildProfileTab(user, authProvider),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new log
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildAttendanceItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab(DashboardProvider dashboardProvider, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Student | ${user?.department ?? 'Computer Science'}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          'ID: ${user?.idNumber ?? 'STU001'}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stats Cards
          if (dashboardProvider.dashboardData?.stats != null)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: 'Attendance',
                  value: dashboardProvider.dashboardData!.stats['attendance_percentage'] ?? '0%',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Pending Tasks',
                  value: dashboardProvider.dashboardData!.stats['pending_tasks'] ?? '0',
                  icon: Icons.task,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Completed',
                  value: dashboardProvider.dashboardData!.stats['completed_tasks'] ?? '0',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Deadlines',
                  value: dashboardProvider.dashboardData!.stats['upcoming_deadlines'] ?? '0',
                  icon: Icons.schedule,
                  color: Colors.red,
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Pending Tasks
          if (dashboardProvider.dashboardData?.pendingTasks.isNotEmpty ?? false)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...dashboardProvider.dashboardData!.pendingTasks.map((task) {
                      final dueDate = DateTime.parse(task['due_date']);
                      final isUrgent = task['priority'] == 'high';
                      final daysLeft = dueDate.difference(DateTime.now()).inDays;

                      return ListTile(
                        leading: Icon(
                          isUrgent ? Icons.warning : Icons.task,
                          color: isUrgent ? Colors.red : Colors.orange,
                        ),
                        title: Text(task['title']),
                        subtitle: Text(
                          '${task['description']}\nDue: ${dueDate.toString().substring(0, 10)} (${daysLeft <= 0 ? 'Overdue' : '$daysLeft days left'})',
                        ),
                        trailing: Icon(
                          isUrgent ? Icons.priority_high : Icons.arrow_forward,
                          color: isUrgent ? Colors.red : Colors.grey,
                        ),
                        onTap: () {
                          // Navigate to task details
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        label: 'Submit Log',
                        onPressed: () {},
                        color: Colors.green,
                      ),
                      _buildActionButton(
                        icon: Icons.upload,
                        label: 'Upload Doc',
                        onPressed: () {},
                        color: Colors.blue,
                      ),
                      _buildActionButton(
                        icon: Icons.announcement,
                        label: 'Announcements',
                        onPressed: () {},
                        color: Colors.purple,
                      ),
                      _buildActionButton(
                        icon: Icons.task,
                        label: 'View Tasks',
                        onPressed: () {},
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Activities
          if (dashboardProvider.dashboardData?.recentActivities.isNotEmpty ?? false)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...dashboardProvider.dashboardData!.recentActivities.map((activity) {
                      final timestamp = DateTime.parse(activity['timestamp']);
                      final timeAgo = _getTimeAgo(timestamp);

                      IconData icon;
                      Color color;
                      switch (activity['type']) {
                        case 'attendance':
                          icon = Icons.calendar_today;
                          color = Colors.blue;
                          break;
                        case 'task':
                          icon = Icons.task;
                          color = Colors.orange;
                          break;
                        case 'evaluation':
                          icon = Icons.star;
                          color = Colors.purple;
                          break;
                        default:
                          icon = Icons.info;
                          color = Colors.grey;
                      }

                      return ListTile(
                        leading: Icon(icon, color: color),
                        title: Text(activity['title']),
                        subtitle: Text('${activity['description']}\n$timeAgo'),
                        trailing: Text(
                          activity['status'] ?? '',
                          style: TextStyle(
                            color: activity['status'] == 'completed' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // Attendance Summary
          if (dashboardProvider.dashboardData?.attendanceSummary != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAttendanceItem(
                            'Present',
                            dashboardProvider.dashboardData!.attendanceSummary!['present_days'].toString(),
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildAttendanceItem(
                            'Absent',
                            dashboardProvider.dashboardData!.attendanceSummary!['absent_days'].toString(),
                            Colors.red,
                          ),
                        ),
                        Expanded(
                          child: _buildAttendanceItem(
                            'Late',
                            dashboardProvider.dashboardData!.attendanceSummary!['late_days'].toString(),
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Overall Attendance: ${dashboardProvider.dashboardData!.attendanceSummary!['percentage']}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(user, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Picture Section
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'S',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // Implement image picker
                        _showImagePickerDialog();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Full Name'),
                    subtitle: Text(user?.name ?? 'Not provided'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? 'Not provided'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Student ID'),
                    subtitle: Text(user?.idNumber ?? 'Not provided'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Department'),
                    subtitle: Text(user?.department ?? 'Not provided'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone'),
                    subtitle: Text(user?.phone ?? 'Not provided'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text('Role'),
                    subtitle: Text(user?.role.toUpperCase() ?? 'STUDENT'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Member Since'),
                    subtitle: Text(
                      user?.createdAt?.toString().substring(0, 10) ?? 'Unknown',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Last Login'),
                    subtitle: Text(
                      user?.lastLogin?.toString().substring(0, 19) ?? 'Never',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Account Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showEditProfileDialog,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _showDeleteConfirmation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: const Text('Choose an option to update your profile picture.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement camera capture
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera functionality coming soon!')),
              );
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              // Implement gallery picker
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gallery picker functionality coming soon!')),
              );
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmNewPasswordController = TextEditingController();
    final _passwordFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: _passwordFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                  if (!passwordRegex.hasMatch(value)) {
                    return 'Password must contain uppercase, lowercase, number, and special character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_passwordFormKey.currentState!.validate()) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.changePassword(
                  _currentPasswordController.text,
                  _newPasswordController.text,
                );

                Navigator.pop(context); // Close dialog

                if (success) {
                  // Show success message and logout
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully. Please login with your new password.'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Auto logout after password change
                  await Future.delayed(const Duration(seconds: 2));
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.error ?? 'Failed to change password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    final _nameController = TextEditingController(text: currentUser?.name ?? '');
    final _phoneController = TextEditingController(text: currentUser?.phone ?? '');
    final _departmentController = TextEditingController(text: currentUser?.department ?? '');
    final _profileFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: _profileFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_profileFormKey.currentState!.validate()) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.updateProfile({
                  'name': _nameController.text.trim(),
                  'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                  'department': _departmentController.text.trim(),
                });

                Navigator.pop(context); // Close dialog

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Refresh dashboard data
                  _loadDashboardData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.error ?? 'Failed to update profile'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.deleteAccount();

    if (success) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to delete account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
