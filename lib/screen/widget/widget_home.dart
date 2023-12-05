import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.shape = const StadiumBorder(),
  });

  final Widget? child;
  final OutlinedBorder? shape;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        shape: shape,
        elevation: 0.12,
        shadowColor: theme.colorScheme.surfaceTint,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      child: child,
    );
  }
}

class HomeMenuButton extends StatelessWidget {
  const HomeMenuButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kTabLabelPadding.copyWith(top: 6.0),
      child: HomeButton(
        onPressed: onPressed,
        child: const Icon(CupertinoIcons.bars, size: 30.0),
      ),
    );
  }
}

class HomePositionButton extends StatelessWidget {
  const HomePositionButton({
    super.key,
    this.title,
    required this.suggestionsBuilder,
  });
  final String? title;
  final SuggestionsBuilder suggestionsBuilder;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SearchAnchor(
      viewElevation: 0.0,
      suggestionsBuilder: suggestionsBuilder,
      viewBackgroundColor: theme.scaffoldBackgroundColor,
      viewHintText: MaterialLocalizations.of(context).searchFieldLabel.capitalize(),
      viewLeading: IconButton(
        onPressed: Navigator.of(context).pop,
        icon: const Icon(CupertinoIcons.arrow_left),
      ),
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.all(8.0).copyWith(top: 6.0),
          child: HomeButton(
            onPressed: controller.openView,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
            child: IntrinsicWidth(
              stepWidth: 60.0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
                titleTextStyle: theme.textTheme.headlineSmall!.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontFamily: FontFamily.avenirNext,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  wordSpacing: 1.0,
                ),
                subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                title: Text(
                  "Point de recherche".toUpperCase(),
                  textAlign: TextAlign.center,
                  softWrap: false,
                ),
                subtitle: SizedBox(
                  height: 20.0,
                  child: Visibility(
                    visible: title != null,
                    replacement: const Text('Chargement...'),
                    child: Builder(
                      builder: (context) {
                        return DefaultTextStyle.merge(
                          style: TextStyle(color: theme.colorScheme.primary),
                          child: Text(
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            title!,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeLocationButton extends StatelessWidget {
  const HomeLocationButton({
    super.key,
    this.active = false,
    required this.onChanged,
  });
  final bool active;
  final ValueChanged<bool>? onChanged;

  VoidCallback? _onPressed() {
    if (onChanged == null) return null;
    return () => onChanged!(!active);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kTabLabelPadding.copyWith(top: 6.0),
      child: HomeButton(
        onPressed: _onPressed(),
        child: Visibility(
          visible: active,
          replacement: const Icon(CupertinoIcons.location),
          child: const Icon(CupertinoIcons.location_fill),
        ),
      ),
    );
  }
}

class ProfileLocationMap extends StatefulWidget {
  const ProfileLocationMap({
    super.key,
    this.center,
    this.onMapIdle,
    this.onMapClick,
    this.onMapMoved,
    this.onCameraIdle,
    this.onMapCreated,
    this.onMapLongClick,
    this.onUserLocationUpdated,
    this.onStyleLoadedCallback,
    this.myLocationEnabled = true,
  });

  final LatLng? center;
  final bool myLocationEnabled;
  final VoidCallback? onMapIdle;
  final VoidCallback? onMapMoved;
  final VoidCallback? onCameraIdle;
  final OnMapClickCallback? onMapClick;
  final MapCreatedCallback? onMapCreated;
  final OnMapClickCallback? onMapLongClick;
  final VoidCallback? onStyleLoadedCallback;
  final OnUserLocationUpdated? onUserLocationUpdated;

  @override
  State<ProfileLocationMap> createState() => _ProfileLocationMapState();
}

class _ProfileLocationMapState extends State<ProfileLocationMap> {
  late String _mapStyle;

  ValueChanged<PointerUpEvent>? _onMapIdle() {
    if (widget.onMapIdle == null) return null;
    return (_) => widget.onMapIdle?.call();
  }

  ValueChanged<PointerDownEvent>? _onMapMoved() {
    if (widget.onMapMoved == null) return null;
    return (_) => widget.onMapMoved?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapStyle = switch (CupertinoTheme.brightnessOf(context)) {
      Brightness.light => 'https://api.maptiler.com/maps/streets-v2/style.json?key=ohdDnBihXL3Yk2cDRMfO',
      Brightness.dark => 'https://api.maptiler.com/maps/streets-v2-dark/style.json?key=ohdDnBihXL3Yk2cDRMfO',
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = switch (CupertinoTheme.brightnessOf(context)) {
      Brightness.light => SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      Brightness.dark => SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    };
    return AnnotatedRegion<SystemUiOverlayStyle>(
      sized: false,
      value: style,
      child: CustomKeepAlive(
        child: Listener(
          onPointerUp: _onMapIdle(),
          onPointerDown: _onMapMoved(),
          child: MaplibreMap(
            compassEnabled: false,
            styleString: _mapStyle,
            trackCameraPosition: true,
            onMapClick: widget.onMapClick,
            onCameraIdle: widget.onCameraIdle,
            onMapCreated: widget.onMapCreated,
            onMapLongClick: widget.onMapLongClick,
            myLocationEnabled: widget.myLocationEnabled,
            onUserLocationUpdated: widget.onUserLocationUpdated,
            onStyleLoadedCallback: widget.onStyleLoadedCallback ?? () {},
            gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
            initialCameraPosition: switch (widget.center) {
              null => const CameraPosition(target: LatLng(0.0, 0.0)),
              _ => CameraPosition(target: widget.center!, zoom: 18.0),
            },
          ),
        ),
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
      extendedTextStyle: context.theme.textTheme.titleMedium!.copyWith(letterSpacing: 0.0),
      foregroundColor: context.theme.colorScheme.onPrimary,
      backgroundColor: context.theme.colorScheme.primary,
      onPressed: onPressed,
      heroTag: "depot",
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
      extendedTextStyle: context.theme.textTheme.titleMedium!.copyWith(letterSpacing: 0.0),
      foregroundColor: context.theme.colorScheme.onTertiary,
      backgroundColor: context.theme.colorScheme.tertiary,
      onPressed: onPressed,
      heroTag: "retrait",
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
    builder: (_) {
      return CustomNavigator(
        notifier: resultController,
        persistentBottomSheetController: controller,
        child: Padding(
          padding: EdgeInsets.only(top: context.mediaQuery.padding.top),
          child: Builder(builder: builder),
        ),
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
      child: HomeButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        onPressed: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "Dépôt Orange Money",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              fontSize: 18.0,
            ),
          ),
          subtitle: Text(
            "10.000 f",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeBackButton extends StatelessWidget {
  const HomeBackButton({
    super.key,
    this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return HomeButton(
      onPressed: onPressed ?? Navigator.of(context).pop,
      child: const Icon(CupertinoIcons.arrow_left),
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
    final theme = context.theme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: kTabLabelPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              HomeBackButton(onPressed: () => CustomNavigator.pop(context)),
              const Spacer(),
              // if (trailing != null) trailing!,
            ],
          ),
        ),
        Flexible(
          child: SizedBox(
            height: 250.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Material(
                elevation: 0.12,
                color: theme.colorScheme.surface,
                shadowColor: theme.colorScheme.surfaceTint,
                surfaceTintColor: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Column(
                  children: [
                    ListTile(
                      dense: false,
                      contentPadding: kTabLabelPadding.copyWith(top: 12.0),
                      title: DefaultTextStyle.merge(
                        style: theme.textTheme.titleLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontFamily: FontFamily.avenirNext,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                        child: const Text("DEPOT ORANGE MONEY"),
                      ),
                      trailing: DefaultTextStyle.merge(
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.0,
                        ),
                        child: const Text("1.000 f"),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 26.0),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 16.0);
                          },
                          itemCount: itemCount,
                          itemBuilder: itemBuilder,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        elevation: 0.0,
        shadowColor: theme.colorScheme.surfaceTint,
        surfaceTintColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      child: AspectRatio(
        aspectRatio: 0.75,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface,
                  radius: 25.0,
                  child: Icon(
                    Icons.storefront,
                    color: theme.colorScheme.onSurface,
                    size: 30.0,
                  ),
                ),
              ),
            ),
            ListTile(
              dense: false,
              contentPadding: EdgeInsets.zero,
              title: DefaultTextStyle.merge(
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.0,
                ),
                child: title,
              ),
              subtitle: DefaultTextStyle.merge(
                style: theme.textTheme.titleSmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.0,
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
    final theme = context.theme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: kTabLabelPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              HomeBackButton(onPressed: () => CustomNavigator.pop(context)),
              const Spacer(),
              // if (trailing != null) trailing!,
            ],
          ),
        ),
        Flexible(
          child: SizedBox(
            height: 220.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Material(
                elevation: 0.12,
                color: theme.colorScheme.surface,
                shadowColor: theme.colorScheme.surfaceTint,
                surfaceTintColor: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 16.0),
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
          ),
        ),
      ],
    );
  }
}

class HomeBottomSheetBackground extends StatelessWidget {
  const HomeBottomSheetBackground({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      elevation: 0.12,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      shape: theme.bottomSheetTheme.shape,
      shadowColor: theme.colorScheme.surfaceTint,
      surfaceTintColor: theme.colorScheme.primary,
      child: child,
    );
  }
}

class HomeSliverBottomSheet extends StatelessWidget {
  const HomeSliverBottomSheet({
    super.key,
    required this.slivers,
  });
  final List<Widget> slivers;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      snap: true,
      expand: false,
      minChildSize: 0.0,
      maxChildSize: 1.0,
      initialChildSize: 0.7,
      snapSizes: const [0.0, 0.7, 1.0],
      builder: (context, scrollController) {
        return NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: kTabLabelPadding.copyWith(bottom: 6.0),
                  child: HomeBackButton(
                    onPressed: () => CustomNavigator.pop(context),
                  ),
                ),
              ),
            ];
          },
          body: HomeBottomSheetBackground(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                ...slivers,
                const SliverSafeArea(
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(height: kMinInteractiveDimension),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeAccountAppBar extends StatelessWidget {
  const HomeAccountAppBar({
    super.key,
    required this.bottom,
  });
  final Widget bottom;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      elevation: 0.12,
      toolbarHeight: 74.0,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      title: DefaultTextStyle.merge(
        style: theme.textTheme.titleLarge!.copyWith(
          color: theme.colorScheme.onSurface,
          fontFamily: FontFamily.avenirNext,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          wordSpacing: 1.0,
        ),
        child: Text("Recherche de Points Relais".toUpperCase()),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kMinInteractiveDimension),
        child: Container(
          alignment: Alignment.center,
          padding: kTabLabelPadding.copyWith(bottom: 6.0),
          height: kMinInteractiveDimension * 1.2,
          child: bottom,
        ),
      ),
    );
  }
}

class HomeAccountSelectedWidget extends StatelessWidget {
  const HomeAccountSelectedWidget({
    super.key,
    required this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      dense: true,
      onTap: onTap,
      minVerticalPadding: 0.0,
      horizontalTitleGap: 14.0,
      tileColor: theme.colorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.all(8.0).copyWith(left: 4.0),
      leading: CircleAvatar(backgroundColor: theme.colorScheme.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      title: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
        ),
        child: const Text("Depot Orange Money"),
      ),
      trailing: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.primary,
        ),
        child: const Text("1.000 f"),
      ),
    );
  }
}

class HomeAccountItemWidget extends StatelessWidget {
  const HomeAccountItemWidget({
    super.key,
    required this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CustomListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceVariant,
      ),
      title: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          fontSize: 18.0,
          height: 1.2,
        ),
        child: const Text("Ali Services"),
      ),
      subtitle: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.0,
          height: 1.5,
        ),
        child: const Text("Cocody PMI"),
      ),
      trailing: const Text("100 m"),
    );
  }
}

class HomeAccountBottomSheet extends StatelessWidget {
  const HomeAccountBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
