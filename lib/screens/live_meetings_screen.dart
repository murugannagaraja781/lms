import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';

class LiveMeetingsScreen extends StatelessWidget {
  const LiveMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    
    // Aggregate all live classes from enrolled courses
    final List<Map<String, dynamic>> liveMeetings = [];
    final coursesToSearch = appState.isAdmin ? appState.courses : appState.enrolledCourses;
    
    for (var course in coursesToSearch) {
      for (var lesson in course.lessons) {
        if (lesson.isLiveClass) {
          liveMeetings.add({
            'course': course,
            'lesson': lesson,
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Meetings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: liveMeetings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming meetings',
                    style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: liveMeetings.length,
              itemBuilder: (context, index) {
                final meeting = liveMeetings[index];
                final course = meeting['course'];
                final lesson = meeting['lesson'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lesson.scheduledTime.isNotEmpty ? lesson.scheduledTime : 'TBA',
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lesson.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.password, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                const SizedBox(width: 6),
                                Text(
                                  'Meeting ID: ${lesson.meetingId.isNotEmpty ? lesson.meetingId : (lesson.zoomMeetingUrl.isNotEmpty ? "External Link" : "None")}',
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                        displayName: appState.currentUserName ?? "LMS Student",
                                        email: "student@lms.com",
                                    ),
                                  );
                                  jitsiMeet.join(options);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No meeting link or ID provided for this class')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.videocam, color: Colors.white),
                              label: const Text('Join Video Call', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
