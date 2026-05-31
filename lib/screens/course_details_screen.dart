import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../state/app_state.dart';
import '../services/phonepe_service.dart';
import '../services/certificate_service.dart';
import 'lesson_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final course = appState.selectedCourse;

    if (course == null) {
      return const Scaffold(
        body: Center(child: Text('No course selected')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        course.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      // Overlay Dark Gradient for readibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ];
          },
          body: Column(
            children: [
              // Course metadata header block
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.category,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(course.instructorImageUrl),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          course.instructor,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // TabBar
              TabBar(
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Curriculum'),
                ],
              ),

              // TabBarView Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAboutTab(context, theme, course),
                    _buildCurriculumTab(context, theme, appState),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomStickyBar(context, theme, appState),
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, ThemeData theme, dynamic course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAboutStat(Icons.schedule, course.duration, 'Duration', theme),
              _buildAboutStat(Icons.play_circle_outline, '${course.totalLessons} Lessons', 'Structure', theme),
              _buildAboutStat(Icons.bar_chart, course.difficulty, 'Level', theme),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'About this course',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            course.description,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Instructor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(course.instructorImageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.instructor,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senior Specialist & Educator. Over 10 years of industrial research and product construction experience.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (course.isEnrolled && course.progressPercent >= 1.0) ...[
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final appState = Provider.of<AppState>(context, listen: false);
                  CertificateService.generateAndShowCertificate(
                    context: context,
                    studentName: appState.currentUserName ?? 'Student',
                    courseTitle: course.title,
                    instructorName: course.instructor,
                  );
                },
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Claim Certificate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutStat(IconData icon, String value, String label, ThemeData theme) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumTab(BuildContext context, ThemeData theme, AppState appState) {
    final course = appState.selectedCourse!;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: course.lessons.length,
      itemBuilder: (context, index) {
        final lesson = course.lessons[index];
        
        Color leadingColor;
        IconData leadingIcon;

        if (lesson.isLocked) {
          leadingColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
          leadingIcon = Icons.lock_outline;
        } else if (lesson.isCompleted) {
          leadingColor = Colors.teal;
          leadingIcon = Icons.check_circle;
        } else {
          leadingColor = theme.colorScheme.primary;
          leadingIcon = Icons.play_arrow_outlined;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: lesson.isLocked ? Colors.transparent : theme.colorScheme.onSurface.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: lesson.isLocked
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                  : theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
          child: ListTile(
            enabled: !lesson.isLocked,
            onTap: () {
              appState.selectLesson(lesson);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LessonScreen()),
              );
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: leadingColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(leadingIcon, color: leadingColor, size: 20),
            ),
            title: Text(
              lesson.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: lesson.isLocked ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : null,
              ),
            ),
            subtitle: Text(
              lesson.duration,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            trailing: lesson.isLocked
                ? null
                : Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBottomStickyBar(BuildContext context, ThemeData theme, AppState appState) {
    final course = appState.selectedCourse!;
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          top: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        child: course.isEnrolled
            ? ElevatedButton(
                onPressed: () {
                  // Find the next incomplete lesson
                  final nextLesson = course.lessons.firstWhere(
                    (l) => !l.isCompleted && !l.isLocked,
                    orElse: () => course.lessons.first,
                  );
                  appState.selectLesson(nextLesson);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LessonScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Continue Learning',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            : Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Lifetime Access',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        course.price == 0.0 ? 'Free' : '₹${course.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (course.price == 0.0) {
                          // Free course, bypass payment
                          appState.enrollInCourse(course.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Successfully enrolled for free!'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        } else {
                          // Trigger PhonePe Payment via secure Node.js Backend
                          final user = FirebaseAuth.instance.currentUser;
                          final token = user != null ? await user.getIdToken() : '';
                          
                          bool isSuccess = await PhonePeService.startTransaction(
                            context: context,
                            amount: course.price.toInt().toString(),
                            transactionId: "TXN_\${DateTime.now().millisecondsSinceEpoch}",
                            token: token ?? '',
                          );

                          if (!context.mounted) return;

                          if (isSuccess) {
                            appState.enrollInCourse(course.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment Successful! Enrolled successfully!'),
                                backgroundColor: Colors.teal,
                              ),
                            );
                          } else if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Payment Cancelled or Failed.'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        course.price == 0.0 ? 'Enroll for Free' : 'Pay & Enroll',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
