import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

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
    this.textColor,
    this.splashColor,
    this.onTap,
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
  });
  final Color? textColor;
  final Color? splashColor;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      textColor: textColor,
      splashColor: splashColor,
      contentPadding: kTabLabelPadding.copyWith(top: 6.0, bottom: 6.0),
      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
        letterSpacing: 0.0,
        fontSize: 18.0,
      ),
      onTap: onTap,
      title: title,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing ?? const Icon(CupertinoIcons.right_chevron, size: 14.0),
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
