import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:figma_squircle/figma_squircle.dart';

class CommunityScreenContent extends StatelessWidget {
  const CommunityScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Community features
                Text(
                  'Connect with Others',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),

                // Community feature cards
                _buildCommunityCard(
                  context,
                  'Support Groups',
                  'Connect with people who understand your journey',
                  FontAwesomeIcons.userGroup,
                ),
                const SizedBox(height: 12),
                _buildCommunityCard(
                  context,
                  'Discussion Forums',
                  'Ask questions and share your experiences',
                  FontAwesomeIcons.comments,
                ),
                const SizedBox(height: 12),
                _buildCommunityCard(
                  context,
                  'Events',
                  'Find diabetes-related events near you',
                  FontAwesomeIcons.calendar,
                ),
                const SizedBox(height: 12),
                _buildCommunityCard(
                  context,
                  'Resource Directory',
                  'Find healthcare providers and services',
                  FontAwesomeIcons.buildingUser,
                ),
                const SizedBox(height: 12),
                _buildCommunityCard(
                  context,
                  'Share Your Story',
                  'Inspire others by sharing your diabetes journey',
                  FontAwesomeIcons.heart,
                ),
                const SizedBox(height: 12),
                _buildCommunityCard(
                  context,
                  'Expert Q&A',
                  'Get answers from diabetes specialists',
                  FontAwesomeIcons.userDoctor,
                ),

                const SizedBox(
                  height: 100,
                ), // Extra space for bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        color: theme.scaffoldBackgroundColor,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle community feature tap
          },
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon container
                Container(
                  height: 44,
                  width: 44,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
