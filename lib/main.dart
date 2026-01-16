import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/community_hatim_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/hatim_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/insights_provider.dart';
import 'providers/language_provider.dart';
import 'services/storage_service.dart';
import 'services/quran_content_service.dart';
import 'l10n/app_localizations.dart';

// Import Firebase only when not on web
import 'services/firebase_auth_service.dart';
import 'services/sync_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting Hatim Tracker...');
  print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
  
  // Initialize Hive FIRST for web compatibility
  try {
    print('📦 Initializing Hive...');
    await Hive.initFlutter();
    print('✅ Hive initialized successfully');
  } catch (e) {
    print('⚠️ Hive initialization error: $e');
    // Continue - web may use IndexedDB
  }
  
  // Initialize storage service
  final storageService = StorageService();
  try {
    print('💾 Initializing storage...');
    await storageService.init();
    print('✅ Storage initialized successfully');
  } catch (e) {
    print('⚠️ Storage error: $e');
    // Continue with limited functionality
  }
  
  // Initialize Quran content service
  final quranService = QuranContentService();
  try {
    print('📖 Loading Quran content...');
    await quranService.initialize();
    print('✅ Quran content loaded successfully');
  } catch (e) {
    print('⚠️ Quran loading error: $e');
    // Will use placeholder text
  }
  
  // Firebase services (only on mobile, skip on web)
  FirebaseAuthService? authService;
  SyncService? syncService;
  
  if (!kIsWeb) {
    try {
      print('🔐 Initializing Firebase (mobile only)...');
      await Firebase.initializeApp();
      authService = FirebaseAuthService();
      syncService = SyncService(authService, storageService);
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('⚠️ Firebase error: $e');
      authService = null;
      syncService = null;
    }
  } else {
    print('⏭️ Skipping Firebase (web mode)');
    authService = null;
    syncService = null;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => HatimProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProvider(create: (_) => InsightsProvider(storageService)),
        if (authService != null) Provider.value(value: authService),
        if (syncService != null) Provider.value(value: syncService),
        Provider.value(value: quranService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Pocket Khatm',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          locale: languageProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('tr', ''),
            Locale('ar', ''),
          ],
          home: const AuthWrapper(),
          routes: {
            '/auth': (context) => const AuthScreen(),
            '/main': (context) => const MainScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasSeenAuthScreen = false;

  @override
  Widget build(BuildContext context) {
    // Web'de: İlk açılışta AuthScreen göster, sonra MainScreen'e geç
    if (kIsWeb) {
      if (!_hasSeenAuthScreen) {
        // Web'de Firebase olmadan AuthScreen göster (sadece UI)
        return AuthScreen(
          onSkip: () {
            setState(() {
              _hasSeenAuthScreen = true;
            });
          },
        );
      }
      return const MainScreen();
    }

    // Mobile'da Firebase auth kontrolü yap
    try {
      // Sadece mobile'da Firebase kullan
      final auth = FirebaseAuth.instance;
      return StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppTheme.warmCream,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If user is authenticated, show MainScreen
          if (snapshot.hasData) {
            return const MainScreen();
          }

          // If no user, force AuthScreen
          return const AuthScreen();
        },
      );
    } catch (e) {
      print('Firebase auth error: $e');
      // Firebase hatası durumunda MainScreen göster (offline mode)
      return const MainScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityHatimScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: localizations?.homeTitle ?? 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: localizations?.community ?? 'Community',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: localizations?.profile ?? 'Profile',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: localizations?.settingsTitle ?? 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
