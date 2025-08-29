import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'utils/app_theme.dart';
 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isOnboardingComplete = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      setState(() {
        _isOnboardingComplete = onboardingComplete;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking onboarding status: $e');
      setState(() {
        _isOnboardingComplete = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ref.watch(themeServiceProvider);
    final languageService = ref.watch(languageServiceProvider);
    final authState = ref.watch(authStateProvider);

    print('MainApp: Building with theme mode: ${themeService.themeMode} and language: ${languageService.currentLocale}');

    // Show loading while checking onboarding status
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Show onboarding if not complete
    if (!_isOnboardingComplete) {
      return MaterialApp(
        title: 'CyberShujaa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildLightTheme(),
        darkTheme: AppTheme.buildDarkTheme(),
        home: const OnboardingScreen(),
      );
    }

    // Show main app if onboarding is complete
    return MaterialApp(
      title: 'CyberShujaa',
      debugShowCheckedModeBanner: false,
      themeMode: themeService.themeMode,
      locale: languageService.currentLocale,
      supportedLocales: languageService.supportedLanguages
          .map((lang) => Locale(lang['code'] as String))
          .toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.buildLightTheme(),
      darkTheme: AppTheme.buildDarkTheme(),
      onGenerateTitle: (context) {
        print('MainApp: Title generated for locale: ${languageService.currentLocale}');
        return 'CyberShujaa';
      },
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
      routes: {
        '/missions': (context) => const MainNavigationScreen(initialIndex: 1),
      },
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainNavigationScreen();
          }
          return const LoginScreen();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const LoginScreen(),
      ),
    );
  }
}