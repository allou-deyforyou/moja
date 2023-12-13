import 'package:flutter/material.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

import '_widget.dart';

class HomeAccountSliverAppBar extends StatelessWidget {
  const HomeAccountSliverAppBar({
    super.key,
    required this.cashin,
    required this.name,
    required this.image,
    required this.relay,
  });
  final bool cashin;
  final String name;
  final String image;
  final String? relay;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      leadingWidth: 64.0,
      toolbarHeight: 74.0,
      backgroundColor: theme.colorScheme.surface,
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontFamily: FontFamily.avenirNext,
        fontWeight: FontWeight.w600,
      ),
      leading: Center(
        child: CustomAvatarWrapper(
          content: CustomAvatarWidget(
            imageUrl: image,
          ),
        ),
      ),
      title: Column(
        children: [
          Visibility(
            visible: cashin,
            replacement: Text(localizations.withdrawal(name).toUpperCase()),
            child: Text(localizations.deposit(name).toUpperCase()),
          ),
          if (relay != null)
            DefaultTextStyle(
              style: theme.textTheme.titleLarge!.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 18.0,
                height: 1.0,
              ),
              child: Text(relay!),
            ),
        ],
      ),
      actions: const [CustomCloseButton()],
    );
  }
}

class HomeAccountAmountTextField extends StatelessWidget {
  const HomeAccountAmountTextField({
    super.key,
    this.controller,
    this.currency,
  });
  final String? currency;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Container(
      alignment: Alignment.center,
      padding: kTabLabelPadding.copyWith(
        bottom: kMinInteractiveDimension,
        top: kMinInteractiveDimension,
      ),
      child: IntrinsicWidth(
        child: TextField(
          autofocus: true,
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: theme.textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.w200,
            letterSpacing: 1.0,
          ),
          inputFormatters: [
            ThousandsFormatter(
              formatter: defaultNumberFormat,
            ),
          ],
          decoration: InputDecoration(
            filled: false,
            border: InputBorder.none,
            hintText: localizations.amount,
            focusedBorder: InputBorder.none,
            suffixIcon: Text(currency ?? "F"),
          ),
        ),
      ),
    );
  }
}

class HomeAccountSubmittedButton extends StatelessWidget {
  const HomeAccountSubmittedButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: kTabLabelPadding.copyWith(top: 26.0, bottom: 26.0),
          child: CustomSubmittedButton(
            onPressed: onPressed,
            child: Text(MaterialLocalizations.of(context).searchFieldLabel.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
