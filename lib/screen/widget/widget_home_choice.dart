import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class HomeChoiceSliverAppBar extends StatelessWidget {
  const HomeChoiceSliverAppBar({
    super.key,
    required this.cashin,
  });
  final bool cashin;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      leadingWidth: 64.0,
      toolbarHeight: 64.0,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      titleTextStyle: theme.textTheme.headlineSmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        wordSpacing: 1.0,
      ),
      title: Visibility(
        visible: cashin,
        replacement: Text(localizations.searchwithdrawalpoints.toUpperCase()),
        child: Text(localizations.searchdepositpoints.toUpperCase()),
      ),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeChoiceCard extends StatelessWidget {
  const HomeChoiceCard({
    super.key,
    this.onPressed,
    required this.title,
  });
  final String title;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onPressed,
      contentPadding: kTabLabelPadding.copyWith(top: 16.0, bottom: 16.0),
      leading: const CircleAvatar(backgroundColor: Colors.black),
      title: Text(title),
      trailing: const Icon(CupertinoIcons.right_chevron, size: 14.0),
    );
  }
}
