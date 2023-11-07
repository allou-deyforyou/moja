import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '_widget.dart';

class HomeMenuAppBar extends StatelessWidget {
  const HomeMenuAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Text("Menu"),
      actions: [CustomCloseButton()],
    );
  }
}

class HomeMenuListTile extends StatelessWidget {
  const HomeMenuListTile({
    super.key,
    this.onTap,
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.contentPadding,
  });
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      contentPadding: contentPadding,
      tileColor: theme.colorScheme.secondaryContainer,
      textColor: theme.colorScheme.onSecondaryContainer,
      splashColor: theme.colorScheme.onSecondaryContainer.withOpacity(0.12),
      onTap: onTap,
      title: title,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing ?? const Icon(CupertinoIcons.right_chevron, size: 14.0),
    );
  }
}

class HomeMenuProfileListTile extends StatelessWidget {
  const HomeMenuProfileListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return HomeMenuListTile(
      onTap: onTap,
      title: const Text("Profil"),
    );
  }
}

class HomeMenuCallListTile extends StatelessWidget {
  const HomeMenuCallListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return HomeMenuListTile(
      onTap: onTap,
      title: const Text("Appels"),
    );
  }
}

class HomeMenuNotifsListTile extends StatelessWidget {
  const HomeMenuNotifsListTile({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return HomeMenuListTile(
      onTap: () => onChanged(!value),
      title: const Text("Notifications"),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class HomeMenuThemeListTile extends StatelessWidget {
  const HomeMenuThemeListTile({
    super.key,
    this.onTap,
    required this.trailing,
  });
  final Widget trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return HomeMenuListTile(
      onTap: onTap,
      title: const Text("Theme"),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: trailing,
      ),
    );
  }
}

class HomeMenuSupportListTile extends StatelessWidget {
  const HomeMenuSupportListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return HomeMenuListTile(
      onTap: onTap,
      title: const Text("Aide ou Suggestion"),
    );
  }
}

class HomeMenuShareListTile extends StatelessWidget {
  const HomeMenuShareListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return HomeMenuListTile(
      onTap: onTap,
      title: const Text("Inviter un contact"),
    );
  }
}

class HomeMenuLogoutListTile extends StatelessWidget {
  const HomeMenuLogoutListTile({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(2.0),
      textColor: CupertinoColors.destructiveRed,
      splashColor: CupertinoColors.destructiveRed.withOpacity(0.12),
      shape: const StadiumBorder(side: BorderSide(color: CupertinoColors.destructiveRed)),
      title: const Center(child: Text("Déconnexion")),
    );
  }
}
