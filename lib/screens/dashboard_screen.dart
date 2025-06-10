import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isCalendarView = false;
  GlobalKey _logHistoryKey = GlobalKey();
  GlobalKey _overviewKey = GlobalKey();

  final List<String> _titles = ['My Health', 'Log', 'Library', 'Community'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        // Always refresh both keys since user might switch tabs after logging
        _overviewKey = GlobalKey();
        _logHistoryKey = GlobalKey();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> screens = [
      OverviewScreenContent(
        key: _overviewKey,
        onLogButtonPressed: _showLogBottomSheet,
      ),
      LogHistoryScreen(
        key: _logHistoryKey,
        isCalendarView: _isCalendarView,
        onViewToggle: (bool newView) {
          setState(() {
            _isCalendarView = newView;
          });
        },
      ),
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
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: _selectedIndex == 1
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCalendarView = !_isCalendarView;
                      });
                    },
                    icon: Icon(
                      _isCalendarView ? Icons.list : Icons.calendar_today,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    label: Text(
                      _isCalendarView ? 'List' : 'Calendar',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: screens[_selectedIndex],
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
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Refresh keys when switching tabs
            if (index == 0) {
              _overviewKey = GlobalKey();
            } else if (index == 1) {
              _logHistoryKey = GlobalKey();
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[500],
        selectedFontSize: 12,
        unselectedFontSize: 12,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house, size: 22),
            activeIcon: FaIcon(FontAwesomeIcons.house, size: 22),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.clock, size: 22),
            activeIcon: FaIcon(FontAwesomeIcons.clock, size: 22),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.book, size: 22),
            activeIcon: FaIcon(FontAwesomeIcons.book, size: 22),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.users, size: 22),
            activeIcon: FaIcon(FontAwesomeIcons.users, size: 22),
            label: 'Community',
          ),
        ],
      ),
    );
  }
}
