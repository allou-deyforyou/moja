import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screen/_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Assets
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    /// Assets
    _router = GoRouter(
      initialLocation: OnBoardingScreen.path,
      routes: [
        GoRoute(
          name: HomeScreen.name,
          path: HomeScreen.path,
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
                    account: data[HomeAccountScreen.accountKey],
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
                    transaction: data[HomeChoiceScreen.transactionKey],
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
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      darkTheme: AppThemes.darkTheme,
      theme: AppThemes.theme,
      routerConfig: _router,
    );
  }
}
