import 'package:flutter_test/flutter_test.dart';
import 'package:lms/state/app_state.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('AppState Tests', () {
    test('AppState initializes with default values', () {
      final mockAuth = MockFirebaseAuth();
      final appState = AppState(auth: mockAuth);

      expect(appState.isDarkMode, false);
      expect(appState.userRole, 'student');
      expect(appState.isSuperAdmin, false);
      expect(appState.isAdmin, false);
      expect(appState.courses, isEmpty);
      expect(appState.categories, contains('All'));
    });

    test('AppState handles login state correctly', () async {
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      
      final appState = AppState(auth: mockAuth);
      
      // Wait for auth stream to process
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentUserName, 'Test User');
      expect(appState.currentUserEmail, 'test@example.com');
    });

    test('AppState handles logout', () async {
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      
      final appState = AppState(auth: mockAuth);
      
      // Wait for auth stream to process
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentUserName, 'Test User');

      await mockAuth.signOut();
      
      // Wait for auth stream
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentUserName, null);
      expect(appState.currentUserEmail, null);
      expect(appState.userRole, 'student'); // Should reset to default
    });

    test('Toggle Theme works', () {
      final mockAuth = MockFirebaseAuth();
      final appState = AppState(auth: mockAuth);

      expect(appState.isDarkMode, false);
      appState.toggleTheme();
      expect(appState.isDarkMode, true);
    });
    
    test('Search filters courses', () {
      final mockAuth = MockFirebaseAuth();
      final appState = AppState(auth: mockAuth);
      
      appState.updateSearch('Flutter');
      expect(appState.searchQuery, 'Flutter');
    });
  });
}
