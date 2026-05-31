import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/superadmin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final state = AppState();
        return state;
      },
      child: const LMSApp(),
    ),
  );
}

class LMSApp extends StatelessWidget {
  const LMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Premium Color Palettes
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C5CE7), // Slate Blue / Indigo
      primary: const Color(0xFF6C5CE7),
      secondary: const Color(0xFF00CEC9), // Teal
      background: const Color(0xFFF8F9FA),
      surface: Colors.white,
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF82589F), // Deep Violet
      primary: const Color(0xFFa29bfe),
      secondary: const Color(0xFF00CEC9),
      background: const Color(0xFF0F0E17), // Rich Dark Space Blue
      surface: const Color(0xFF1C1A27), // Card Dark Purple-Blue
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'EduSphere - LMS',
      debugShowCheckedModeBanner: false,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightColorScheme.surface,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkColorScheme.surface,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          color: darkColorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF28253B)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: Consumer<AppState>(
        builder: (context, state, child) {
          if (state.isAuthenticated) {
            if (state.isSuperAdmin) {
              return const SuperAdminDashboardScreen();
            }
            if (state.isAdmin) {
              return const AdminDashboardScreen();
            }
            return const NavigationScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
