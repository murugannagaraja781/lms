import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/comment.dart';

class AppState extends ChangeNotifier {
  final String baseUrl = 'https://lms-bzuj.onrender.com/api';
  
  bool _isDarkMode = false;
  String? _currentUserEmail;
  String? _currentUserName;
  String _userRole = 'student';
  bool _isSuperAdmin = false;
  bool _isAdmin = false;
  List<Course> _courses = [];
  String _searchQuery = "";
  String _selectedCategory = "All";
  
  Course? _selectedCourse;
  Lesson? _selectedLesson;

  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authStateSubscription;

  Map<String, dynamic> _userProgress = {};
  List<Comment> _comments = [];
  List<Map<String, dynamic>> _registeredUsers = [];
  List<String> _customCategories = [];

  AppState({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUserEmail = user.email;
        _currentUserName = user.displayName ?? user.email?.split('@')[0] ?? 'Student';
        _fetchInitialData();
      } else {
        _clearState();
      }
    });
  }

  void _clearState() {
    _currentUserEmail = null;
    _currentUserName = null;
    _userRole = 'student';
    _isSuperAdmin = false;
    _isAdmin = false;
    _userProgress = {};
    _courses = [];
    _comments = [];
    _registeredUsers = [];
    _customCategories = [];
    _clearLocalProgress();
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchInitialData() async {
    await fetchCategories();
    await fetchCourses();
    await fetchComments();
    await syncUser();
  }

  Future<void> syncUser() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/users/sync'),
        headers: _headers(token),
        body: jsonEncode({
          'email': _currentUserEmail,
          'name': _currentUserName,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _userRole = data['role'] ?? 'student';
        _userProgress = data;
        
        // Hardcode failsafe check just in case the backend hasn't been updated on Render yet!
        if (_currentUserEmail == 'murugannagaraja781@gmail.com' || _currentUserEmail == 'superadmin@lms.com') {
          _userRole = 'superadmin';
        } else if (_currentUserEmail == 'admin@lms.com') {
          _userRole = 'admin';
        }

        if (_userRole == 'superadmin') {
          _isSuperAdmin = true;
          _isAdmin = true;
          await fetchAllUsers();
        } else if (_userRole == 'admin') {
          _isSuperAdmin = false;
          _isAdmin = true;
          await fetchAllUsers();
        } else {
          _isSuperAdmin = false;
          _isAdmin = false;
        }
        
        _mergeProgressWithCourses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sync user error: $e');
    }
  }

  Future<void> fetchCourses() async {
    final token = await _getToken();
    if (token == null) return;
    
    try {
      final res = await http.get(Uri.parse('$baseUrl/courses'), headers: _headers(token));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _courses = data.map((c) {
          c['id'] = c['_id'];
          c['lessons'] = (c['lessons'] as List).map((l) {
            l['id'] = l['_id'];
            return l;
          }).toList();
          return Course.fromMap(c, c['id']);
        }).toList();
        _mergeProgressWithCourses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch courses error: $e');
    }
  }

  Future<void> fetchComments() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final res = await http.get(Uri.parse('$baseUrl/comments'), headers: _headers(token));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _comments = data.map((c) {
          c['id'] = c['_id'];
          return Comment.fromMap(c, c['id']);
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch comments error: $e');
    }
  }

  Future<void> fetchAllUsers() async {
    final token = await _getToken();
    if (token == null) return;
    try {
      final res = await http.get(Uri.parse('$baseUrl/users'), headers: _headers(token));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _registeredUsers = List<Map<String, dynamic>>.from(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch all users error: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/categories'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _customCategories = data.map((c) => c['name'].toString()).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch categories error: $e');
    }
  }

  Future<void> addCategory(String name) async {
    final token = await _getToken();
    if (token == null) return;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: _headers(token),
        body: jsonEncode({'name': name}),
      );
      if (res.statusCode == 201) {
        await fetchCategories();
      }
    } catch (e) {
      debugPrint('Add category error: $e');
    }
  }

  Future<void> deleteCategory(String name) async {
    final token = await _getToken();
    if (token == null) return;
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/categories/$name'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        await fetchCategories();
      }
    } catch (e) {
      debugPrint('Delete category error: $e');
    }
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  String get userRole => _userRole;
  bool get isAuthenticated => _currentUserEmail != null;
  bool get isSuperAdmin => _isSuperAdmin;
  bool get isAdmin => _isAdmin;
  List<Course> get courses => _courses;
  List<Map<String, dynamic>> get registeredUsers => _registeredUsers;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Course? get selectedCourse => _selectedCourse;
  Lesson? get selectedLesson => _selectedLesson;
  List<Comment> get comments => _comments;

  List<Comment> getUnreadAdminComments() {
    return _comments.where((c) => !c.isReadByAdmin && c.replyText == null).toList();
  }

  List<Comment> getCommentsForLesson(String lessonId) {
    return _comments.where((c) => c.lessonId == lessonId).toList();
  }

  List<Course> get enrolledCourses =>
      _courses.where((c) => c.isEnrolled).toList();

  List<String> get courseCategories => _customCategories;

  List<String> get categories {
    final Set<String> cats = {"All"};
    cats.addAll(_customCategories);
    return cats.toList();
  }

  List<Course> get filteredCourses {
    return _courses.where((course) {
      final matchesCategory = _selectedCategory == "All" ||
          course.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = course.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          course.instructor
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get overallProgress {
    final enrolled = enrolledCourses;
    if (enrolled.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (var c in enrolled) {
      totalProgress += c.progressPercent;
    }
    return totalProgress / enrolled.length;
  }

  int get totalCompletedLessons {
    int total = 0;
    for (var c in enrolledCourses) {
      total += c.completedLessonsCount;
    }
    return total;
  }

  double get totalPlatformIncome {
    double total = 0;
    for (var user in _registeredUsers) {
      final enrolled = user['enrolledCourses'] as Map<String, dynamic>? ?? {};
      for (var courseId in enrolled.keys) {
        final course = _courses.firstWhere((c) => c.id == courseId, orElse: () => _courses.first);
        if (course.id == courseId && course.price > 0) {
          total += course.price;
        }
      }
    }
    return total;
  }

  List<Map<String, dynamic>> get studentList => _registeredUsers.where((u) => u['role'] == 'student').toList();
  List<Map<String, dynamic>> get adminList => _registeredUsers.where((u) => u['role'] == 'admin').toList();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final lowerEmail = email.trim().toLowerCase();
    try {
      await _auth.signInWithEmailAndPassword(
        email: lowerEmail,
        password: password.trim(),
      );
      // Wait for stream to update
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        if ((lowerEmail == 'superadmin@lms.com' && password == 'superadmin123') ||
            (lowerEmail == 'admin@lms.com' && password == 'admin123') ||
            (lowerEmail == 'user@gmail.com' && password == 'user123')) {
          
          final UserCredential creds = await _auth.createUserWithEmailAndPassword(
            email: lowerEmail,
            password: password.trim(),
          );
          
          String role = 'student';
          String name = 'Test Student';
          if (lowerEmail == 'superadmin@lms.com') {
            role = 'superadmin';
            name = 'Super Admin';
          } else if (lowerEmail == 'admin@lms.com') {
            role = 'admin';
            name = 'Admin User';
          }
          
          await creds.user!.updateDisplayName(name);
          
          final token = await creds.user!.getIdToken();
          if (token != null) {
            await http.post(
              Uri.parse('$baseUrl/users/sync'),
              headers: _headers(token),
              body: jsonEncode({'email': lowerEmail, 'name': name, 'role': role}),
            );
          }
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> signup(String email, String password, String name) async {
    final UserCredential creds = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    if (creds.user != null) {
      if (name.trim().isNotEmpty) {
        await creds.user!.updateDisplayName(name.trim());
      }
      final token = await creds.user!.getIdToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/users/sync'),
          headers: _headers(token),
          body: jsonEncode({'email': email.trim(), 'name': name.trim(), 'role': 'student'}),
        );
      }
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: '288012292455-o128lke1lj2j6l2vrcltovc8c7b81drm.apps.googleusercontent.com',
    ).signIn();
    
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential creds = await _auth.signInWithCredential(credential);
      if (creds.additionalUserInfo?.isNewUser ?? false) {
        final token = await creds.user!.getIdToken();
        if (token != null) {
          await http.post(
            Uri.parse('$baseUrl/users/sync'),
            headers: _headers(token),
            body: jsonEncode({
              'email': creds.user!.email,
              'name': creds.user!.displayName ?? googleUser.displayName ?? 'Student',
              'role': 'student'
            }),
          );
        }
      }
    }
  }

  Future<void> updateUserProfile(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      _currentUserName = name;
      notifyListeners();
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint("Error signing out from Google: $e");
    }
    await _auth.signOut();
  }

  void enrollInCourse(String courseId) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final res = await http.post(Uri.parse('$baseUrl/users/enroll/$courseId'), headers: _headers(token));
      if (res.statusCode == 200) {
        _userProgress = jsonDecode(res.body);
        _mergeProgressWithCourses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Enroll error: $e');
    }
  }

  void selectCourse(Course? course) {
    _selectedCourse = course;
    if (course != null && course.lessons.isNotEmpty) {
      _selectedLesson = course.lessons.firstWhere(
        (l) => !l.isLocked,
        orElse: () => course.lessons.first,
      );
    } else {
      _selectedLesson = null;
    }
    notifyListeners();
  }

  void selectLesson(Lesson lesson) {
    _selectedLesson = lesson;
    notifyListeners();
  }

  void completeLesson(String courseId, String lessonId) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final res = await http.post(Uri.parse('$baseUrl/users/complete/$courseId/$lessonId'), headers: _headers(token));
      if (res.statusCode == 200) {
        _userProgress = jsonDecode(res.body);
        _mergeProgressWithCourses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Complete lesson error: $e');
    }
  }

  void toggleAdminMode() {
    _isAdmin = !_isAdmin;
    notifyListeners();
  }

  Future<void> postComment(String courseId, String lessonId, String text) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: _headers(token),
        body: jsonEncode({
          'courseId': courseId,
          'lessonId': lessonId,
          'text': text,
          'userName': _currentUserName ?? 'Student'
        }),
      );
      await fetchComments();
    } catch (e) {
      debugPrint('Post comment error: $e');
    }
  }

  Future<void> replyToComment(String commentId, String replyText) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.post(
        Uri.parse('$baseUrl/comments/reply/$commentId'),
        headers: _headers(token),
        body: jsonEncode({'replyText': replyText}),
      );
      await fetchComments();
    } catch (e) {
      debugPrint('Reply to comment error: $e');
    }
  }

  void addCourse(Course course) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final map = course.toMap();
      map.remove('id');
      await http.post(
        Uri.parse('$baseUrl/courses'),
        headers: _headers(token),
        body: jsonEncode(map),
      );
      await fetchCourses();
    } catch (e) {
      debugPrint('Add course error: $e');
    }
  }

  void deleteCourse(String courseId) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.delete(Uri.parse('$baseUrl/courses/$courseId'), headers: _headers(token));
      await fetchCourses();
    } catch (e) {
      debugPrint('Delete course error: $e');
    }
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void _clearLocalProgress() {
    for (var c in _courses) {
      c.isEnrolled = false;
      for (var l in c.lessons) {
        l.isCompleted = false;
        l.isLocked = l.videoUrl.isNotEmpty && l != c.lessons.first;
      }
    }
  }

  void _mergeProgressWithCourses() {
    if (_courses.isEmpty) return;
    
    _clearLocalProgress();

    if (_userProgress.isEmpty) {
      return;
    }

    final enrolledData = _userProgress['enrolledCourses'] as Map<String, dynamic>? ?? {};

    for (var course in _courses) {
      if (enrolledData.containsKey(course.id)) {
        course.isEnrolled = true;
        
        final courseProgress = enrolledData[course.id] as Map<String, dynamic>? ?? {};
        final completedLessons = List<String>.from(courseProgress['completedLessons'] ?? []);
        
        for (int i = 0; i < course.lessons.length; i++) {
          final lesson = course.lessons[i];
          if (completedLessons.contains(lesson.id)) {
            lesson.isCompleted = true;
            lesson.isLocked = false;
            
            if (i + 1 < course.lessons.length) {
              course.lessons[i + 1].isLocked = false;
            }
          } else {
            lesson.isCompleted = false;
          }
        }
      } else {
        if (course.price == 0 && _isAdmin) {
          course.isEnrolled = true;
          for (var l in course.lessons) {
             l.isLocked = false;
          }
        }
      }
    }
  }
}
