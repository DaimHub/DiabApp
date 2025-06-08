import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floating1;
  late Animation<double> _floating2;
  late Animation<double> _floating3;
  late Animation<double> _rotation1;
  late Animation<double> _rotation2;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Floating animations
    _floating1 = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floating2 = Tween<double>(begin: 15, end: -15).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floating3 = Tween<double>(begin: -10, end: 25).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _rotation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.linear),
    );

    _rotation2 = Tween<double>(begin: 0, end: -0.8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.linear),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    super.dispose();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: ShapeDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0F1F7),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 16,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                      ),
                      child: Text(
                        'DiabApp',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: ShapeDecoration(
                              color: theme.colorScheme.primary,
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 32,
                                  cornerSmoothing: 0.6,
                                ),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Welcome to DiabApp',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your personal diabetes management assistant.\nTrack your health, manage your diet, and stay informed.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildActionButton(
                            context: context,
                            text: 'Login',
                            isPrimary: true,
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            context: context,
                            text: 'Register',
                            isPrimary: false,
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
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
              top: 120 + _floating1.value,
              left: 50,
              child: Transform.rotate(
                angle: _rotation1.value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating shape 2
            Positioned(
              top: 300 + _floating2.value,
              right: 40,
              child: Transform.rotate(
                angle: _rotation2.value * 2 * 3.14159,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Floating shape 3
            Positioned(
              bottom: 200 + _floating3.value,
              left: 30,
              child: Transform.rotate(
                angle: _rotation1.value * 1.5 * 3.14159,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.06),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 25,
                        cornerSmoothing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating shape 4
            Positioned(
              bottom: 350 + _floating1.value * 0.8,
              right: 60,
              child: Transform.rotate(
                angle: _rotation2.value * 0.7 * 3.14159,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.05),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
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

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: ShapeDecoration(
        color: isPrimary ? theme.colorScheme.primary : Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey[300]!,
                  width: 1.5,
                ),
        ),
        shadows: isPrimary
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
