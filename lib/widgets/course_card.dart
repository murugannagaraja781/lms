import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../state/app_state.dart';
import '../screens/course_details_screen.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isHorizontal;

  const CourseCard({
    super.key,
    required this.course,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    Widget buildCardContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image & Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  course.imageUrl,
                  height: isHorizontal ? 120 : 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: isHorizontal ? 120 : 160,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.broken_image, color: theme.colorScheme.primary),
                  ),
                ),
              ),
              // Category Chip
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Rating Badge
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      course.difficulty,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      course.duration,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(course.instructorImageUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        course.instructor,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),

                // Enrollment Progress or Stats
                if (course.isEnrolled) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: course.progressPercent,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(course.progressPercent * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.enrolledCount} students',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        appState.selectCourse(course);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CourseDetailsScreen()),
        );
      },
      child: Container(
        width: isHorizontal ? 260 : double.infinity,
        margin: isHorizontal
            ? const EdgeInsets.only(right: 16, bottom: 8)
            : const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: appState.isDarkMode ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: appState.isDarkMode
                ? const Color(0xFF28253B)
                : Colors.grey.shade100,
          ),
        ),
        child: buildCardContent(),
      ),
    );
  }
}
