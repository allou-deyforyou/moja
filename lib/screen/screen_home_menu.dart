import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '_screen.dart';

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});
  static const name = 'home-menu';
  static const path = 'menu';
  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  /// Assets
  Stream<bool?>? _notificationsStream;
  bool? _currentNotifications;

  Stream<ThemeMode>? _themeModeStream;
  ThemeMode? _currentThemeMode;

  Stream<Locale?>? _localeStream;
  Locale? _currentLocale;

  void _onNotifsTaped(bool active) async {
    if (active) {
      final enabled = await NotificationConfig.enableNotifications();
      if (!enabled) _openNotifsModal();
    } else {
      NotificationConfig.disableNotifications();
    }
  }

  void _openNotifsModal() async {
    final data = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return const HomeMenuNotifisModal();
      },
    );
    if (data != null) {
      openAppSettings();
    }
  }

  VoidCallback _openThemeModal(ThemeMode themeMode) {
    return () async {
      final data = await showCupertinoModalPopup<ThemeMode>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          return HomeMenuThemeModal<ThemeMode>(
            onSelected: (value) => HiveLocalDB.themeMode = value,
            selected: themeMode,
          );
        },
      );
      if (data == null) {
        HiveLocalDB.themeMode = themeMode;
      }
    };
  }

  VoidCallback _openLanguageModal(Locale? locale) {
    return () async {
      final data = await showCupertinoModalPopup<Locale>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          return HomeMenuLanguageModal<Locale>(
            onSelected: (value) => HiveLocalDB.locale = value,
            selected: locale,
          );
        },
      );
      if (data == null) {
        HiveLocalDB.locale = locale;
      }
    };
  }

  VoidCallback _launnchApp(Uri url) {
    return () async {
      if (await canLaunchUrl(url)) {
        launchUrl(url);
      } else {}
    };
  }

  void _openSupportScreen() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return HomeMenuSupportModal(
          children: [
            Builder(
              builder: (context) {
                final url = RemoteConfig.emailSupport;
                final value = Uri.decodeFull(url.path);
                return HomeMenuSupportEmailWidget(
                  onTap: _launnchApp(url),
                  email: value,
                );
              },
            ),
            Builder(
              builder: (context) {
                final url = RemoteConfig.whatsappSupport;
                final value = Uri.decodeFull(url.path);
                return HomeMenuSupportWhatsappWidget(
                  onTap: _launnchApp(url),
                  phone: value,
                );
              },
            ),
            Builder(
              builder: (context) {
                final url = RemoteConfig.policeSupport;
                final value = Uri.decodeFull(url.path);
                return HomeMenuSupportPoliceWidget(
                  onTap: _launnchApp(url),
                  phone: value,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _openShareScreen() {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      RemoteConfig.appLink,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _openRateScreen() {
    HiveLocalDB.showInAppReview();
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentLocale = HiveLocalDB.locale;
    _localeStream = HiveLocalDB.localeStream;

    _currentThemeMode = HiveLocalDB.themeMode;
    _themeModeStream = HiveLocalDB.themeModeStream;

    _currentNotifications = HiveLocalDB.notifications;
    _notificationsStream = HiveLocalDB.notificationsStream;
  }

  @override
  Widget build(BuildContext context) {
    const divider = SliverToBoxAdapter(
      child: Divider(thickness: 4.0, height: 4.0),
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const HomeMenuAppBar(),
          SliverPadding(padding: kMaterialListPadding / 2),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: _notificationsStream,
              initialData: _currentNotifications,
              builder: (context, snapshot) {
                return HomeMenuNotifs(
                  value: snapshot.data ?? false,
                  onChanged: _onNotifsTaped,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: _themeModeStream,
              initialData: _currentThemeMode,
              builder: (context, snapshot) {
                return HomeMenuTheme(
                  onTap: _openThemeModal(snapshot.data!),
                  value: snapshot.data!.format(context).capitalize(),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: _localeStream,
              initialData: _currentLocale,
              builder: (context, snapshot) {
                return HomeLanguageTheme(
                  onTap: _openLanguageModal(snapshot.data),
                  value: snapshot.data?.format(context).capitalize(),
                );
              },
            ),
          ),
          divider,
          SliverToBoxAdapter(
            child: HomeMenuSupport(
              onTap: _openSupportScreen,
            ),
          ),
          SliverToBoxAdapter(
            child: HomeMenuShare(
              onTap: _openShareScreen,
            ),
          ),
          SliverToBoxAdapter(
            child: HomeMenuRate(
              onTap: _openRateScreen,
            ),
          ),
        ],
      ),
    );
  }
}
