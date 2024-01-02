import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '_widget.dart';

class HomeChoiceSliverAppBar extends StatelessWidget {
  const HomeChoiceSliverAppBar({
    super.key,
    required this.cashin,
    required this.relay,
  });
  final bool cashin;
  final String? relay;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      leadingWidth: 64.0,
      toolbarHeight: 74.0,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: cashin,
            replacement: Text(localizations.moneywithdraw.toUpperCase()),
            child: Text(localizations.moneydeposit.toUpperCase()),
          ),
          if (relay != null)
            DefaultTextStyle(
              style: theme.textTheme.titleLarge!.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w400,
                fontSize: 18.0,
                height: 1.0,
              ),
              child: Text(relay!),
            ),
        ],
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
      padding: const EdgeInsets.all(16.0),
      height: kMinInteractiveDimension * 1.5,
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

class HomeChoiceError extends StatelessWidget {
  const HomeChoiceError({
    super.key,
    required this.onTry,
  });
  final VoidCallback? onTry;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            letterSpacing: -0.5,
            fontSize: 24.0,
            height: 1.2,
          ),
          child: Text(
            localizations.loadingfailed.capitalize(),
          ),
        ),
        const SizedBox(height: 6.0),
        TextButton(
          onPressed: onTry,
          style: TextButton.styleFrom(
            textStyle: theme.textTheme.titleMedium,
          ),
          child: Text(
            localizations.clicktryagain.capitalize(),
          ),
        ),
      ],
    );
  }
}

class HomeChoiceNoSupport extends StatelessWidget {
  const HomeChoiceNoSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            letterSpacing: -0.5,
            fontSize: 24.0,
            height: 1.2,
          ),
          child: Text(
            localizations.noservice.capitalize(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
            padding: const EdgeInsets.all(16.0),
            height: kMinInteractiveDimension * 1.5,
            title: textWidget,
            trailing: const SizedBox.shrink(),
            leading: CircleAvatar(backgroundColor: color),
          ),
        ),
      ),
    );
  }
}
