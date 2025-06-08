import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'overview_screen.dart';
import 'log_screen.dart';
import 'log_history_screen.dart';
import 'learn_screen.dart';
import 'community_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isCalendarView = false;
  GlobalKey _logHistoryKey = GlobalKey();
  GlobalKey _overviewKey = GlobalKey();

  // App bar titles for each tab
  final List<String> _titles = ['My Health', 'Log', 'Library', 'Community'];

  // App bar actions for each tab
  List<Widget> _getActions() {
    final theme = Theme.of(context);
    switch (_selectedIndex) {
      case 0: // Overview tab
        return [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: ShapeDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.settings,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      case 1: // Log History tab
        return [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: ShapeDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isCalendarView = !_isCalendarView;
                    });
                  },
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCalendarView ? Icons.list : Icons.calendar_today,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCalendarView ? 'List' : 'Calendar',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      case 2: // Library tab (Learn)
        return [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: ShapeDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.settings,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      case 3: // Community tab
        return [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: ShapeDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.settings,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  void _showLogBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius.only(
          topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
          topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return LogBottomSheet(scrollController: scrollController);
        },
      ),
    ).then((_) {
      // When bottom sheet closes, refresh the appropriate screens
      setState(() {
        if (_selectedIndex == 0) {
          // Overview tab - force rebuild
          _overviewKey = GlobalKey();
        } else if (_selectedIndex == 1) {
          // Log history tab - force rebuild
          _logHistoryKey = GlobalKey();
        }
        // Always refresh both keys since user might switch tabs after logging
        _overviewKey = GlobalKey();
        _logHistoryKey = GlobalKey();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create LogHistoryScreen with current view state
    final Widget logHistoryScreen = LogHistoryScreen(
      key: _logHistoryKey,
      isCalendarView: _isCalendarView,
      onViewToggle: (bool newView) {
        setState(() {
          _isCalendarView = newView;
        });
      },
    );

    final List<Widget> currentScreens = [
      OverviewScreenContent(
        key: _overviewKey,
        onLogButtonPressed: _showLogBottomSheet,
      ),
      logHistoryScreen,
      const LearnScreenContent(),
      const CommunityScreenContent(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _getActions(),
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: currentScreens[_selectedIndex],
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 18,
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
            onTap: _showLogBottomSheet,
            customBorder: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 18,
                cornerSmoothing: 0.6,
              ),
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: GNav(
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(milliseconds: 300),
              tabBackgroundColor: theme.colorScheme.primary,
              tabBorderRadius: 16,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
              backgroundColor: theme.cardColor,
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: const [
                GButton(icon: Icons.home_outlined, text: 'Overview'),
                GButton(icon: Icons.history, text: 'Log'),
                GButton(icon: Icons.menu_book_outlined, text: 'Learn'),
                GButton(icon: Icons.people_outline, text: 'Community'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
