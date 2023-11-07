import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '_widget.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.leading,
    required this.middle,
    required this.trailing,
  });
  final Widget leading;
  final Widget middle;
  final Widget trailing;
  @override
  Size get preferredSize => const Size.fromHeight(64.0);
  @override
  Widget build(BuildContext context) {
    final style = switch (MediaQuery.platformBrightnessOf(context)) {
      Brightness.light => SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      Brightness.dark => SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    };
    return SafeArea(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: style,
        sized: false,
        child: SizedBox.fromSize(
          size: preferredSize,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leading,
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: middle,
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeBarsFilledButton extends StatelessWidget {
  const HomeBarsFilledButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      icon: const Icon(CupertinoIcons.bars),
      onPressed: onPressed,
    );
  }
}

class HomeNotifsFilledButton extends StatelessWidget {
  const HomeNotifsFilledButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      icon: const Icon(CupertinoIcons.location),
      onPressed: onPressed,
    );
  }
}

class HomePositionFilledButton extends StatelessWidget {
  const HomePositionFilledButton({
    super.key,
    required this.child,
    required this.onPressed,
  });
  final Widget child;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Point de recherche",
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10.0,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
                height: 1.5,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCashInFloatingActionButton extends StatelessWidget {
  const HomeCashInFloatingActionButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;
  // static const color = Color.fromARGB(255, 175, 214, 255);
  // static const darkColor = Color.fromARGB(255, 35, 54, 77);
  static const color = Color.fromARGB(255, 175, 255, 214);
  static const darkColor = Color.fromARGB(255, 35, 77, 54);
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      // foregroundColor: const CupertinoDynamicColor.withBrightness(
      //   color: darkColor,
      //   darkColor: color,
      // ).resolveFrom(context),
      // backgroundColor: const CupertinoDynamicColor.withBrightness(
      //   darkColor: darkColor,
      //   color: color,
      // ).resolveFrom(context),
      foregroundColor: context.theme.colorScheme.onPrimary,
      backgroundColor: context.theme.colorScheme.primary,
      onPressed: onPressed,
      label: const Text("Déposer de l'argent"),
    );
  }
}

class HomeCashOutFloatingActionButton extends StatelessWidget {
  const HomeCashOutFloatingActionButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;
  static const color = Color.fromARGB(255, 255, 175, 175);
  static const darkColor = Color.fromARGB(255, 77, 35, 35);
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      // foregroundColor: const CupertinoDynamicColor.withBrightness(
      //   color: darkColor,
      //   darkColor: color,
      // ).resolveFrom(context),
      // backgroundColor: const CupertinoDynamicColor.withBrightness(
      //   darkColor: darkColor,
      //   color: color,
      // ).resolveFrom(context),
      foregroundColor: context.theme.colorScheme.onError,
      backgroundColor: context.theme.colorScheme.error,
      onPressed: onPressed,
      label: const Text("Retirer de l'argent"),
    );
  }
}

final class CustomNavigator extends InheritedWidget {
  const CustomNavigator({
    super.key,
    required this.notifier,
    required this.persistentBottomSheetController,
    required super.child,
  });

  final ValueNotifier notifier;
  final PersistentBottomSheetController persistentBottomSheetController;

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    final CustomNavigator? inheritedTheme = context.dependOnInheritedWidgetOfExactType<CustomNavigator>();
    inheritedTheme!.notifier.value = result;
    inheritedTheme.persistentBottomSheetController.close();
  }

  @override
  bool updateShouldNotify(covariant CustomNavigator oldWidget) {
    return oldWidget.notifier != notifier;
  }
}

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Clip? clipBehavior,
  double? elevation,
  ShapeBorder? shape,
  BoxConstraints? constraints,
  bool? enableDrag,
  AnimationController? transitionAnimationController,
}) async {
  final resultController = ValueNotifier<T?>(null);
  late PersistentBottomSheetController<T> controller;
  controller = showBottomSheet<T>(
    context: context,
    builder: (context) {
      return CustomNavigator(
        persistentBottomSheetController: controller,
        notifier: resultController,
        child: Builder(builder: builder),
      );
    },
    backgroundColor: backgroundColor ?? Colors.transparent,
    clipBehavior: clipBehavior,
    elevation: elevation ?? 0.0,
    shape: shape,
    constraints: constraints,
    enableDrag: enableDrag,
    transitionAnimationController: transitionAnimationController,
  );
  await controller.closed;
  return resultController.value;
}

class HomeSelectorListTile extends StatelessWidget {
  const HomeSelectorListTile({
    super.key,
    required this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return IntrinsicWidth(
      child: ListTile(
        onTap: onTap,
        contentPadding: kTabLabelPadding,
        tileColor: theme.colorScheme.secondaryContainer,
        splashColor: theme.colorScheme.onSecondaryContainer.withOpacity(0.12),
        title: const Text("Dépôt Orange Money", style: TextStyle(fontSize: 15.0, letterSpacing: -0.2)),
        subtitle: const Text("10.000 f"),
      ),
    );
  }
}

class HomeAccountListView extends StatelessWidget {
  const HomeAccountListView({
    super.key,
    this.trailing,
    required this.itemCount,
    required this.itemBuilder,
  });
  final Widget? trailing;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: kTabLabelPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomFilledBackButton(onPressed: () => CustomNavigator.pop(context)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        Flexible(
          child: SizedBox(
            height: 220.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              separatorBuilder: (context, index) {
                return const SizedBox(width: 8.0);
              },
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          ),
        ),
      ],
    );
  }
}

class HomeAccountItemCard extends StatelessWidget {
  const HomeAccountItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final Widget title;
  final Widget subtitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ActionChip(
      onPressed: onPressed,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.all(2.0),
      backgroundColor: theme.colorScheme.secondaryContainer,
      label: AspectRatio(
        aspectRatio: 0.75,
        child: Column(
          children: [
            const Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                child: ColoredBox(
                  color: Colors.black,
                  child: SizedBox.expand(),
                ),
              ),
            ),
            ListTile(
              dense: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              title: DefaultTextStyle.merge(
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                child: title,
              ),
              subtitle: DefaultTextStyle.merge(
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: -0.2,
                ),
                child: subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeAccountItemBottomSheet extends StatelessWidget {
  const HomeAccountItemBottomSheet({
    super.key,
    this.trailing,
    required this.child,
  });
  final Widget? trailing;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: kTabLabelPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomFilledBackButton(onPressed: () => CustomNavigator.pop(context)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        Flexible(
          child: SizedBox(
            height: 220.0,
            child: Container(
              margin: const EdgeInsets.only(top: 12.0),
              padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26.0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AspectRatio(
                    aspectRatio: 1.0,
                    child: Card(color: Colors.black),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ListTile(
                          title: Text("Boba Pro", style: TextStyle(fontSize: 24.0)),
                          subtitle: Text("Angré Marché"),
                        ),
                        const Spacer(),
                        ListTile(
                          leading: FilledButton(
                            onPressed: () {},
                            child: const Text("Appeler"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
