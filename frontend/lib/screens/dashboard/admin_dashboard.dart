import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('View Profile'),
                ),
              ),
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
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.purple,
                      child: Icon(
                        Icons.admin_panel_settings,
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
                          const Text(
                            'System Administrator',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const Text(
                            'Last login: Today, 9:00 AM',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.monitor_heart),
                      label: const Text('Live Monitor'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // System Stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total Users', '156', Icons.people, Colors.blue),
                _buildStatCard('Students', '120', Icons.school, Colors.green),
                _buildStatCard('Coordinators', '12', Icons.supervisor_account, Colors.orange),
                _buildStatCard('Supervisors', '24', Icons.business, Colors.purple),
                _buildStatCard('Companies', '45', Icons.business, Colors.teal),
                _buildStatCard('Active', '89', Icons.work, Colors.indigo),
                _buildStatCard('Storage', '2.4GB', Icons.storage, Colors.red),
                _buildStatCard('Uptime', '99.9%', Icons.timer, Colors.cyan),
              ],
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
                        _buildActionButton('Backup', Icons.backup, Colors.blue),
                        _buildActionButton('Restore', Icons.settings_backup_restore, Colors.orange),
                        _buildActionButton('Broadcast', Icons.email, Colors.green),
                        _buildActionButton('Security', Icons.security, Colors.red),
                        _buildActionButton('Logs', Icons.list_alt, Colors.purple),
                        _buildActionButton('Reports', Icons.report, Colors.teal),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recent Users
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Users',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manage Users'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('John Smith')),
                          const DataCell(Text('john@imts.edu')),
                          const DataCell(Chip(label: Text('Student'))),
                          DataCell(Chip(
                            label: const Text('Active'),
                            backgroundColor: Colors.green.withOpacity(0.2),
                          )),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Jane Doe')),
                          const DataCell(Text('jane@imts.edu')),
                          const DataCell(Chip(label: Text('Coordinator'))),
                          DataCell(Chip(
                            label: const Text('Active'),
                            backgroundColor: Colors.green.withOpacity(0.2),
                          )),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Bob Wilson')),
                          const DataCell(Text('bob@imts.edu')),
                          const DataCell(Chip(label: Text('Supervisor'))),
                          DataCell(Chip(
                            label: const Text('Inactive'),
                            backgroundColor: Colors.red.withOpacity(0.2),
                          )),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // System Alerts
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.warning, color: Colors.orange),
                      title: Text('Storage Warning'),
                      subtitle: Text('Storage is at 85% capacity'),
                      trailing: Text('2h ago'),
                    ),
                    ListTile(
                      leading: Icon(Icons.info, color: Colors.blue),
                      title: Text('System Update'),
                      subtitle: Text('New version available'),
                      trailing: Text('1d ago'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
      ),
    );
  }
}
