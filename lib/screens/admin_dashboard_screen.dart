import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

import '../state/app_state.dart';
import 'admin_add_course_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final courses = appState.courses;

    // Calculate Admin stats
    int totalLearners = 0;
    for (var c in courses) {
      totalLearners += c.enrolledCount;
    }

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
        appBar: AppBar(
          title: const Text(
            'Admin Console',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          automaticallyImplyLeading: false,
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics Section Title
              const Text(
                'LMS Analytics Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildStatTile('Total Courses', '${courses.length}', Icons.import_contacts, Colors.blue, theme),
                  _buildStatTile('Learners', '$totalLearners', Icons.people_outline, Colors.teal, theme),
                  _buildStatTile('Completion Rate', '74%', Icons.check_circle_outline, Colors.purple, theme),
                  _buildStatTile('Revenue', 'Free App', Icons.monetization_on_outlined, Colors.orange, theme),
                ],
              ),
              const SizedBox(height: 28),

              // Pending Q&A Section
              if (appState.getUnreadAdminComments().isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pending Q&A',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${appState.getUnreadAdminComments().length} New',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.getUnreadAdminComments().length,
                  itemBuilder: (context, index) {
                    final comment = appState.getUnreadAdminComments()[index];
                    final replyController = TextEditingController();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                comment.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            comment.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: replyController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Type your reply...',
                                    hintStyle: const TextStyle(fontSize: 13),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (replyController.text.trim().isNotEmpty) {
                                    appState.replyToComment(comment.id, replyController.text.trim());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(60, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],

              // Registered Users Section
              if (appState.registeredUsers.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registered Students',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${appState.registeredUsers.length} Total',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.registeredUsers.length,
                  itemBuilder: (context, index) {
                    final user = appState.registeredUsers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                        title: Text(user['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(user['email'] ?? 'No email', style: const TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],

              // Course Inventory Management Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Course Inventory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${courses.length} Active',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Inventory Listing
              if (courses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'Inventory is empty. Add your first course!',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            course.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.broken_image, color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        title: Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Instructor: ${course.instructor}', style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('Category: ${course.category} • ${course.lessons.length} Modules', style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, appState, course.id, course.title),
                        ),
                      ),
                    );
                  },
                ),
            const SizedBox(height: 20),
            // Footer Logout Button
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
                label: const Text('Admin Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
            heroTag: 'add_live_class',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminAddCourseScreen(initialIsLiveClass: true)),
              );
            },
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.videocam),
            label: const Text('Add Live Class', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_course',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminAddCourseScreen(initialIsLiveClass: false)),
              );
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.library_add),
            label: const Text('Add Course', style: TextStyle(fontWeight: FontWeight.bold)),
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
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, String courseId, String courseTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "$courseTitle" from the catalog? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.deleteCourse(courseId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Course deleted from inventory.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
