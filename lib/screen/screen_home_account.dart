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
    _currentAccount = widget.account;
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
          ),
          SliverToBoxAdapter(
            child: HomeAccountAmountTextField(
              currency: _currentAccount.country.value?.currency,
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
