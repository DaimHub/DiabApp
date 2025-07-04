import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as auth;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floating1;
  late Animation<double> _floating2;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _floating1 = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floating2 = Tween<double>(begin: 10, end: -10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _rotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.linear),
    );

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<auth.AuthProvider>(
        context,
        listen: false,
      );
      final success = await authProvider.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Dismiss keyboard
        FocusScope.of(context).unfocus();

        // Show success message
        _showToast('Welcome back!', ToastificationType.success);

        // Navigate back to let the home screen show the Dashboard
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showToast('Login failed. Please try again.', ToastificationType.error);
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Try again later.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
      }

      _showToast(errorMessage, ToastificationType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // Dismiss keyboard immediately when Google sign-in is tapped
    FocusScope.of(context).unfocus();

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final authProvider = Provider.of<auth.AuthProvider>(
        context,
        listen: false,
      );
      final success = await authProvider.signInWithGoogle();

      if (success) {
        // Successfully signed in
        _showToast(
          'Successfully signed in with Google',
          ToastificationType.success,
        );
        // Navigate back to let the home screen show the Dashboard
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showToast('Google sign-in was cancelled', ToastificationType.error);
      }
    } catch (e) {
      String errorMessage = 'Failed to sign in with Google';

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
        title = 'Welcome Back!';
        description = message;
        iconData = Icons.check_circle_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case ToastificationType.error:
        title = 'Login Failed';
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
      borderRadius: SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 0.6),
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
        child: Stack(
          children: [
            // Animated background elements
            _buildAnimatedBackground(theme),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: ShapeDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF0F1F7),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 14,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              customBorder: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 14,
                                  cornerSmoothing: 0.6,
                                ),
                              ),
                              child: const Center(
                                child: FaIcon(FontAwesomeIcons.xmark, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Welcome back',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email',
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
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _showForgotPasswordDialog();
                                  },
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 8,
                                    cornerSmoothing: 0.6,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildPrimaryButton(
                              text: 'Log in',
                              isLoading: _isLoading,
                              onPressed: _isLoading
                                  ? null
                                  : _signInWithEmailAndPassword,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
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
                            _buildGoogleButton(),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 12,
                              cornerSmoothing: 0.6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Text(
                                'Don\'t have an account? Sign up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating shape 1
            Positioned(
              top: 100 + _floating1.value,
              right: 30,
              child: Transform.rotate(
                angle: _rotation.value * 2 * 3.14159,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating shape 2
            Positioned(
              top: 250 + _floating2.value,
              left: 25,
              child: Transform.rotate(
                angle: _rotation.value * -1.5 * 3.14159,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Floating shape 3
            Positioned(
              bottom: 150 + _floating1.value * 0.7,
              right: 40,
              child: Transform.rotate(
                angle: _rotation.value * 0.8 * 3.14159,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return Focus(
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;

          return Container(
            decoration: ShapeDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF0F1F7),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 18,
                  cornerSmoothing: 0.6,
                ),
                side: BorderSide(
                  color: isFocused
                      ? theme.colorScheme.primary.withOpacity(0.8)
                      : theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey[200]!,
                  width: isFocused ? 2 : 1,
                ),
              ),
              shadows: isFocused
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: 18,
                cornerSmoothing: 0.6,
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                validator: validator,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  filled: false,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: ShapeDecoration(
        color: theme.colorScheme.primary,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
        ),
        shadows: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: ShapeDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isGoogleLoading
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
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(context: context, builder: (context) => ForgotPasswordDialog());
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.trim().isEmpty) {
      _showToast('Please enter your email address', ToastificationType.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      _showToast(
        'Password reset email sent! Check your inbox.',
        ToastificationType.success,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      _showToast(errorMessage, ToastificationType.error);
    } finally {
      setState(() {
        _isLoading = false;
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
        title = 'Welcome Back!';
        description = message;
        iconData = Icons.check_circle_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case ToastificationType.error:
        title = 'Login Failed';
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
      borderRadius: SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 0.6),
      backgroundColor: theme.scaffoldBackgroundColor,
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

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: theme.scaffoldBackgroundColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.6,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF0F1F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      child: const Center(child: Icon(Icons.close, size: 18)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Large reset password icon
            Container(
              height: 80,
              width: 80,
              decoration: ShapeDecoration(
                color: theme.colorScheme.primary,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 24,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.lock_reset, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Reset Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Email input field
            Focus(
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;

                  return Container(
                    decoration: ShapeDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0F1F7),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 0.6,
                        ),
                        side: BorderSide(
                          color: isFocused
                              ? theme.colorScheme.primary.withOpacity(0.8)
                              : theme.brightness == Brightness.dark
                              ? const Color(0xFF3A3A3A)
                              : Colors.grey[200]!,
                          width: isFocused ? 2 : 1,
                        ),
                      ),
                      shadows: isFocused
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius(
                        cornerRadius: 16,
                        cornerSmoothing: 0.6,
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.primary.withOpacity(0.7),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          filled: false,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Send reset email button
            Container(
              width: double.infinity,
              height: 48,
              decoration: ShapeDecoration(
                color: const Color(0xFF5D74FB),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 14,
                    cornerSmoothing: 0.6,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _sendPasswordResetEmail,
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 14,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Send Reset Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
