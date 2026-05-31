import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/course_card.dart';
import '../widgets/custom_widgets.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final userName = appState.currentUserName ?? 'Student';
    final categories = appState.categories;

    return Scaffold(
      backgroundColor: Colors.orange.withValues(alpha: 0.05), // Distinct orange tint for Student Dashboard
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile & Welcome Row
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back 👋',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Circular Progress Indicator for overall progress
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: appState.overallProgress,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            color: theme.colorScheme.primary,
                            strokeWidth: 3,
                          ),
                          Text(
                            '${(appState.overallProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              TextField(
                onChanged: (val) => appState.updateSearch(val),
                decoration: InputDecoration(
                  hintText: 'Search courses, instructors...',
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.04)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category Selector
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return CategoryChip(
                      label: cat,
                      isSelected: appState.selectedCategory == cat,
                      onTap: () => appState.selectCategory(cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Continue Learning Section (Only show if user has enrolled courses)
              if (appState.enrolledCourses.isNotEmpty) ...[
                const Text(
                  'Continue Learning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: appState.enrolledCourses.length,
                    itemBuilder: (context, index) {
                      final course = appState.enrolledCourses[index];
                      return CourseCard(course: course, isHorizontal: true);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Explore Courses Section
              Row(
                children: [
                  const Text(
                    'Explore Courses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${appState.filteredCourses.length} courses',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List of Filtered Courses
              if (appState.filteredCourses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'No courses match your query.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = appState.filteredCourses[index];
                    return CourseCard(course: course, isHorizontal: false);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
