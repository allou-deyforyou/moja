import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '_screen.dart';

class HomeAccountScreen extends StatefulWidget {
  const HomeAccountScreen({
    super.key,
    required this.currentRelay,
    required this.currentAccount,
  });
  final Relay? currentRelay;
  final Account currentAccount;
  static const name = 'home-account';
  static const path = 'account';
  static const currentRelayKey = 'currentRelay';
  static const currentAccountKey = 'currentAccount';
  @override
  State<HomeAccountScreen> createState() => _HomeAccountScreenState();
}

class _HomeAccountScreenState extends State<HomeAccountScreen> {
  /// Assets
  late final Relay? _currentRelay;
  late final Account _currentAccount;

  late TextEditingController _amountTextController;

  double get _amount {
    return double.tryParse(_amountTextController.text.replaceAll('.', '').trimSpace()) ?? 0;
  }

  void _onSubmitted() {
    context.pop(_currentAccount.copyWith(amount: _amount));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentRelay = widget.currentRelay;
    _currentAccount = widget.currentAccount;
    final amount = _currentAccount.amount?.formatted;
    _amountTextController = TextEditingController(text: amount);
    _amountTextController.selection = TextSelection(
      extentOffset: amount?.length ?? 0,
      baseOffset: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeAccountSliverAppBar(
            cashin: _currentAccount.transaction == Transaction.cashin,
            image: _currentAccount.image,
            name: _currentAccount.name,
            relay: _currentRelay?.name,
          ),
          SliverToBoxAdapter(
            child: HomeAccountAmountTextField(
              currency: _currentAccount.country?.currency,
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
