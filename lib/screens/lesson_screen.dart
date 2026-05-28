import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';
import '../models/quiz.dart';
import '../models/lesson.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Video Mock State
  bool _isPlaying = false;
  double _videoProgress = 0.15; // Simulated percentage
  String _currentTime = '01:50';

  // YouTube Player State
  YoutubePlayerController? _ytController;
  String? _currentLoadedLessonId;

  // Notes State
  final _noteController = TextEditingController();
  final List<String> _localNotes = [];

  // Q&A State
  final _commentController = TextEditingController();

  // Quiz Session State
  bool _quizSubmitted = false;

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be') || url.contains('youtube-nocookie.com');
  }

  @override
  void dispose() {
    _noteController.dispose();
    _commentController.dispose();
    _ytController?.dispose();
    super.dispose();
  }

  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      setState(() {
        _localNotes.insert(0, _noteController.text.trim());
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  void _deleteNote(int index) {
    setState(() {
      _localNotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final course = appState.selectedCourse;
    final lesson = appState.selectedLesson;

    if (course == null || lesson == null) {
      return const Scaffold(
        body: Center(child: Text('No active lesson')),
      );
    }

    // Dynamic controller initialization for YouTube streams
    if (_currentLoadedLessonId != lesson.id) {
      _currentLoadedLessonId = lesson.id;
      _ytController?.dispose();
      _ytController = null;
      
      if (_isYouTubeUrl(lesson.videoUrl)) {
        final videoId = YoutubePlayer.convertUrlToId(lesson.videoUrl);
        if (videoId != null) {
          _ytController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              isLive: true, // Auto-configures player optimization for YouTube Live classes
            ),
          );
        }
      }
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // 1. Mock Video Player Panel
            _buildVideoPlayer(theme, lesson),

            // Lesson Header Meta
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Classroom Module • ${lesson.duration}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Buttons
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Q&A'),
                Tab(text: 'Quiz'),
                Tab(text: 'My Notes'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(theme, appState, course.id, lesson),
                  _buildQaTab(theme, appState, course.id, lesson),
                  _buildQuizTab(theme, appState, course.id, lesson),
                  _buildNotesTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(ThemeData theme, Lesson lesson) {
    if (lesson.isLiveClass) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.05),
                theme.colorScheme.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade600.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.video_camera_front, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'IN-APP VIRTUAL CLASS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (lesson.scheduledTime.isNotEmpty) ...[
                  Text(
                    'Scheduled: ${lesson.scheduledTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (lesson.meetingId.isNotEmpty)
                  Text(
                    'Room ID: ${lesson.meetingId}  |  Passcode: ${lesson.meetingPassword}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (lesson.zoomMeetingUrl.isNotEmpty) {
                      final uri = Uri.parse(lesson.zoomMeetingUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch external meeting')),
                        );
                      }
                    } else if (lesson.meetingId.isNotEmpty) {
                      final jitsiMeet = JitsiMeet();
                      var options = JitsiMeetConferenceOptions(
                        serverURL: "https://meet.jit.si",
                        room: lesson.meetingId,
                        configOverrides: {
                          "startWithAudioMuted": true,
                          "startWithVideoMuted": true,
                        },
                        userInfo: JitsiMeetUserInfo(
                            displayName: Provider.of<AppState>(context, listen: false).currentUserName ?? "Student",
                            email: "student@lms.com",
                        ),
                      );
                      jitsiMeet.join(options);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No Room ID or Link found for this class')),
                      );
                    }
                  },
                  icon: const Icon(Icons.videocam, color: Colors.white),
                  label: Text(lesson.zoomMeetingUrl.isNotEmpty ? 'Open External Meeting' : 'Join Virtual Class', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_ytController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _ytController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: theme.colorScheme.primary,
          liveUIColor: Colors.redAccent,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Thumbnail / Black Panel
            Center(
              child: Icon(
                Icons.play_circle_filled,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: _isPlaying ? 0.05 : 0.8),
              ),
            ),
            
            // Video overlay controller details
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                    ),
                    Text(
                      _currentTime,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Expanded(
                      child: Slider(
                        value: _videoProgress,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: Colors.white30,
                        onChanged: (val) {
                          setState(() {
                            _videoProgress = val;
                            // Calculate current time string from slider
                            int totalSecs = 700; // Mock total duration
                            int currentSecs = (val * totalSecs).toInt();
                            int mins = currentSecs ~/ 60;
                            int secs = currentSecs % 60;
                            _currentTime = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
                          });
                        },
                      ),
                    ),
                    Text(
                      lesson.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, AppState appState, String courseId, Lesson lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this Lesson',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          
          // Resource Section
          const Text(
            'Reference Attachments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('lecture_notes_and_slides.pdf', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('PDF File • 4.2 MB', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Completion status button
          if (lesson.isCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.teal),
                  SizedBox(width: 10),
                  Text(
                    'You completed this lesson',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                appState.completeLesson(courseId, lesson.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lesson marked complete! Nice progress.'),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check),
              label: const Text(
                'Mark as Complete',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizTab(ThemeData theme, AppState appState, String courseId, Lesson lesson) {
    final quiz = lesson.quiz;

    if (quiz == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.playlist_add_check, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              const Text(
                'No Quiz Added',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'This specific module relies on classroom reference files. Complete the lesson using the button under the Overview tab to proceed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Interactive Assessment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          Text(
            'Earn a passing score of ${quiz.passingScore}% to unlock the next milestone.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),

          // Render Question Blocks
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quiz.questions.length,
            itemBuilder: (context, qIndex) {
              final q = quiz.questions[qIndex];
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${qIndex + 1}: ${q.questionText}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      q.options.length,
                      (optIndex) {
                        final optionText = q.options[optIndex];
                        final isSelected = q.selectedAnswerIndex == optIndex;
                        
                        Color blockColor = theme.colorScheme.onSurface.withValues(alpha: 0.02);
                        BorderSide border = BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08));

                        if (_quizSubmitted) {
                          if (optIndex == q.correctAnswerIndex) {
                            blockColor = Colors.teal.withValues(alpha: 0.12);
                            border = const BorderSide(color: Colors.teal, width: 1.5);
                          } else if (isSelected && !q.isCorrect) {
                            blockColor = theme.colorScheme.error.withValues(alpha: 0.12);
                            border = BorderSide(color: theme.colorScheme.error, width: 1.5);
                          }
                        } else if (isSelected) {
                          blockColor = theme.colorScheme.primary.withValues(alpha: 0.1);
                          border = BorderSide(color: theme.colorScheme.primary, width: 1.5);
                        }

                        return GestureDetector(
                          onTap: _quizSubmitted
                              ? null
                              : () {
                                  setState(() {
                                    q.selectedAnswerIndex = optIndex;
                                  });
                                },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: blockColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.fromBorderSide(border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? (_quizSubmitted
                                          ? (q.isCorrect ? Icons.check_circle : Icons.cancel)
                                          : Icons.radio_button_checked)
                                      : Icons.radio_button_off,
                                  size: 20,
                                  color: isSelected
                                      ? (_quizSubmitted
                                          ? (q.isCorrect ? Colors.teal : theme.colorScheme.error)
                                          : theme.colorScheme.primary)
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Submit Actions
          if (!_quizSubmitted)
            ElevatedButton(
              onPressed: () {
                // Ensure all answered
                bool allAnswered = quiz.questions.every((q) => q.selectedAnswerIndex != null);
                if (!allAnswered) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please answer all questions before submitting.'),
                      backgroundColor: Colors.amber,
                    ),
                  );
                  return;
                }

                setState(() {
                  quiz.calculateScore();
                  _quizSubmitted = true;
                });

                if (quiz.isPassed) {
                  appState.completeLesson(courseId, lesson.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Congratulations! Passed with ${quiz.percentageScore.toInt()}%. Next module unlocked!'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed. Scored ${quiz.percentageScore.toInt()}%. Try again.'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Assessment', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: quiz.isPassed ? Colors.teal.withValues(alpha: 0.12) : theme.colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: quiz.isPassed ? Colors.teal : theme.colorScheme.error,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    quiz.isPassed ? Icons.emoji_events : Icons.refresh,
                    color: quiz.isPassed ? Colors.teal : theme.colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz.isPassed ? 'Assessment Passed!' : 'Assessment Failed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: quiz.isPassed ? Colors.teal : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: ${quiz.score}/${quiz.totalQuestions} (${quiz.percentageScore.toInt()}%)',
                    style: TextStyle(
                      fontSize: 13,
                      color: quiz.isPassed ? Colors.teal : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  quiz.reset();
                  _quizSubmitted = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                foregroundColor: theme.colorScheme.onSurface,
              ),
              child: const Text('Retry Assessment', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Personal Memo Notebook',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          
          // Form and Save
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Add an interactive quick note...',
                    filled: true,
                    fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _addNote,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // List of notes
          Expanded(
            child: _localNotes.isEmpty
                ? Center(
                    child: Text(
                      'No saved notes yet.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _localNotes.length,
                    itemBuilder: (context, index) {
                      final note = _localNotes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Saved just now',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                              onPressed: () => _deleteNote(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQaTab(ThemeData theme, AppState appState, String courseId, Lesson lesson) {
    final comments = appState.getCommentsForLesson(lesson.id);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ask the Instructor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          
          // Form and Save
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Type your question here...',
                    filled: true,
                    fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    appState.postComment(courseId, lesson.id, _commentController.text.trim());
                    _commentController.clear();
                    FocusScope.of(context).unfocus();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // List of comments
          Expanded(
            child: comments.isEmpty
                ? Center(
                    child: Text(
                      'No questions yet. Be the first to ask!',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  )
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  child: Text(
                                    comment.userName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  comment.userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comment.text,
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (comment.replyText != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.admin_panel_settings, size: 14, color: theme.colorScheme.primary),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Instructor Reply',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      comment.replyText!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
