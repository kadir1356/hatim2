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
import 'services/local_auth_service.dart'; // Local-only auth (no Firebase)
import 'l10n/app_localizations.dart';

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
  
  // LOCAL AUTH SERVICE (Firebase disabled)
  print('📱 Using local-only auth service (no Firebase)');
  final authService = LocalAuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => HatimProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProvider(create: (_) => InsightsProvider(storageService)),
        Provider.value(value: authService), // LocalAuthService
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

    // FIREBASE DISABLED - Skip auth, go directly to MainScreen
    return const MainScreen();
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
