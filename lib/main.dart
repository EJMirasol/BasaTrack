import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/storage_service.dart';
import 'providers/reading_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/sync_provider.dart';
import 'ui/screens/main_navigation.dart';
import 'ui/screens/login_screen.dart';
import 'data/services/notification_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Google Fonts to not fetch at runtime (use bundled fonts)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize notifications (permissions will be requested from home screen)
  final notificationService = NotificationService();
  await notificationService.init();

  // Initialize local storage
  final storageService = StorageService();
  await storageService.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const BibleDailyReadingApp());
}

class BibleDailyReadingApp extends StatelessWidget {
  const BibleDailyReadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider (first, as others depend on it)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Sync Provider (depends on auth)
        ChangeNotifierProxyProvider<AuthProvider, SyncProvider>(
          create: (context) => SyncProvider(
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, auth, previous) => previous ?? SyncProvider(
            authProvider: auth,
          ),
        ),
        // Reading Provider
        ChangeNotifierProvider(
          create: (_) => ReadingProvider(),
        ),
        // Streak Provider
        ChangeNotifierProvider(
          create: (_) => StreakProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Theme Configuration (Dark mode disabled - always use light theme)
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,

        // Authentication-based routing
        home: Consumer2<AuthProvider, SyncProvider>(
          builder: (context, authProvider, syncProvider, child) {
            // Show loading while checking auth state
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // If signed in, show home screen
            if (authProvider.isSignedIn) {
              // Perform initial sync on first sign-in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (syncProvider.lastSyncTime == null) {
                  syncProvider.performInitialSync();
                }
              });
              return const MainNavigation();
            }

            // Otherwise, show login screen
            return const LoginScreen();
          },
        ),

        // Route Configuration
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return authProvider.isSignedIn
                        ? const MainNavigation()
                        : const LoginScreen();
                  },
                ),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const MainNavigation(),
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return authProvider.isSignedIn
                        ? const MainNavigation()
                        : const LoginScreen();
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
