import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeAccountScreen extends StatefulWidget {
  const HomeAccountScreen({super.key, required this.transactionType});
  final TransactionType transactionType;
  static const name = 'home-selector';
  static const path = 'selector';
  @override
  State<HomeAccountScreen> createState() => _HomeAccountScreenState();
}

class _HomeAccountScreenState extends State<HomeAccountScreen> {
  /// Assets
  late TransactionType _transactionType;

  void _pushCashInSheet(Account account) async {
    final data = await context.pushNamed<Transaction>(HomeTransactionScreen.name,
        extra: Transaction(
          account: account,
          type: _transactionType,
        ));
    if (data != null && mounted) context.pop(data);
  }

  /// AccountService
  late final AccountService _accountService;

  void _listenAccountState(BuildContext context, AccountState state) {
    if (state is AccountStateInit) {
      SchedulerBinding.instance.endOfFrame.whenComplete(_searchAccount);
    }
  }

  Future<void> _searchAccount() {
    return _accountService.add(const SearchAccount(live: true));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _transactionType = widget.transactionType;

    /// AccountService
    _accountService = AccountService.instance();
  }

  @override
  void didUpdateWidget(covariant HomeAccountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactionType != widget.transactionType) {
      _transactionType = widget.transactionType;
      _accountService.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeAccountSliverAppBar(
            title: switch (_transactionType) {
              TransactionType.cashin => const HomeAccountCashInText(),
              TransactionType.cashout => const HomeAccountCashOutText(),
            },
          ),
          ControllerConsumer(
            autoListen: true,
            listener: _listenAccountState,
            controller: _accountService,
            builder: (context, state, child) {
              return switch (state) {
                AccountStateAccountList(:var data) => HomeAccountSliverList(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return HomeAccountCard(
                        onPressed: () => _pushCashInSheet(item),
                        title: item.name,
                      );
                    },
                  ),
                _ => const SliverToBoxAdapter(),
              };
            },
          ),
        ],
      ),
    );
  }
}
