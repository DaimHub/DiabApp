import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:figma_squircle/figma_squircle.dart';

class LearnScreenContent extends StatelessWidget {
  const LearnScreenContent({super.key});

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

                // Search Bar - interactive with squircle styling
                Container(
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
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF3A3A3A)
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Handle search tap
                      },
                      customBorder: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Search for articles',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Featured Section
                Text(
                  'Featured',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),

                // Featured Articles
                _buildFeaturedArticle(
                  context,
                  'Understanding Your Blood Sugar Levels',
                  'Learn about the importance of monitoring your blood sugar and what the numbers mean.',
                  FontAwesomeIcons.droplet,
                ),
                const SizedBox(height: 16),
                _buildFeaturedArticle(
                  context,
                  'Healthy Eating for Diabetes',
                  'Discover delicious and nutritious meal plans tailored for managing diabetes.',
                  FontAwesomeIcons.utensils,
                ),
                const SizedBox(height: 16),
                _buildFeaturedArticle(
                  context,
                  'Exercise and Diabetes Management',
                  'Learn how physical activity can help manage your diabetes effectively.',
                  FontAwesomeIcons.personRunning,
                ),

                const SizedBox(height: 30),

                // Categories Section
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),

                // Categories - now using consistent card design
                _buildCategoryCard(
                  context,
                  'Nutrition',
                  'Diet tips and meal planning',
                  FontAwesomeIcons.utensils,
                ),
                const SizedBox(height: 12),
                _buildCategoryCard(
                  context,
                  'Exercise',
                  'Workout routines and activities',
                  FontAwesomeIcons.dumbbell,
                ),
                const SizedBox(height: 12),
                _buildCategoryCard(
                  context,
                  'Medication',
                  'Treatment and medication guides',
                  FontAwesomeIcons.pills,
                ),
                const SizedBox(height: 12),
                _buildCategoryCard(
                  context,
                  'Heart Health',
                  'Cardiovascular wellness tips',
                  FontAwesomeIcons.heart,
                ),
                const SizedBox(height: 12),
                _buildCategoryCard(
                  context,
                  'Mental Health',
                  'Stress management and wellbeing',
                  FontAwesomeIcons.faceSmile,
                ),
                const SizedBox(height: 12),
                _buildCategoryCard(
                  context,
                  'FAQ',
                  'Frequently asked questions',
                  FontAwesomeIcons.circleQuestion,
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

  Widget _buildFeaturedArticle(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
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
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle article tap
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
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 14,
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
                      size: 22,
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
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.3,
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

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
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
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle category tap
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
