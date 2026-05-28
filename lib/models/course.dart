import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String instructor;
  final String instructorImageUrl;
  final String duration;
  final double rating;
  final int enrolledCount;
  final String difficulty;
  final String imageUrl;
  final String description;
  final List<Lesson> lessons;
  final String category;
  final double price;
  bool isEnrolled;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.instructorImageUrl,
    required this.duration,
    required this.rating,
    required this.enrolledCount,
    required this.difficulty,
    required this.imageUrl,
    required this.description,
    required this.lessons,
    required this.category,
    this.price = 0.0,
    this.isEnrolled = false,
  });

  int get totalLessons => lessons.length;

  int get completedLessonsCount => lessons.where((l) => l.isCompleted).length;

  double get progressPercent {
    if (lessons.isEmpty) return 0.0;
    return completedLessonsCount / totalLessons;
  }

  void enroll() {
    isEnrolled = true;
    if (lessons.isNotEmpty) {
      lessons[0].unlock(); // Unlock the first lesson upon enrollment
    }
  }

  void updateLessonCompletion(String lessonId, bool completed) {
    final lessonIndex = lessons.indexWhere((l) => l.id == lessonId);
    if (lessonIndex != -1) {
      lessons[lessonIndex].isCompleted = completed;

      // Automatically unlock the next lesson if completed
      if (completed && lessonIndex + 1 < lessons.length) {
        lessons[lessonIndex + 1].unlock();
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'instructorImageUrl': instructorImageUrl,
      'duration': duration,
      'rating': rating,
      'enrolledCount': enrolledCount,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'price': price,
      'lessons': lessons.map((l) => l.toMap()).toList(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map, String docId, {bool isEnrolled = false}) {
    final lessonsList = (map['lessons'] as List<dynamic>? ?? []).map((l) {
      return Lesson.fromMap(l as Map<String, dynamic>);
    }).toList();

    return Course(
      id: docId,
      title: map['title'] ?? '',
      instructor: map['instructor'] ?? '',
      instructorImageUrl: map['instructorImageUrl'] ?? '',
      duration: map['duration'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      enrolledCount: map['enrolledCount'] ?? 0,
      difficulty: map['difficulty'] ?? 'Beginner',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Development',
      price: (map['price'] ?? 0.0).toDouble(),
      lessons: lessonsList,
      isEnrolled: isEnrolled,
    );
  }
}
