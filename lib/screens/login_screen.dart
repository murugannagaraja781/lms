import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';
import 'admin_dashboard_screen.dart';
import 'superadmin_dashboard_screen.dart';
import 'navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final appState = Provider.of<AppState>(context, listen: false);
      
      try {
        if (_isSignUp) {
          await appState.signup(
            _emailController.text,
            _passwordController.text,
            _nameController.text,
          );
        } else {
          await appState.login(
            _emailController.text,
            _passwordController.text,
          );
        }

        if (mounted) {
          // Add a small delay to ensure Firestore stream updates role
          await Future.delayed(const Duration(milliseconds: 500));

          if (appState.isSuperAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SuperAdminDashboardScreen()),
            );
          } else if (appState.isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavigationScreen()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = 'An authentication error occurred.';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMsg = 'Invalid email or password.';
        } else if (e.code == 'email-already-in-use') {
          errorMsg = 'This email is already registered.';
        } else if (e.code == 'weak-password') {
          errorMsg = 'The password is too weak.';
        } else if (e.code == 'invalid-email') {
          errorMsg = 'Please enter a valid email address.';
        } else if (e.code == 'user-disabled') {
          errorMsg = 'This account has been disabled.';
        } else if (e.message != null) {
          errorMsg = e.message!;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              appState.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => appState.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo & Subtitle
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.blur_on_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isSignUp ? 'Create Account' : 'Welcome Back',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? 'Sign up to start learning and tracking your achievements.'
                      : 'Login to access your enrolled courses and curriculum.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 40),

                // Form Fields
                if (_isSignUp) ...[
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                if (!_isSignUp) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isSignUp ? 'Sign Up' : 'Log In',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or connect with',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      Icons.g_mobiledata, 
                      theme,
                      onTap: () async {
                        setState(() => _isLoading = true);
                        try {
                          await appState.signInWithGoogle();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const NavigationScreen()),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Google Sign In Failed. Note: Add SHA-1 key to Firebase console.'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(Icons.apple, theme),
                    const SizedBox(width: 16),
                    _buildSocialButton(Icons.code, theme), // GitHub mock
                  ],
                ),

                const SizedBox(height: 32),

                // Toggle Auth Mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account? ' : 'New to EduSphere? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isSignUp ? 'Log In' : 'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, ThemeData theme, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(icon, size: 28, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      ),
    );
  }
}
