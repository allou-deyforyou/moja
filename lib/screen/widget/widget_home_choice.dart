import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

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
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      title: Visibility(
        visible: cashin,
        replacement: Text(localizations.withdrawmoney.toUpperCase()),
        child: Text(localizations.depositmoney.toUpperCase()),
      ),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeChoiceCard extends StatelessWidget {
  const HomeChoiceCard({
    super.key,
    this.onPressed,
    required this.name,
    required this.image,
  });
  final String name;
  final String image;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onPressed,
      contentPadding: const EdgeInsets.all(16.0),
      leading: CustomAvatarWrapper(
        content: CustomAvatarWidget(
          imageUrl: image,
        ),
      ),
      title: Text(name),
      trailing: const Icon(CupertinoIcons.right_chevron, size: 14.0),
    );
  }
}

class HomeChoiceLoadingListView extends StatelessWidget {
  const HomeChoiceLoadingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = theme.colorScheme.surfaceVariant.withOpacity(0.12);
    final textWidget = Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 12.0,
        width: 100.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.onSurfaceVariant,
      highlightColor: theme.colorScheme.onInverseSurface,
      child: Column(
        children: List.filled(
          4,
          CustomListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: textWidget,
            trailing: const SizedBox.shrink(),
            leading: CircleAvatar(backgroundColor: color),
          ),
        ),
      ),
    );
  }
}
