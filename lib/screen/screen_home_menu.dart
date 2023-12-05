import 'package:flutter/material.dart';

import '_screen.dart';

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});
  static const name = 'home-menu';
  static const path = 'menu';
  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
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
            child: HomeMenuNotifs(
              onChanged: (value) {},
              value: true,
            ),
          ),
          SliverToBoxAdapter(
            child: HomeMenuTheme(
              value: "Systeme",
              onTap: () {},
            ),
          ),
          divider,
          SliverToBoxAdapter(
            child: HomeMenuSupport(
              onTap: () {},
            ),
          ),
          SliverToBoxAdapter(
            child: HomeMenuShare(
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
