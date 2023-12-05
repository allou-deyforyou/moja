import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '_screen.dart';

class HomeAccountScreen extends StatefulWidget {
  const HomeAccountScreen({
    super.key,
    required this.account,
  });
  final Account account;
  static const name = 'home-account';
  static const path = 'account';
  static const accountKey = 'account';
  @override
  State<HomeAccountScreen> createState() => _HomeAccountScreenState();
}

class _HomeAccountScreenState extends State<HomeAccountScreen> {
  /// Assets
  late Account _currentAccount;

  late TextEditingController _amountTextController;

  void _onSubmitted() {
    context.pop(_currentAccount);
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentAccount = widget.account;
    _amountTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeAccountSliverAppBar(
            name: _currentAccount.name,
            cashin: false,
          ),
          SliverToBoxAdapter(
            child: HomeAccountAmountTextField(
              controller: _amountTextController,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: HomeAccountSubmittedButton(
              onPressed: _onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
