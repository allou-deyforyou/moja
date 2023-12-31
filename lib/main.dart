import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:service_tools/service_tools.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screen/_screen.dart';

void main() {
  runService(const MyService()).then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Assets
  late final GoRouter _router;

  Stream<ThemeMode>? _themeModeStream;
  ThemeMode? _currentThemeMode;

  Stream<Locale?>? _localeStream;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentLocale = HiveLocalDB.locale;
    _localeStream = HiveLocalDB.localeStream;

    _currentThemeMode = HiveLocalDB.themeMode;
    _themeModeStream = HiveLocalDB.themeModeStream;

    _router = GoRouter(
      observers: [
        FirebaseAnalyticsObserver(
          analytics: FirebaseConfig.firebaseAnalytics,
        ),
      ],
      routes: [
        GoRoute(
          name: HomeScreen.name,
          path: HomeScreen.path,
          redirect: HomeScreen.redirect,
          pageBuilder: (context, state) {
            return const NoTransitionPage<void>(
              child: HomeScreen(),
            );
          },
          routes: [
            GoRoute(
              name: HomeMenuScreen.name,
              path: HomeMenuScreen.path,
              pageBuilder: (context, state) {
                return const CupertinoPage(
                  fullscreenDialog: true,
                  child: HomeMenuScreen(),
                );
              },
            ),
            GoRoute(
              name: HomeAccountScreen.name,
              path: HomeAccountScreen.path,
              pageBuilder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                return DialogPage<Account>(
                  child: HomeAccountScreen(
                    currentAccount: data[HomeAccountScreen.currentAccountKey],
                    currentRelay: data[HomeAccountScreen.currentRelayKey],
                  ),
                );
              },
            ),
            GoRoute(
              name: HomeChoiceScreen.name,
              path: HomeChoiceScreen.path,
              pageBuilder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                return DialogPage<Account>(
                  child: HomeChoiceScreen(
                    currentTransaction: data[HomeChoiceScreen.currentTransactionKey],
                    currentPosition: data[HomeChoiceScreen.currentPositionKey],
                    currentRelay: data[HomeChoiceScreen.currentRelayKey],
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: OnBoardingScreen.name,
          path: OnBoardingScreen.path,
          pageBuilder: (context, state) {
            return const CupertinoPage(
              child: OnBoardingScreen(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _localeStream,
      initialData: _currentLocale,
      builder: (context, localeSnapshot) {
        return StreamBuilder<ThemeMode>(
          stream: _themeModeStream,
          initialData: _currentThemeMode,
          builder: (context, themeModeSnapshot) {
            return MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: localeSnapshot.data?.normalize(),
              themeMode: themeModeSnapshot.data,
              color: AppThemes.primaryColor,
              darkTheme: AppThemes.darkTheme,
              theme: AppThemes.theme,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}
