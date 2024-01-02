import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
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

class ProfileLocationPin extends StatelessWidget {
  const ProfileLocationPin({
    super.key,
    required this.controller,
  });
  final Animation<double> controller;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 50.0,
        child: Transform.scale(
          scale: 4.0,
          child: LottieBuilder.asset(
            Assets.images.mylocation,
            controller: controller,
            fit: BoxFit.contain,
            animate: false,
          ),
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
  late SystemUiOverlayStyle _barStyle;

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
    switch (CupertinoTheme.brightnessOf(context)) {
      case Brightness.light:
        _mapStyle = 'https://api.maptiler.com/maps/streets-v2/style.json?key=ohdDnBihXL3Yk2cDRMfO';
        _barStyle = SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);
        break;
      case Brightness.dark:
        _mapStyle = 'https://api.maptiler.com/maps/streets-v2-dark/style.json?key=ohdDnBihXL3Yk2cDRMfO';
        _barStyle = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomKeepAlive(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        sized: false,
        value: _barStyle,
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
            myLocationRenderMode: switch (defaultTargetPlatform) {
              TargetPlatform.iOS => MyLocationRenderMode.COMPASS,
              _ => MyLocationRenderMode.GPS,
            },
            onUserLocationUpdated: widget.onUserLocationUpdated,
            onStyleLoadedCallback: widget.onStyleLoadedCallback ?? () {},
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
    this.error,
    required this.suggestionsBuilder,
  });
  final String? title;
  final String? error;
  final SuggestionsBuilder suggestionsBuilder;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    final child = SearchAnchor(
      viewElevation: 0.0,
      suggestionsBuilder: suggestionsBuilder,
      viewBackgroundColor: theme.scaffoldBackgroundColor,
      viewHintText: MaterialLocalizations.of(context).searchFieldLabel.capitalize(),
      viewLeading: IconButton(
        onPressed: Navigator.of(context).pop,
        icon: const Icon(CupertinoIcons.arrow_left),
      ),
      builder: (context, controller) {
        return ListTile(
          onTap: controller.openView,
          contentPadding: kTabLabelPadding,
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
              replacement: Visibility(
                visible: error != null,
                replacement: Text('${localizations.loading.capitalize()}...'),
                child: Text(
                  style: const TextStyle(color: CupertinoColors.destructiveRed),
                  localizations.loadingfailed.capitalize(),
                ),
              ),
              child: Builder(
                builder: (context) {
                  return DefaultTextStyle.merge(
                    maxLines: 2,
                    style: TextStyle(color: theme.colorScheme.primary),
                    child: Text(title!),
                  );
                },
              ),
            ),
          ),
          trailing: const Icon(CupertinoIcons.pen),
        );
      },
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

class HomeLocationItemWidget extends StatelessWidget {
  const HomeLocationItemWidget({
    super.key,
    this.onTap,
    this.subtitle,
    required this.title,
  });
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w600,
      ),
      onTap: onTap,
      leading: const Icon(CupertinoIcons.location_solid),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      title: Text(title),
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
        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
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
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              localizations.moneydeposit.capitalize(),
              textAlign: TextAlign.center,
            ),
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
        padding: const EdgeInsets.only(right: 16.0, left: 8.0),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
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
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              localizations.moneywithdraw.capitalize(),
              textAlign: TextAlign.center,
            ),
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
    return Container(
      alignment: Alignment.centerLeft,
      padding: kTabLabelPadding.copyWith(bottom: 16.0),
      child: HomeButton(
        onPressed: onPressed ?? Navigator.of(context).pop,
        child: const Icon(CupertinoIcons.arrow_left),
      ),
    );
  }
}

class HomeBottomSheetBackground extends StatelessWidget {
  const HomeBottomSheetBackground({
    super.key,
    this.padding,
    required this.child,
  });
  final EdgeInsetsGeometry? padding;
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
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 24.0),
        child: child,
      ),
    );
  }
}

class HomeSliverBottomSheet extends StatelessWidget {
  const HomeSliverBottomSheet({
    super.key,
    required this.controller,
    required this.slivers,
  });
  final DraggableScrollableController? controller;
  final List<Widget> slivers;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      snap: true,
      expand: false,
      minChildSize: 0.7,
      maxChildSize: 1.0,
      initialChildSize: 0.7,
      controller: controller,
      snapSizes: const [0.7, 1.0],
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HomeBackButton(
              onPressed: () => CustomNavigator.pop(context),
            ),
            Expanded(
              child: HomeBottomSheetBackground(
                padding: EdgeInsets.zero,
                child: CustomScrollView(
                  controller: scrollController,
                  key: const PageStorageKey('relay-page'),
                  slivers: slivers,
                ),
              ),
            ),
          ],
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
      toolbarHeight: 84.0,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      title: DefaultTextStyle.merge(
        style: theme.textTheme.headlineMedium!.copyWith(
          fontFamily: FontFamily.avenirNext,
          fontWeight: FontWeight.w600,
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
          margin: kTabLabelPadding.copyWith(bottom: 8.0),
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
    required this.currency,
    required this.onTap,
  });
  final bool cashin;
  final String name;
  final String image;
  final double amount;
  final String? currency;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return ListTile(
      onTap: onTap,
      minVerticalPadding: 16.0,
      horizontalTitleGap: 14.0,
      tileColor: theme.colorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      leading: CustomAvatarWrapper(
        content: CustomAvatarWidget(
          imageUrl: image,
        ),
      ),
      title: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        child: Text.rich(TextSpan(
          children: [
            TextSpan(text: defaultNumberFormat.format(amount)),
            TextSpan(
              text: currency ?? 'f',
              style: const TextStyle(fontSize: 10.0),
            )
          ],
        )),
      ),
    );
  }
}

