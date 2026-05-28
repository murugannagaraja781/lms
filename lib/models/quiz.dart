class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  int? selectedAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.selectedAnswerIndex,
  });

  bool get isCorrect => selectedAnswerIndex == correctAnswerIndex;
}

class Quiz {
  final String id;
  final List<Question> questions;
  final int passingScore;
  bool isCompleted;
  int score;

  Quiz({
    required this.id,
    required this.questions,
    this.passingScore = 70,
    this.isCompleted = false,
    this.score = 0,
  });

  int get totalQuestions => questions.length;
  
  double get percentageScore => 
      totalQuestions == 0 ? 0.0 : (score / totalQuestions) * 100.0;

  bool get isPassed => percentageScore >= passingScore;

  void calculateScore() {
    int correctCount = 0;
    for (var q in questions) {
      if (q.isCorrect) {
        correctCount++;
      }
    }
    score = correctCount;
    if (isPassed) {
      isCompleted = true;
    }
  }

  void reset() {
    score = 0;
    isCompleted = false;
    for (var q in questions) {
      q.selectedAnswerIndex = null;
    }
  }
}
