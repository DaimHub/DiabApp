import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'providers/glucose_data_provider.dart';
import 'providers/medication_data_provider.dart';
import 'providers/glucose_trend_data_provider.dart';
import 'providers/log_history_data_provider.dart';
import 'providers/learn_articles_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TODO: REMOVE AFTER ARTICLES ARE CREATED - One-time article population
  // print('🚀 Attempting to populate articles...');
  // try {
  //   await FirestoreService.populateArticlesOnce();
  // } catch (e) {
  //   print('❌ Article population failed: $e');
  // }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        ChangeNotifierProvider(create: (context) => GlucoseDataProvider()),
        ChangeNotifierProvider(create: (context) => MedicationDataProvider()),
        ChangeNotifierProvider(create: (context) => GlucoseTrendDataProvider()),
        ChangeNotifierProvider(create: (context) => LogHistoryDataProvider()),
        ChangeNotifierProvider(create: (context) => LearnArticlesProvider()),
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
          child: MaterialApp(
            title: 'DiabApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeManager.themeMode,
            navigatorObservers: [routeObserver],
            initialRoute: '/',
            routes: {
              '/': (context) => const WelcomeScreen(),
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
          ),
        );
      },
    );
  }
}
