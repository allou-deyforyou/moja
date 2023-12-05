import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeChoiceScreen extends StatefulWidget {
  const HomeChoiceScreen({
    super.key,
    required this.transaction,
  });
  final Transaction transaction;
  static const name = 'home-account';
  static const path = 'account';
  static const transactionKey = 'transaction';
  @override
  State<HomeChoiceScreen> createState() => _HomeChoiceScreenState();
}

class _HomeChoiceScreenState extends State<HomeChoiceScreen> {
  /// Assets
  late final Transaction _currentTransaction;
  late List<Account> _relayAccounts;

  VoidCallback _openAccountScreen(Account account) {
    return () async {
      account = account.copyWith(transaction: _currentTransaction);
      final data = await context.pushNamed<Account>(HomeAccountScreen.name, extra: {
        HomeAccountScreen.accountKey: account,
      });
      if (data != null && mounted) context.pop(data);
    };
  }

  /// AccountService
  late final AsyncController<AsyncState> _accountController;

  void _listenAccountState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _selectAccount();
    } else if (state case SuccessState<List<Account>>(:final data)) {
      _relayAccounts = data;
    } else if (state case FailureState<SelectAccountEvent>(:final code)) {
      switch (code) {}
    }
  }

  Future<void> _selectAccount() {
    return _accountController.run(
      const SelectAccountEvent(),
    );
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentTransaction = widget.transaction;
    _relayAccounts = [];

    /// AccountService
    _accountController = AsyncController(const InitState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          const HomeChoiceSliverAppBar(
            cashin: false,
          ),
          SliverPadding(padding: kMaterialListPadding / 2),
          ControllerConsumer(
            autoListen: true,
            listener: _listenAccountState,
            controller: _accountController,
            builder: (context, state, child) {
              return SliverList.builder(
                itemCount: _relayAccounts.length,
                itemBuilder: (context, index) {
                  final item = _relayAccounts[index];
                  return HomeChoiceCard(
                    onPressed: _openAccountScreen(item),
                    title: item.name,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
