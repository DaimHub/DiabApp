import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:provider/provider.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/learn_articles_provider.dart';
import '../models/article.dart';

class LearnScreenContent extends StatefulWidget {
  const LearnScreenContent({super.key});

  @override
  State<LearnScreenContent> createState() => _LearnScreenContentState();
}

class _LearnScreenContentState extends State<LearnScreenContent> {
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter functionality
  Set<String> _selectedFilters = {
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  };

  @override
  void initState() {
    super.initState();
    _loadArticles();

    // Listen to search changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    final provider = Provider.of<LearnArticlesProvider>(context, listen: false);
    await provider.getArticles();
  }

  // Filter articles based on selected filters
  List<Article> _getFilteredByChips(List<Article> articles) {
    if (_selectedFilters.contains('All')) {
      return articles;
    }

    return articles.where((article) {
      // Check if article matches any selected difficulty filter
      return _selectedFilters.contains(_capitalizeFirst(article.difficulty));
    }).toList();
  }

  // Helper function to capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Filter articles based on search query and filters combined
  List<Article> _getFilteredArticles(List<Article> articles) {
    // First apply filter chips
    List<Article> filteredByChips = _getFilteredByChips(articles);

    // Then apply search query
    if (_searchQuery.isEmpty) {
      return filteredByChips;
    }

    return filteredByChips.where((article) {
      final searchLower = _searchQuery.toLowerCase();
      return article.title.toLowerCase().contains(searchLower) ||
          article.difficulty.toLowerCase().contains(searchLower) ||
          article.tags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<LearnArticlesProvider>(
          builder: (context, articlesProvider, child) {
            return LiquidPullToRefresh(
              onRefresh: () => articlesProvider.refreshData(),
              color: theme.colorScheme.primary,
              backgroundColor: theme.scaffoldBackgroundColor,
              height: 80,
              animSpeedFactor: 6,
              showChildOpacityTransition: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Search Bar - functional with squircle styling
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
                                        ? theme.colorScheme.primary.withOpacity(
                                            0.8,
                                          )
                                        : theme.brightness == Brightness.dark
                                        ? const Color(0xFF3A3A3A)
                                        : Colors.grey[200]!,
                                    width: isFocused ? 2 : 1,
                                  ),
                                ),
                                shadows: isFocused
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                  cornerRadius: 16,
                                  cornerSmoothing: 0.6,
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search for articles...',
                                    hintStyle: TextStyle(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withOpacity(0.6),
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            const SizedBox(width: 12),
                            _buildFilterChip('Beginner'),
                            const SizedBox(width: 12),
                            _buildFilterChip('Intermediate'),
                            const SizedBox(width: 12),
                            _buildFilterChip('Advanced'),
                          ],
                        ),
                      ),

                      // Search results count (always show when articles are available)
                      if (articlesProvider.hasData) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Builder(
                            builder: (context) {
                              final filteredArticles = _getFilteredArticles(
                                articlesProvider.articles!,
                              );
                              return Text(
                                filteredArticles.length == 1
                                    ? '1 article found'
                                    : '${filteredArticles.length} articles found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Articles Section
                      if (articlesProvider.isLoading &&
                          !articlesProvider.hasData) ...[
                        // Loading state
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading articles...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (articlesProvider.hasData) ...[
                        // Display filtered articles
                        Builder(
                          builder: (context) {
                            final filteredArticles = _getFilteredArticles(
                              articlesProvider.articles!,
                            );

                            if (filteredArticles.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        _searchQuery.isNotEmpty
                                            ? Icons.search_off
                                            : Icons.filter_list_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'No articles found'
                                            : 'No articles match the selected filters',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'Try searching with different keywords'
                                            : 'Try selecting different difficulty levels',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: filteredArticles.map((article) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildArticleCard(context, article),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ] else if (articlesProvider.error != null) ...[
                        // Error state
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load articles',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pull down to retry',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // No articles
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.bookOpen,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No articles available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for new content',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 100,
                      ), // Extra space for bottom navigation
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
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
            _showArticleBottomSheet(context, article);
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
                      _getIconForArticle(article),
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
                        article.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.summary,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (article.readTime > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${article.readTime} min',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article.difficulty.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodySmall?.color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
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

  IconData _getIconForArticle(Article article) {
    // Return different icons based on article tags or title
    if (article.tags.contains('glucose') ||
        article.tags.contains('monitoring')) {
      return FontAwesomeIcons.droplet;
    } else if (article.tags.contains('nutrition') ||
        article.tags.contains('carbs')) {
      return FontAwesomeIcons.utensils;
    } else if (article.tags.contains('exercise') ||
        article.tags.contains('activity')) {
      return FontAwesomeIcons.personRunning;
    } else if (article.tags.contains('medication')) {
      return FontAwesomeIcons.pills;
    } else {
      return FontAwesomeIcons.book;
    }
  }

  void _showArticleBottomSheet(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius.only(
          topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
          topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
        ),
      ),
      builder: (context) => ArticleBottomSheet(article: article),
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

  Widget _buildFilterChip(String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilters.contains(label);
    final chipColor = label == 'All'
        ? theme.colorScheme.primary
        : _getDifficultyColor(context, label);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (bool value) {
        setState(() {
          if (label == 'All') {
            if (isSelected) {
              // If "All" is selected, deselect everything
              _selectedFilters.clear();
            } else {
              // If "All" is not selected, select everything
              _selectedFilters = {
                'All',
                'Beginner',
                'Intermediate',
                'Advanced',
              };
            }
          } else {
            // For other filters
            if (isSelected) {
              _selectedFilters.remove(label);
              // If we deselect a specific filter, also deselect "All"
              _selectedFilters.remove('All');
            } else {
              _selectedFilters.add(label);
              // Check if all individual filters are now selected
              if (_selectedFilters.contains('Beginner') &&
                  _selectedFilters.contains('Intermediate') &&
                  _selectedFilters.contains('Advanced')) {
                _selectedFilters.add('All');
              }
            }
          }
        });
      },
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 10,
          cornerSmoothing: 0.6,
        ),
        side: BorderSide(
          color: isSelected
              ? chipColor
              : theme.brightness == Brightness.dark
              ? const Color(0xFF4A4A4A)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      backgroundColor: isSelected
          ? chipColor
          : theme.brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : Colors.white,
      selectedColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Helper function to get color for each difficulty level
  Color _getDifficultyColor(BuildContext context, String difficulty) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;

    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return baseColor.withOpacity(0.85); // 85% opacity
      case 'intermediate':
        return baseColor.withOpacity(0.75); // 75% opacity
      case 'advanced':
        return baseColor.withOpacity(0.65); // 65% opacity
      default:
        return baseColor;
    }
  }
}

class ArticleBottomSheet extends StatelessWidget {
  final Article article;

  const ArticleBottomSheet({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: ShapeDecoration(
        color: theme.scaffoldBackgroundColor,
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineSmall?.color,
                    ),
                  ),
                ),
                Container(
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
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.close,
                          color: theme.iconTheme.color,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article image (if available)
                  if (article.imageUrl != null &&
                      article.imageUrl!.isNotEmpty) ...[
                    ClipSmoothRect(
                      radius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                          article.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[600],
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Article meta info
                  Row(
                    children: [
                      if (article.readTime > 0) ...[
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readTime} min read',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.person,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.author,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Article content
                  MarkdownBody(
                    data: _processMarkdownContent(article.content),
                    styleSheet: MarkdownStyleSheet(
                      h1: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                        height: 1.3,
                      ),
                      h2: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                        height: 1.3,
                      ),
                      h3: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.headlineSmall?.color,
                        height: 1.3,
                      ),
                      p: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      listBullet: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: theme.colorScheme.primary,
                      ),
                      code: TextStyle(
                        fontSize: 14,
                        backgroundColor: theme.brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        color: theme.colorScheme.primary,
                      ),
                      blockquotePadding: const EdgeInsets.all(16),
                      blockquoteDecoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _processMarkdownContent(String content) {
    // Convert literal \n to actual newlines
    return content
        .replaceAll('\\n', '\n') // Convert literal \n to actual newlines
        .replaceAll('\n\n\n', '\n\n'); // Clean up any triple newlines
  }
}
