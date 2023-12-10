import 'dart:async';

import 'package:shimmer/shimmer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
        shadowColor: theme.colorScheme.surfaceVariant,
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
      padding: kTabLabelPadding.copyWith(top: 16.0),
      child: HomeButton(
        onPressed: onPressed,
        child: const Icon(CupertinoIcons.bars, size: 30.0),
      ),
    );
  }
}

class HomeLocationButton extends StatelessWidget {
  const HomeLocationButton({
    super.key,
    this.active = false,
    required this.onPressed,
  });
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kTabLabelPadding.copyWith(top: 16.0),
      child: HomeButton(
        onPressed: onPressed,
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

class HomeLocationWidget extends StatelessWidget {
  const HomeLocationWidget({
    super.key,
    this.title,
    required this.suggestionsBuilder,
  });
  final String? title;
  final SuggestionsBuilder suggestionsBuilder;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    final child = ListTile(
      contentPadding: kTabLabelPadding.copyWith(right: 2.0, top: 16.0, bottom: 28.0),
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      leading: const Icon(CupertinoIcons.location_solid),
      title: Text(localizations.searchpoint.toUpperCase()),
      subtitle: SizedBox(
        height: 35.0,
        child: Visibility(
          visible: title != null,
          replacement: Text('${localizations.loading.capitalize()}...'),
          child: Builder(
            builder: (context) {
              return DefaultTextStyle.merge(
                style: TextStyle(color: theme.colorScheme.primary),
                child: Text(title!, maxLines: 2),
              );
            },
          ),
        ),
      ),
      trailing: SearchAnchor(
        viewElevation: 0.0,
        suggestionsBuilder: suggestionsBuilder,
        viewBackgroundColor: theme.scaffoldBackgroundColor,
        viewHintText: MaterialLocalizations.of(context).searchFieldLabel.capitalize(),
        viewLeading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(CupertinoIcons.arrow_left),
        ),
        builder: (context, controller) {
          return IconButton(
            onPressed: controller.openView,
            icon: const Icon(CupertinoIcons.pen),
          );
        },
      ),
    );
    return Visibility(
      visible: title != null,
      replacement: Shimmer.fromColors(
        baseColor: theme.colorScheme.onSurfaceVariant,
        highlightColor: theme.colorScheme.onInverseSurface,
        child: child,
      ),
      child: child,
    );
  }
}

class HomeCashInActionButton extends StatelessWidget {
  const HomeCashInActionButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SafeArea(
      top: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 24.0, right: 8.0),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 4.0),
            foregroundColor: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.surfaceVariant,
            textStyle: theme.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              fontSize: 16.0,
              height: 1.2,
            ),
          ),
          onPressed: onPressed,
          icon: Assets.images.cashin.image(
            height: kMinInteractiveDimension,
            width: kMinInteractiveDimension,
          ),
          label: Text(
            localizations.depositmoney.capitalize(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class HomeCashOutActionButton extends StatelessWidget {
  const HomeCashOutActionButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SafeArea(
      top: false,
      left: false,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 24.0, bottom: 24.0, left: 8.0),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 4.0),
            foregroundColor: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.surfaceVariant,
            textStyle: theme.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              fontSize: 16.0,
              height: 1.2,
            ),
          ),
          onPressed: onPressed,
          icon: Transform.flip(
            flipX: true,
            child: Assets.images.cashout.image(
              height: kMinInteractiveDimension,
              width: kMinInteractiveDimension,
            ),
          ),
          label: Text(
            localizations.withdrawmoney.capitalize(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
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
      minChildSize: 0.7,
      maxChildSize: 1.0,
      initialChildSize: 0.7,
      snapSizes: const [0.7, 1.0],
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: kTabLabelPadding.copyWith(bottom: 16.0),
                  child: HomeBackButton(
                    onPressed: () => CustomNavigator.pop(context),
                  ),
                ),
              ),
            ];
          },
          body: Builder(builder: (context) {
            return HomeBottomSheetBackground(
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
            );
          }),
        );
      },
    );
  }
}

class HomeAccountAppBar extends StatelessWidget {
  const HomeAccountAppBar({
    super.key,
    required this.cashin,
    required this.bottom,
  });
  final bool cashin;
  final Widget bottom;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
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
        child: Visibility(
          visible: cashin,
          replacement: Text(localizations.searchwithdrawalpoints.toUpperCase()),
          child: Text(localizations.searchdepositpoints.toUpperCase()),
        ),
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
    required this.name,
    required this.image,
    required this.cashin,
    required this.amount,
    required this.onTap,
  });
  final bool cashin;
  final String name;
  final String image;
  final double amount;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return ListTile(
      dense: true,
      onTap: onTap,
      minVerticalPadding: 0.0,
      horizontalTitleGap: 14.0,
      tileColor: theme.colorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.all(8.0).copyWith(left: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      leading: CustomAvatarWrapper(
        content: CustomAvatarWidget(
          imageUrl: image,
        ),
      ),
      title: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
        ),
        child: Visibility(
          visible: cashin,
          replacement: Text(localizations.withdrawal(name).capitalize()),
          child: Text(localizations.deposit(name).capitalize()),
        ),
      ),
      trailing: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.primary,
        ),
        child: Text("$amount f"),
      ),
    );
  }
}

class HomeAccountItemWidget extends StatelessWidget {
  const HomeAccountItemWidget({
    super.key,
    required this.name,
    required this.image,
    required this.location,
    required this.onTap,
  });
  final String name;
  final String image;
  final String location;
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
        child: Text(name),
      ),
      subtitle: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.0,
          height: 1.5,
        ),
        child: Text(location),
      ),
      trailing: const Text("100 m"),
    );
  }
}

class HomeAccountLoadingListView extends StatelessWidget {
  const HomeAccountLoadingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = theme.colorScheme.surfaceVariant.withOpacity(0.12);
    final textWidget = Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 10.0,
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
            title: textWidget,
            subtitle: textWidget,
            trailing: const SizedBox.shrink(),
            leading: CircleAvatar(backgroundColor: color),
          ),
        ),
      ),
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
