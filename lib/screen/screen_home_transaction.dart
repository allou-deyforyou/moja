import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '_screen.dart';

class HomeTransactionScreen extends StatefulWidget {
  const HomeTransactionScreen({
    super.key,
    required this.transaction,
  });
  static const name = 'home-transaction';
  static const path = 'transaction';
  final Transaction transaction;
  @override
  State<HomeTransactionScreen> createState() => _HomeTransactionScreenState();
}

class _HomeTransactionScreenState extends State<HomeTransactionScreen> {
  /// Assets
  late Transaction _transaction;
  late List<(double, bool)> _amountSuggestions;
  late TextEditingController _amountTextController;

  void _onSubmitted() {
    context.pop(_transaction.copyWith(amount: double.tryParse(_amountTextController.text)));
  }

  void _setupData() {
    _transaction = widget.transaction;
    _amountSuggestions = _transaction.amountSuggestions.map((e) => (e, false)).toList();
    _amountTextController = TextEditingController(text: _transaction.amount?.toString());
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _setupData();
  }

  @override
  void didUpdateWidget(covariant HomeTransactionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transaction != widget.transaction) {
      _setupData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeTransactionAppBar(
            title: switch (_transaction.type) {
              TransactionType.cashin => HomeTransactionCashInText(
                  account: _transaction.account.name,
                ),
              TransactionType.cashout => HomeTransactionCashOutText(
                  account: _transaction.account.name,
                ),
            },
            trailing: const CircleAvatar(),
          ),
          SliverToBoxAdapter(
            child: HomeTransactionAmountTextField(controller: _amountTextController),
          ),
          SliverToBoxAdapter(
            child: StatefulBuilder(
              builder: (context, setState) {
                return HomeTransactionSuggestionListView(
                  itemCount: _amountSuggestions.length,
                  itemBuilder: (context, index) {
                    final (amount, selected) = _amountSuggestions[index];
                    return HomeTransactionSuggestionItemWidget(
                      onSelected: (selected) => setState(
                        () => _amountSuggestions[index] = (amount, selected),
                      ),
                      selected: selected,
                      amount: amount,
                    );
                  },
                );
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: HomeTransactionSubmittedButton(
              onPressed: _onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
