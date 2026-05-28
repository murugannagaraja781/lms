class Comment {
  final String id;
  final String lessonId;
  final String courseId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final String? replyText;
  final DateTime? replyTimestamp;
  final bool isReadByAdmin;

  Comment({
    required this.id,
    required this.lessonId,
    required this.courseId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    this.replyText,
    this.replyTimestamp,
    this.isReadByAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'replyText': replyText,
      'replyTimestamp': replyTimestamp?.toIso8601String(),
      'isReadByAdmin': isReadByAdmin,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map, String docId) {
    return Comment(
      id: docId,
      lessonId: map['lessonId'] ?? '',
      courseId: map['courseId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Student',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      replyText: map['replyText'],
      replyTimestamp: map['replyTimestamp'] != null ? DateTime.parse(map['replyTimestamp']) : null,
      isReadByAdmin: map['isReadByAdmin'] ?? false,
    );
  }
}
