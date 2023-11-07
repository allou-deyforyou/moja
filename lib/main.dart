import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                return const DialogPage(
                  child: HomeMenuScreen(),
                );
              },
            ),
            GoRoute(
              name: HomeSearchScreen.name,
              path: HomeSearchScreen.path,
              pageBuilder: (context, state) {
                return const DialogPage(
                  child: HomeSearchScreen(),
                );
              },
            ),
            GoRoute(
              name: HomeAccountScreen.name,
              path: HomeAccountScreen.path,
              pageBuilder: (context, state) {
                final data = state.extra as TransactionType;
                return DialogPage<Transaction>(
                  child: HomeAccountScreen(
                    transactionType: data,
                  ),
                );
              },
            ),
            GoRoute(
              name: HomeTransactionScreen.name,
              path: HomeTransactionScreen.path,
              pageBuilder: (context, state) {
                final data = state.extra as Transaction;
                return DialogPage<Transaction>(
                  child: HomeTransactionScreen(
                    transaction: data,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      darkTheme: AppThemes.darkTheme,
      theme: AppThemes.theme,
      routerConfig: _router,
    );
  }
}
