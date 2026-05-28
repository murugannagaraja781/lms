import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/course_card.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final enrolled = appState.enrolledCourses;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Learning',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: enrolled.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu_book_outlined,
                          size: 72,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Enrolled Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You haven\'t enrolled in any courses yet. Browse the catalog on the Explore tab and jumpstart your skills!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: enrolled.length,
                itemBuilder: (context, index) {
                  final course = enrolled[index];
                  return CourseCard(course: course, isHorizontal: false);
                },
              ),
      ),
    );
  }
}
