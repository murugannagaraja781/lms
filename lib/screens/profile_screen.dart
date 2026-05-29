import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'superadmin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final name = appState.currentUserName ?? 'Student';
    final email = appState.currentUserEmail ?? 'student@edusphere.com';

    // Calculate Dynamic Badges
    final hasEnrolled = appState.enrolledCourses.isNotEmpty;
    final finishedLessons = appState.totalCompletedLessons;
    final hasFinishedLesson = finishedLessons > 0;
    
    // Check if user passed any quiz
    bool passedAnyQuiz = false;
    for (var c in appState.enrolledCourses) {
      for (var l in c.lessons) {
        if (l.quiz != null && l.quiz!.isCompleted && l.quiz!.isPassed) {
          passedAnyQuiz = true;
          break;
        }
      }
    }

    bool completedCourse = appState.enrolledCourses.any((c) => c.progressPercent >= 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Portfolio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User profile header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Streak badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  '5 Days Learning Streak',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _showEditProfileDialog(context, appState, name),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Enrolled',
                      value: '${appState.enrolledCourses.length}',
                      icon: Icons.book_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Completed',
                      value: '$finishedLessons',
                      icon: Icons.check_circle_outline,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Badges & Achievements
              const Text(
                'Earned Badges',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildBadge('First Step', Icons.flag_outlined, hasEnrolled, theme),
                    _buildBadge('Speed Demon', Icons.bolt, hasFinishedLesson, theme),
                    _buildBadge('Brainiac', Icons.psychology_outlined, passedAnyQuiz, theme),
                    _buildBadge('Scholar Guru', Icons.workspace_premium_outlined, completedCourse, theme),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Settings Card List
              const Text(
                'Settings & Security',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      // Theme toggle
                      ListTile(
                        leading: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                        title: const Text('Theme Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(appState.isDarkMode ? 'Dark Theme Active' : 'Light Theme Active', style: const TextStyle(fontSize: 11)),
                        trailing: Switch(
                          value: appState.isDarkMode,
                          onChanged: (val) => appState.toggleTheme(),
                        ),
                      ),
                      Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), height: 1),
                      // Super Admin Console
                      if (appState.isSuperAdmin)
                        ListTile(
                          leading: Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary),
                          title: const Text('Super Admin Console', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: const Text('Manage overall platform & users', style: TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperAdminDashboardScreen()));
                          },
                        ),
                      if (appState.isSuperAdmin)
                        Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), height: 1),
                      // Admin/Teacher Console
                      if (appState.isAdmin && !appState.isSuperAdmin)
                        ListTile(
                          leading: Icon(Icons.co_present, color: theme.colorScheme.primary),
                          title: const Text('Teacher Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: const Text('Manage your courses & content', style: TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                          },
                        ),
                      if (appState.isAdmin && !appState.isSuperAdmin)
                        Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), height: 1),
                      // Edit Profile
                      ListTile(
                        leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                        title: const Text('Edit Account Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {},
                      ),
                      Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), height: 1),
                      // Help
                      ListTile(
                        leading: Icon(Icons.help_outline, color: theme.colorScheme.primary),
                        title: const Text('Help Center', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {},
                      ),
                      Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), height: 1),
                      // Sign out
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                        onTap: () {
                          appState.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String title, IconData icon, bool isUnlocked, ThemeData theme) {
    final activeColor = isUnlocked ? theme.colorScheme.primary : Colors.grey.shade400;
    
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isUnlocked ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.onSurface.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: activeColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppState appState, String currentName) {
    final nameController = TextEditingController(text: currentName);
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: 'Display Name',
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      label: 'New Password (Optional)',
                      prefixIcon: Icons.lock,
                      isPassword: true,
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
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          try {
                            if (nameController.text.trim().isNotEmpty && nameController.text.trim() != currentName) {
                              await appState.updateUserProfile(nameController.text.trim());
                            }
                            if (passwordController.text.isNotEmpty) {
                              if (passwordController.text.length < 6) {
                                throw Exception('Password must be at least 6 characters');
                              }
                              await appState.updateUserPassword(passwordController.text);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
