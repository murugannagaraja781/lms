import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state/app_state.dart';
import 'login_screen.dart';
import 'create_admin_screen.dart';
import 'create_student_screen.dart';
import 'manage_categories_screen.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final students = appState.studentList;
    final admins = appState.adminList;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.red.withValues(alpha: 0.05), // Distinct red tint for Super Admin Dashboard
        appBar: AppBar(
          title: const Text('Super Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              appState.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => appState.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${appState.currentUserName} 👑',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Platform Statistics
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  _buildStatTile('Total Income', '₹${appState.totalPlatformIncome.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.green, theme),
                  _buildStatTile('Total Students', '${students.length}', Icons.people, Colors.blue, theme),
                  _buildStatTile('Total Admins', '${admins.length}', Icons.admin_panel_settings, Colors.purple, theme),
                  _buildStatTile('Total Courses', '${appState.courses.length}', Icons.library_books, Colors.orange, theme),
                ],
              ),
              const SizedBox(height: 32),

              // Advanced Analytics Section
              const Text(
                'Platform Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Revenue Bar Chart (Simulated last 6 months)
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue (Last 6 Months)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20000,
                          barTouchData: const BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0: text = const Text('Jan', style: style); break;
                                    case 1: text = const Text('Feb', style: style); break;
                                    case 2: text = const Text('Mar', style: style); break;
                                    case 3: text = const Text('Apr', style: style); break;
                                    case 4: text = const Text('May', style: style); break;
                                    case 5: text = const Text('Jun', style: style); break;
                                    default: text = const Text('', style: style); break;
                                  }
                                  return Padding(padding: const EdgeInsets.only(top: 8.0), child: text);
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5000, color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8000, color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 6000, color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 12000, color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 15000, color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: appState.totalPlatformIncome > 0 ? appState.totalPlatformIncome : 18000, color: theme.colorScheme.primary, width: 12, borderRadius: BorderRadius.circular(4))]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Course Distribution Pie Chart
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: Colors.blue,
                              value: (appState.courses.where((c) => c.price == 0).length).toDouble().clamp(1.0, 100.0), // Prevent 0 size error
                              title: 'Free',
                              radius: 40,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.orange,
                              value: (appState.courses.where((c) => c.price > 0).length).toDouble().clamp(1.0, 100.0),
                              title: 'Paid',
                              radius: 40,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Course Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.blue, size: 12),
                              SizedBox(width: 4),
                              Text('Free Courses', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.orange, size: 12),
                              SizedBox(width: 4),
                              Text('Premium Courses', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Admins List
              const Text(
                'Platform Admins',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (admins.isEmpty)
                Text('No admins found.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: 0,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.withValues(alpha: 0.1),
                          child: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                        ),
                        title: Text(admin['name'] ?? 'Unknown Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(admin['email'] ?? ''),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),

              // Students List
              const Text(
                'Registered Students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (students.isEmpty)
                Text('No students found.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: 0,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(student['name'] ?? 'Unknown Student', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(student['email'] ?? ''),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              
              // Logout Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    appState.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Super Admin Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manage_categories',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
              );
            },
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.category),
            label: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_student',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateStudentScreen()),
              );
            },
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Student', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_admin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateAdminScreen()),
              );
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Add Staff/Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
