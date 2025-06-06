import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

                // Search Bar - interactive with original styling
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Handle search tap
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0F1F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search for articles',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 16,
                            ),
                          ),
                        ],
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
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle article tap
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
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(12),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Article',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
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
    );
  }

  Widget _buildCategoryCard(
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
          // Handle category tap
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
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.8,
                        ),
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
