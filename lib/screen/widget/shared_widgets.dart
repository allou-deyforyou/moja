import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:widget_tools/widget_tools.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '_widget.dart';

void showSnackBar({
  required BuildContext context,
  required String text,
  Color? backgroundColor,
  VoidCallback? onTry,
}) {
  final localizations = context.localizations;

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    action: onTry != null ? SnackBarAction(label: localizations.tryagain.capitalize(), onPressed: onTry) : null,
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor,
    showCloseIcon: true,
    content: Text(text),
  ));
}

class DialogPage<T> extends Page<T> {
  const DialogPage({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return child;
      },
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      onPressed: onPressed ?? Navigator.of(context).maybePop,
      icon: const Icon(CupertinoIcons.arrow_left),
    );
  }
}

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({
    super.key,
    this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).closeButtonLabel,
      constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
      onPressed: onPressed ?? Navigator.of(context).maybePop,
      icon: const Icon(CupertinoIcons.xmark),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    this.onTap,
    this.height,
    this.shape,
    this.horizontalTitleGap,
    this.padding,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });
  final double? height;
  final ShapeBorder? shape;
  final double? horizontalTitleGap;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: shape,
      child: Container(
        padding: padding ?? kTabLabelPadding,
        height: height ?? kMinInteractiveDimension * 1.1,
        decoration: ShapeDecoration(shape: shape ?? InputBorder.none),
        child: SafeArea(
          top: false,
          bottom: false,
          child: NavigationToolbar(
            centerMiddle: false,
            middleSpacing: horizontalTitleGap ?? (leading != null ? 14.0 : 0.0),
            leading: leading,
            middle: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 18.0),
                    child: title!,
                  ),
                if (subtitle != null) subtitle!,
              ],
            ),
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}

class CustomModal extends StatelessWidget {
  const CustomModal({
    super.key,
    this.title,
    this.content,
    this.actions,
  });
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return AlertDialog(
      elevation: 1.0,
      insetPadding: kTabLabelPadding,
      backgroundColor: theme.colorScheme.surface,
      titleTextStyle: theme.textTheme.titleLarge!,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      titlePadding: const EdgeInsets.all(24).copyWith(bottom: 16.0),
      title: SizedBox(width: 700.0, child: title),
      content: content,
      actions: actions,
    );
  }
}

class CustomSubmittedButton extends StatelessWidget {
  const CustomSubmittedButton({
    super.key,
    this.timeout,
    this.elevation,
    required this.onPressed,
    required this.child,
  });
  final double? elevation;
  final Duration? timeout;
  final VoidCallback? onPressed;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CounterBuilder(
      reverse: true,
      timeout: timeout ?? Duration.zero,
      child: child,
      builder: (context, duration, child) {
        final done = duration == Duration.zero;
        return FilledButton(
          onPressed: done ? onPressed : null,
          style: FilledButton.styleFrom(
            elevation: elevation,
            textStyle: theme.textTheme.titleSmall!.copyWith(
              fontFamily: FontFamily.avenir,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              height: 1.0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
          ),
          child: Container(
            height: 24.0,
            alignment: Alignment.center,
            child: Visibility(
              visible: onPressed != null,
              replacement: const CustomProgressIndicator(),
              child: Visibility(
                visible: done,
                replacement: Text('$duration'.substring(0, 7)),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({
    super.key,
    this.color,
    this.radius = 8.0,
    this.strokeWidth = 2.0,
  });
  final Color? color;
  final double radius;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox.fromSize(
      size: Size.fromRadius(radius),
      child: CircularProgressIndicator(
        backgroundColor: theme.colorScheme.onInverseSurface,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

class CustomAvatarWrapper extends StatelessWidget {
  const CustomAvatarWrapper({
    super.key,
    this.radius = 20.0,
    required this.content,
  });
  final double radius;
  final Widget content;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox.square(
      dimension: radius * 2,
      child: Material(
        shape: CircleBorder(
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surfaceVariant,
        child: content,
      ),
    );
  }
}

class CustomAvatarProgressIndicator extends StatelessWidget {
  const CustomAvatarProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CustomProgressIndicator(
        strokeWidth: 2.0,
        radius: 12.0,
      ),
    );
  }
}

class CustomAvatarWidget extends StatelessWidget {
  const CustomAvatarWidget({
    super.key,
    required this.imageUrl,
    this.cached = true,
    this.onTap,
  });
  final bool cached;
  final String? imageUrl;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: Visibility(
          visible: cached,
          replacement: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, result) {
              return Visibility(
                visible: result?.cumulativeBytesLoaded == result?.expectedTotalBytes,
                replacement: const CustomAvatarProgressIndicator(),
                child: child,
              );
            },
          ),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: imageUrl!,
            placeholder: (context, url) {
              return const CustomAvatarProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

const customBannerAd = AdSize(width: 640, height: 60);

class CustomBannerAdWidget extends StatelessWidget {
  const CustomBannerAdWidget({
    super.key,
    this.width,
    this.height,
    this.loaded = false,
    required this.ad,
  });
  final double? width;
  final double? height;
  final bool loaded;
  final AdWithView ad;
  @override
  Widget build(BuildContext context) {
    return CustomKeepAlive(
      child: ClipPath(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: Visibility(
            key: ValueKey(loaded),
            visible: loaded,
            child: SizedBox(
              width: width ?? double.maxFinite,
              height: height ?? customBannerAd.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ),
        ),
      ),
    );
  }
}
