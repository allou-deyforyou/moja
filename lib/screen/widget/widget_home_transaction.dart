import 'package:flutter/material.dart';

import '_widget.dart';

class HomeTransactionAppBar extends StatelessWidget {
  const HomeTransactionAppBar({
    super.key,
    required this.title,
    required this.trailing,
  });
  final Widget title;
  final Widget trailing;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      leading: const Center(child: CustomBackButton()),
      title: title,
      actions: [Padding(padding: kTabLabelPadding, child: trailing)],
    );
  }
}

class HomeTransactionCashInText extends StatelessWidget {
  const HomeTransactionCashInText({
    super.key,
    required this.account,
  });
  final String account;
  @override
  Widget build(BuildContext context) {
    return Text("Dépôt $account");
  }
}

class HomeTransactionCashOutText extends StatelessWidget {
  const HomeTransactionCashOutText({
    super.key,
    required this.account,
  });
  final String account;
  @override
  Widget build(BuildContext context) {
    return Text("Retrait $account");
  }
}


class HomeTransactionAmountTextField extends StatelessWidget {
  const HomeTransactionAmountTextField({
    super.key,
    this.controller,
  });
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: IntrinsicWidth(
        child: TextField(
          autofocus: true,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 34.0),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: false,
            border: InputBorder.none,
            suffixIcon: Text("Francs"),
            hintText: "Montant",
          ),
        ),
      ),
    );
  }
}

class HomeTransactionSuggestionListView extends StatelessWidget {
  const HomeTransactionSuggestionListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 6.0);
        },
      ),
    );
  }
}

class HomeTransactionSuggestionItemWidget extends StatelessWidget {
  const HomeTransactionSuggestionItemWidget({
    super.key,
    required this.amount,
    this.selected = false,
    required this.onSelected,
  });

  final double amount;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      label: Text("${amount.toInt()} F"),
    );
  }
}

class HomeTransactionSubmittedButton extends StatelessWidget {
  const HomeTransactionSubmittedButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onPressed,
        child: const Text("Terminé"),
      ),
    );
  }
}
