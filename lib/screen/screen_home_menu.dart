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
    const space = SliverToBoxAdapter(child: SizedBox(height: 4.0));
    const largeSpace = SliverToBoxAdapter(child: SizedBox(height: 26.0));

    return Scaffold(
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          const HomeMenuAppBar(),
          SliverPadding(
            padding: kTabLabelPadding,
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: HomeMenuNotifsListTile(
                    onChanged: (value) {},
                    value: true,
                  ),
                ),
                space,
                SliverToBoxAdapter(
                  child: HomeMenuThemeListTile(
                    onTap: () {},
                    trailing: const Text("Systeme"),
                  ),
                ),
                largeSpace,
                SliverToBoxAdapter(
                  child: HomeMenuSupportListTile(
                    onTap: () {},
                  ),
                ),
                space,
                SliverToBoxAdapter(
                  child: HomeMenuShareListTile(
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
