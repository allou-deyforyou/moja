import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '_widget.dart';

class HomeSearchAppBar extends StatelessWidget {
  const HomeSearchAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: const Text("Point de recherche"),
      actions: const [CustomCloseButton()],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(54.0),
        child: HomeSearchTextField(),
      ),
      shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.8)),
    );
  }
}

class HomeSearchTextField extends StatelessWidget {
  const HomeSearchTextField({
    super.key,
    this.searchController,
  });
  final TextEditingController? searchController;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kTabLabelPadding.copyWith(bottom: 6.0),
      child: TextField(
        autofocus: true,
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Quartier, commune ou ville...",
          prefixIcon: const Icon(CupertinoIcons.search, size: 20.0),
          suffixIcon: IconButton(
            constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
            onPressed: searchController?.clear,
            icon: const Icon(CupertinoIcons.xmark_circle),
          ),
        ),
      ),
    );
  }
}
