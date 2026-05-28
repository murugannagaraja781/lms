import 'quiz.dart';

class Lesson {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final String description;
  bool isCompleted;
  bool isLocked;
  final Quiz? quiz;
  final bool isLiveClass;
  final String zoomMeetingUrl;
  final String meetingId;
  final String meetingPassword;
  final String scheduledTime;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    required this.description,
    this.isCompleted = false,
    this.isLocked = true,
    this.quiz,
    this.isLiveClass = false,
    this.zoomMeetingUrl = '',
    this.meetingId = '',
    this.meetingPassword = '',
    this.scheduledTime = '',
  });

  void complete() {
    isCompleted = true;
    if (quiz != null) {
      quiz!.isCompleted = true;
    }
  }

  void unlock() {
    isLocked = false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'videoUrl': videoUrl,
      'description': description,
      'isLiveClass': isLiveClass,
      'zoomMeetingUrl': zoomMeetingUrl,
      'meetingId': meetingId,
      'meetingPassword': meetingPassword,
      'scheduledTime': scheduledTime,
      'quiz': quiz != null ? {
        'id': quiz!.id,
        'passingScore': quiz!.passingScore,
        'questions': quiz!.questions.map((q) => {
          'questionText': q.questionText,
          'options': q.options,
          'correctAnswerIndex': q.correctAnswerIndex,
        }).toList(),
      } : null,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map, {bool isCompleted = false, bool isLocked = true}) {
    final quizMap = map['quiz'] as Map<String, dynamic>?;
    Quiz? parsedQuiz;
    if (quizMap != null) {
      final qList = (quizMap['questions'] as List<dynamic>? ?? []).map((q) {
        return Question(
          questionText: q['questionText'] ?? '',
          options: List<String>.from(q['options'] ?? []),
          correctAnswerIndex: q['correctAnswerIndex'] ?? 0,
        );
      }).toList();
      parsedQuiz = Quiz(
        id: quizMap['id'] ?? '',
        questions: qList,
        passingScore: quizMap['passingScore'] ?? 70,
      );
    }

    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      duration: map['duration'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      description: map['description'] ?? '',
      isCompleted: isCompleted,
      isLocked: isLocked,
      quiz: parsedQuiz,
      isLiveClass: map['isLiveClass'] ?? false,
      zoomMeetingUrl: map['zoomMeetingUrl'] ?? '',
      meetingId: map['meetingId'] ?? '',
      meetingPassword: map['meetingPassword'] ?? '',
      scheduledTime: map['scheduledTime'] ?? '',
    );
  }
}