class HomeRelayItemWidget extends StatelessWidget {
  const HomeRelayItemWidget({
    super.key,
    required this.name,
    required this.image,
    required this.location,
    this.onTap,
    this.onCallPressed,
  });
  final String name;
  final String? image;
  final String location;
  final VoidCallback? onTap;
  final VoidCallback? onCallPressed;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      height: kMinInteractiveDimension * 1.8,
      leading: CustomAvatarWrapper(
        radius: 25.0,
        content: switch (image) {
          String() => CustomAvatarWidget(
              cached: false,
              imageUrl: image,
            ),
          _ => Icon(
              color: theme.colorScheme.onSurfaceVariant,
              Icons.storefront,
            ),
        },
      ),
      title: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          fontSize: 18.0,
          height: 1.5,
        ),
        child: Text(name),
      ),
      subtitle: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.0,
          height: 1.2,
        ),
        child: Text(location),
      ),
      trailing: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: kTabLabelPadding,
          textStyle: theme.textTheme.titleMedium,
          side: BorderSide(color: theme.colorScheme.primary),
        ),
        onPressed: onCallPressed,
        child: Text(localizations.call.capitalize()),
      ),
    );
  }
}

class HomeRelayNoFound extends StatelessWidget {
  const HomeRelayNoFound({
    super.key,
    required this.cashin,
    required this.account,
    required this.onTry,
  });
  final bool cashin;
  final String account;
  final VoidCallback? onTry;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(26.0),
      child: DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
          letterSpacing: -0.5,
          fontSize: 24.0,
          height: 1.2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: cashin,
              replacement: Text(
                localizations.nowithdrawpoint(account).capitalize(),
              ),
              child: Text(
                localizations.nodepositpoint(account).capitalize(),
              ),
            ),
            TextButton(
              onPressed: onTry,
              style: TextButton.styleFrom(textStyle: theme.textTheme.titleMedium),
              child: Text(localizations.clicktryagain.capitalize()),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeRelayError extends StatelessWidget {
  const HomeRelayError({
    super.key,
    required this.onTry,
  });
  final VoidCallback? onTry;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(26.0),
      child: DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
          letterSpacing: -0.5,
          fontSize: 24.0,
          height: 1.2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.loadingfailed.capitalize()),
            TextButton(
              onPressed: onTry,
              style: TextButton.styleFrom(textStyle: theme.textTheme.titleMedium),
              child: Text(localizations.clicktryagain.capitalize()),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeRelayLoadingListView extends StatelessWidget {
  const HomeRelayLoadingListView({super.key});

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
            height: kMinInteractiveDimension * 1.8,
            title: textWidget,
            subtitle: textWidget,
            trailing: const SizedBox.shrink(),
            leading: CircleAvatar(
              backgroundColor: color,
              radius: 25.0,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeAccountBottomSheet extends StatelessWidget {
  const HomeAccountBottomSheet({
    super.key,
    required this.content,
  });
  final Widget content;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeBackButton(
          onPressed: () => CustomNavigator.pop(context),
        ),
        HomeBottomSheetBackground(
          child: content,
        ),
      ],
    );
  }
}

class HomeRelayCallModal extends StatelessWidget {
  const HomeRelayCallModal({
    super.key,
    required this.relay,
    required this.onCall,
  });
  final String relay;
  final VoidCallback onCall;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return CupertinoActionSheet(
      // title: DefaultTextStyle.merge(
      //   style: theme.textTheme.titleSmall!.copyWith(
      //     fontWeight: FontWeight.w600,
      //     height: 1.2,
      //   ),
      //   child: Text(relay),
      // ),
      message: DefaultTextStyle.merge(
        style: theme.textTheme.titleMedium!.copyWith(height: 1.2),
        child: Text.rich(TextSpan(children: [
          const TextSpan(text: "Vous êtes sur le point d'appeler chez\n"),
          TextSpan(
            style: const TextStyle(fontWeight: FontWeight.bold),
            text: relay,
          ),
        ])),
      ),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: onCall,
          child: DefaultTextStyle.merge(
            style: theme.textTheme.titleLarge!.copyWith(
              color: theme.colorScheme.primary,
              height: 1.2,
            ),
            child: Text(localizations.call.capitalize()),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: Navigator.of(context).pop,
        child: DefaultTextStyle.merge(
          style: theme.textTheme.titleLarge!.copyWith(
            color: CupertinoColors.destructiveRed,
            height: 1.2,
          ),
          child: Text(localizations.cancel.capitalize()),
        ),
      ),
    );
  }
}
