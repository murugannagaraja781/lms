import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/course.dart';
import '../models/lesson.dart';

class AdminAddCourseScreen extends StatefulWidget {
  final bool initialIsLiveClass;
  
  const AdminAddCourseScreen({super.key, this.initialIsLiveClass = false});

  @override
  State<AdminAddCourseScreen> createState() => _AdminAddCourseScreenState();
}

class _AdminAddCourseScreenState extends State<AdminAddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructorController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=800&q=80',
  );
  final _youtubeController = TextEditingController(
    text: 'https://www.youtube.com/watch?v=5qap5aO4i9A',
  );
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '0');

  late bool _isLiveClass;
  bool _isExternalLink = false;
  final _zoomUrlController = TextEditingController(text: 'https://zoom.us/j/123456');
  final _meetingIdController = TextEditingController(text: 'Room-1234');
  final _meetingPasswordController = TextEditingController(text: 'PASS123');
  final _scheduledTimeController = TextEditingController(text: 'Today, 03:00 PM');

  String _selectedCategory = 'Development';
  String _selectedDifficulty = 'Beginner';

  final List<String> _categories = ['Development', 'Design', 'Marketing', 'Business'];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _isLiveClass = widget.initialIsLiveClass;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    _youtubeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _zoomUrlController.dispose();
    _meetingIdController.dispose();
    _meetingPasswordController.dispose();
    _scheduledTimeController.dispose();
    super.dispose();
  }

  void _submitCourse() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Generate a new course object
      final newCourse = Course(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        instructor: _instructorController.text.trim(),
        instructorImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        duration: _durationController.text.trim(),
        rating: 5.0, // Default rating for new courses
        enrolledCount: 0,
        difficulty: _selectedDifficulty,
        imageUrl: _imageUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        isEnrolled: false,
        // Pre-populate with one introductory lesson so the course is instantly operational
        lessons: [
          Lesson(
            id: 'l_intro_${DateTime.now().millisecondsSinceEpoch}',
            title: _isLiveClass ? '1. Live Class Session' : '1. Course Introduction and Getting Started',
            duration: _durationController.text.trim().isNotEmpty ? _durationController.text.trim() : '05:30',
            videoUrl: _isLiveClass ? '' : _youtubeController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty 
                ? _descriptionController.text.trim() 
                : 'Welcome to this class!',
            isLocked: false, // Default unlocked
            isCompleted: false,
            isLiveClass: _isLiveClass,
            zoomMeetingUrl: _isLiveClass && _isExternalLink ? _zoomUrlController.text.trim() : '',
            meetingId: _isLiveClass && !_isExternalLink ? _meetingIdController.text.trim() : '',
            meetingPassword: _isLiveClass && !_isExternalLink ? _meetingPasswordController.text.trim() : '',
            scheduledTime: _isLiveClass ? _scheduledTimeController.text.trim() : '',
          ),
        ],
      );

      appState.addCourse(newCourse);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newCourse.title}" successfully added to inventory!'),
          backgroundColor: Colors.teal,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Course',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Field
                _buildFormField(
                  controller: _titleController,
                  label: 'Course Title',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter course title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Instructor Field
                _buildFormField(
                  controller: _instructorController,
                  label: 'Instructor Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter instructor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Duration Field
                _buildFormField(
                  controller: _durationController,
                  label: 'Course Duration (e.g. 8h 30m)',
                  icon: Icons.schedule,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter duration details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price Field
                _buildFormField(
                  controller: _priceController,
                  label: 'Course Price (Enter 0 for Free)',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price (or 0 for free)';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image URL Field
                _buildFormField(
                  controller: _imageUrlController,
                  label: 'Cover Image URL',
                  icon: Icons.image_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter banner image URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Live Class Switch
                SwitchListTile(
                  title: const Text('Is this an In-App Virtual Class?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Hosts a native video call room inside the app for students to join instantly.', style: TextStyle(fontSize: 11)),
                  value: _isLiveClass,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (bool value) {
                    setState(() {
                      _isLiveClass = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (!_isLiveClass) ...[
                  // YouTube URL Field
                  _buildFormField(
                    controller: _youtubeController,
                    label: 'YouTube Lesson / Live Stream URL',
                    icon: Icons.video_library_outlined,
                    validator: (value) {
                      if (!_isLiveClass && (value == null || value.trim().isEmpty)) {
                        return 'Please enter YouTube lesson / stream URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Live Class Type Selector
                  const Text('Live Class Platform:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('In-App Jitsi Room', style: TextStyle(fontSize: 12)),
                          value: false,
                          groupValue: _isExternalLink,
                          onChanged: (bool? value) {
                            if (value != null) setState(() => _isExternalLink = value);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('External Zoom/Meet', style: TextStyle(fontSize: 12)),
                          value: true,
                          groupValue: _isExternalLink,
                          onChanged: (bool? value) {
                            if (value != null) setState(() => _isExternalLink = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isExternalLink) ...[
                    // External Zoom URL
                    _buildFormField(
                      controller: _zoomUrlController,
                      label: 'External Zoom / Meet Meeting Link',
                      icon: Icons.link,
                      validator: (value) {
                        if (_isLiveClass && _isExternalLink && (value == null || value.trim().isEmpty)) {
                          return 'Please enter external meeting URL';
                        }
                        return null;
                      },
                    ),
                  ] else ...[
                    // Virtual Class fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: _meetingIdController,
                            label: 'Meeting ID',
                            icon: Icons.tag,
                            validator: (value) {
                              if (_isLiveClass && !_isExternalLink && (value == null || value.trim().isEmpty)) {
                                return 'Enter ID';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            controller: _meetingPasswordController,
                            label: 'Passcode',
                            icon: Icons.password,
                            validator: (value) {
                              if (_isLiveClass && !_isExternalLink && (value == null || value.trim().isEmpty)) {
                                return 'Enter Passcode';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _scheduledTimeController,
                    label: 'Scheduled Time (e.g. Today, 03:00 PM)',
                    icon: Icons.event,
                    validator: (value) {
                      if (_isLiveClass && (value == null || value.trim().isEmpty)) {
                        return 'Please enter scheduled time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Dropdown Category Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: _categories.map((String cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(cat, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCategory = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Difficulty',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDifficulty,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: _difficulties.map((String diff) {
                                  return DropdownMenuItem<String>(
                                    value: diff,
                                    child: Text(diff, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedDifficulty = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description Field
                Text(
                  'Course Description',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description details';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter complete overview details...',
                    filled: true,
                    fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Publish Course',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            filled: true,
            fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
