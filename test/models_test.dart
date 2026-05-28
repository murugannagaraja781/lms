import 'package:flutter_test/flutter_test.dart';
import 'package:lms/models/course.dart';
import 'package:lms/models/lesson.dart';

void main() {
  group('Model Tests', () {
    test('Lesson.fromMap parses correctly', () {
      final map = {
        'id': 'lesson_1',
        'title': 'Test Lesson',
        'videoUrl': 'http://test.com/video',
        'duration': '10:00',
        'description': 'Lesson description',
      };

      final lesson = Lesson.fromMap(map);

      expect(lesson.id, 'lesson_1');
      expect(lesson.title, 'Test Lesson');
      expect(lesson.videoUrl, 'http://test.com/video');
      expect(lesson.duration, '10:00');
      expect(lesson.description, 'Lesson description');
      expect(lesson.isCompleted, false);
      expect(lesson.isLocked, true); // default
    });

    test('Lesson.toMap serializes correctly', () {
      final lesson = Lesson(
        id: 'lesson_2',
        title: 'New Lesson',
        videoUrl: 'http://test.com/v2',
        duration: '5:00',
        description: 'Desc',
      );

      final map = lesson.toMap();
      expect(map['title'], 'New Lesson');
      expect(map['videoUrl'], 'http://test.com/v2');
      expect(map['duration'], '5:00');
    });

    test('Course.fromMap parses correctly with price', () {
      final map = {
        'title': 'Flutter Course',
        'instructor': 'Admin',
        'instructorImageUrl': '',
        'duration': '2h',
        'rating': 4.5,
        'enrolledCount': 10,
        'difficulty': 'Beginner',
        'imageUrl': 'img.png',
        'description': 'Desc',
        'category': 'Development',
        'price': 499.0,
        'lessons': [
          {
            'title': 'Intro',
            'videoUrl': 'url',
            'duration': '2m',
            'description': 'intro'
          }
        ]
      };

      final course = Course.fromMap(map, 'course_1');

      expect(course.id, 'course_1');
      expect(course.title, 'Flutter Course');
      expect(course.price, 499.0);
      expect(course.lessons.length, 1);
      expect(course.lessons.first.title, 'Intro');
    });

    test('Course.fromMap handles missing price gracefully', () {
      final map = {
        'title': 'Free Course',
        'instructor': 'Admin',
        'category': 'Design',
      };

      final course = Course.fromMap(map, 'course_free');
      expect(course.price, 0.0); // Should fallback to 0.0
      expect(course.title, 'Free Course');
      expect(course.category, 'Design');
    });

    test('Course progress calculation works', () {
      final course = Course(
        id: 'c1',
        title: 'Title',
        instructor: 'Inst',
        instructorImageUrl: '',
        duration: '1h',
        rating: 5.0,
        enrolledCount: 0,
        difficulty: 'Beginner',
        imageUrl: '',
        description: '',
        category: 'Dev',
        price: 0.0,
        lessons: [
          Lesson(id: 'l1', title: 'L1', videoUrl: '', duration: '', description: '', isCompleted: true),
          Lesson(id: 'l2', title: 'L2', videoUrl: '', duration: '', description: '', isCompleted: false),
        ],
      );

      expect(course.completedLessonsCount, 1);
      expect(course.progressPercent, 0.5); // 1 out of 2 is 50%
    });
  });
}
