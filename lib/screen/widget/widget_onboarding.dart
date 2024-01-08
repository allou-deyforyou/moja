import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class OnBoardingBackground extends StatelessWidget {
  const OnBoardingBackground({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      sized: false,
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.onboarding.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}

class OnBoardingSubmittedButton extends StatelessWidget {
  const OnBoardingSubmittedButton({
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
      child: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    titleTextStyle: theme.textTheme.displaySmall!.copyWith(
                      fontFamily: FontFamily.avenirNext,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      wordSpacing: 1.0,
                    ),
                    subtitleTextStyle: theme.textTheme.titleMedium!.copyWith(
                      color: CupertinoColors.systemGrey4,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    title: const Text("GAGNEZ PLUS AVEC VOS POINTS RELAIS"),
                    subtitle: const Text("Rendez plus visibles vos points relais au près de vos client(e)s et gagnez plus."),
                  ),
                  const SizedBox(height: kToolbarHeight),
                  CustomSubmittedButton(
                    onPressed: onPressed,
                    child: Text(localizations.getstarted.toUpperCase()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnBoardingPermissionModal extends StatelessWidget {
  const OnBoardingPermissionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomModal();
  }
}
