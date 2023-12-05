import 'package:flutter/material.dart';

import '_widget.dart';

class HomeMenuAppBar extends StatelessWidget {
  const HomeMenuAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64.0,
      automaticallyImplyLeading: false,
      titleTextStyle: theme.textTheme.headlineLarge!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      title: const Text("MENU"),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeMenuNotifs extends StatelessWidget {
  const HomeMenuNotifs({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return CustomListTile(
      onTap: () => onChanged(!value),
      title: Text(localizations.notifications.capitalize()),
      trailing: Switch(
        activeTrackColor: theme.colorScheme.onSurface,
        activeColor: theme.colorScheme.surface,
        onChanged: onChanged,
        value: value,
      ),
    );
  }
}

class HomeMenuTheme extends StatelessWidget {
  const HomeMenuTheme({
    super.key,
    this.onTap,
    required this.value,
  });
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.theme.capitalize()),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(value),
      ),
    );
  }
}

class HomeLanguageTheme extends StatelessWidget {
  const HomeLanguageTheme({
    super.key,
    this.onTap,
    required this.value,
  });
  final String? value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.language.capitalize()),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(value ?? 'system'),
      ),
    );
  }
}

class HomeMenuSupport extends StatelessWidget {
  const HomeMenuSupport({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.helporsuggestions.capitalize()),
    );
  }
}

class HomeMenuShare extends StatelessWidget {
  const HomeMenuShare({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return CustomListTile(
      onTap: onTap,
      title: Text(localizations.shareapp.capitalize()),
    );
  }
}
