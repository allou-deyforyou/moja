import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class HomeAccountSliverAppBar extends StatelessWidget {
  const HomeAccountSliverAppBar({super.key, required this.title});
  final Widget title;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: title,
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeAccountCashInText extends StatelessWidget {
  const HomeAccountCashInText({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text("Déposer de l'argent via");
  }
}

class HomeAccountCashOutText extends StatelessWidget {
  const HomeAccountCashOutText({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text("Retirer de l'argent via");
  }
}

class HomeAccountSliverList extends StatelessWidget {
  const HomeAccountSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: kTabLabelPadding,
      sliver: SliverList.separated(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0),
        ),
      ),
    );
  }
}

class HomeAccountCard extends StatelessWidget {
  const HomeAccountCard({
    super.key,
    this.onPressed,
    required this.title,
  });
  final String title;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return HomeMenuListTile(
      onTap: onPressed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      leading: const CircleAvatar(backgroundColor: Colors.black),
      title: Text(title),
      trailing: const Icon(CupertinoIcons.right_chevron, size: 14.0),
    );
  }
}
