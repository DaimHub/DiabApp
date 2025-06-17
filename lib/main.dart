import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_details_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/medication_reminders_screen.dart';
import 'screens/export_data_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'providers/auth_provider.dart' as auth;
import 'providers/glucose_data_provider.dart';
import 'providers/medication_data_provider.dart';
import 'providers/glucose_trend_data_provider.dart';
import 'providers/log_history_data_provider.dart';
import 'providers/learn_articles_provider.dart';
import 'providers/settings_data_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/blood_sugar_reminder_service.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service
  await NotificationService.initialize();

  // Initialize blood sugar reminders
  await BloodSugarReminderService.initializeReminders();

  // TODO: REMOVE AFTER ARTICLES ARE CREATED - One-time article population
  // try {
  //   await FirestoreService.populateArticlesOnce();
  // } catch (e) {
  //   // Article population failed
  // }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => auth.AuthProvider()),
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        ChangeNotifierProvider(create: (context) => GlucoseDataProvider()),
        ChangeNotifierProvider(create: (context) => MedicationDataProvider()),
        ChangeNotifierProvider(create: (context) => GlucoseTrendDataProvider()),
        ChangeNotifierProvider(create: (context) => LogHistoryDataProvider()),
        ChangeNotifierProvider(create: (context) => LearnArticlesProvider()),
        ChangeNotifierProvider(create: (context) => SettingsDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return ToastificationWrapper(
          child: Consumer<auth.AuthProvider>(
            builder: (context, authProvider, child) {
              return MaterialApp(
                title: 'DiabApp',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(),
                darkTheme: AppTheme.darkTheme(),
                themeMode: themeManager.themeMode,
                navigatorObservers: [routeObserver],
                home: _getHomeScreen(authProvider.status),
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/register': (context) => const RegisterScreen(),
                  '/register-details': (context) {
                    final args =
                        ModalRoute.of(context)?.settings.arguments
                            as Map<String, dynamic>?;
                    return RegisterDetailsScreen(
                      firstName: args?['firstName'] ?? '',
                      lastName: args?['lastName'] ?? '',
                      email: args?['email'] ?? '',
                      password: args?['password'] ?? '',
                    );
                  },
                  '/dashboard': (context) => const DashboardScreen(),
                  '/profile-edit': (context) => const ProfileEditScreen(),
                  '/medication-reminders': (context) =>
                      const MedicationRemindersScreen(),
                  '/export-data': (context) => const ExportDataScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _getHomeScreen(auth.AuthStatus authStatus) {
    switch (authStatus) {
      case auth.AuthStatus.uninitialized:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case auth.AuthStatus.authenticated:
        return const DashboardScreen();
      case auth.AuthStatus.unauthenticated:
        return const WelcomeScreen();
    }
  }
}
