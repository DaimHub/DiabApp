import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle community feature tap
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 18,
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
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
