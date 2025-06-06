import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import '../services/google_sign_in_service.dart';
import '../services/firestore_service.dart';
import 'register_details_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccountAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Update user profile with display name
      await credential.user?.updateDisplayName(
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );

      // Show success message
      _showToast('Account created successfully!', ToastificationType.success);

      // Wait a moment for the toast to show, then navigate to details screen
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterDetailsScreen(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      _showToast(errorMessage, ToastificationType.error);
    } catch (e) {
      _showToast(
        'An unexpected error occurred. Please try again.',
        ToastificationType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();

      if (userCredential != null) {
        // Successfully signed in

        // Extract first and last name from Google display name
        final displayName = userCredential.user?.displayName ?? '';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        _showToast('Account created successfully!', ToastificationType.success);

        // Wait a moment for the toast to show, then navigate to details screen
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterDetailsScreen(
                firstName: firstName,
                lastName: lastName,
                email: userCredential.user?.email ?? '',
                password: '', // Empty password for Google users
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Add detailed error logging

      String errorMessage = 'Failed to sign up with Google';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'An account already exists with a different sign-in method';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid Google credentials';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Google sign-in is not enabled';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      } else {
        errorMessage = 'An unexpected error occurred: $e';
      }

      _showToast(errorMessage, ToastificationType.error);
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  void _showToast(String message, ToastificationType type) {
    final theme = Theme.of(context);

    String title;
    String description;
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ToastificationType.success:
        title = 'Account Created!';
        description = message;
        iconData = Icons.check_circle_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case ToastificationType.error:
        title = 'Registration Failed';
        description = message;
        iconData = Icons.error_outline;
        iconColor = Colors.red[600]!;
        break;
      default:
        title = 'Notification';
        description = message;
        iconData = Icons.info_outline;
        iconColor = theme.colorScheme.primary;
    }

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.brightness == Brightness.dark
              ? Colors.grey[300]
              : Colors.black54,
        ),
      ),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      borderRadius: BorderRadius.circular(10),
      backgroundColor: theme.cardColor,
      foregroundColor: theme.colorScheme.primary,
      borderSide: BorderSide(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      icon: Icon(iconData, color: iconColor, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 24),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Let\'s get started with your basic information',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _firstNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5C5FC1),
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F1F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Last Name',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5C5FC1),
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F1F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5C5FC1),
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F1F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5C5FC1),
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F1F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createAccountAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D74FB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[600]
                              : Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[600]
                              : Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : Colors.white,
                      foregroundColor: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF3A3A3A)
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    icon: _isGoogleLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : FaIcon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF4285F4),
                          ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Already have an account? Sign in',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
