import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeAccountScreen extends StatefulWidget {
  const HomeAccountScreen({
    super.key,
    required this.currentRelay,
    required this.currentAccount,
  });
  final Relay? currentRelay;
  final Account currentAccount;
  static const name = 'home-account';
  static const path = 'account';
  static const currentRelayKey = 'currentRelay';
  static const currentAccountKey = 'currentAccount';
  @override
  State<HomeAccountScreen> createState() => _HomeAccountScreenState();
}

class _HomeAccountScreenState extends State<HomeAccountScreen> {
  /// Assets
  late final Relay? _currentRelay;
  late final Account _currentAccount;

  late TextEditingController _amountTextController;

  double get _amount {
    return double.tryParse(_amountTextController.text.replaceAll('.', '').trimSpace()) ?? 0;
  }

  void _onSubmitted() {
    final account = _currentAccount.copyWith(amount: _amount);
    if (_currentRelay != null) {
      _getRelay(account);
    } else {
      context.pop(account);
    }
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) async {
    final localizations = context.localizations;
    if (state case SuccessState<List<Relay>>()) {
      showSnackBar(
        context: context,
        backgroundColor: CupertinoColors.activeGreen,
        text: localizations.youcancarryout.capitalize(),
      );
    } else if (state case FailureState<String>(:final data)) {
      switch (data) {
        case 'no-record':
          showSnackBar(
            context: context,
            backgroundColor: CupertinoColors.destructiveRed,
            text: localizations.youcannotcarryout.capitalize(),
          );
          break;
        case 'no-internet':
          showSnackBar(
            context: context,
            text: localizations.connectionproblem.capitalize(),
          );
          break;
        default:
          showSnackBar(
            context: context,
            text: localizations.erroroccured.capitalize(),
          );
      }
    }
  }

  Future<void> _getRelay(Account account) {
    return _relayController.run(SelectRelayEvent(
      relay: _currentRelay,
      account: account,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentRelay = widget.currentRelay;
    _currentAccount = widget.currentAccount;
    final amount = _currentAccount.amount?.formatted;
    _amountTextController = TextEditingController(text: amount);
    _amountTextController.selection = TextSelection(
      extentOffset: amount?.length ?? 0,
      baseOffset: 0,
    );

    /// RelayService
    _relayController = AsyncController<AsyncState>(const InitState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeAccountSliverAppBar(
            cashin: _currentAccount.transaction == Transaction.cashin,
            image: _currentAccount.image,
            name: _currentAccount.name,
            relay: _currentRelay?.name,
          ),
          SliverToBoxAdapter(
            child: HomeAccountAmountTextField(
              currency: _currentAccount.country?.currency,
              controller: _amountTextController,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: ControllerBuilder(
              listener: _listenRelayState,
              controller: _relayController,
              builder: (context, state, child) {
                VoidCallback? onPressed = _onSubmitted;
                if (state is PendingState) onPressed = null;
                return Visibility(
                  visible: _currentRelay != null,
                  replacement: HomeAccountSubmittedButton(
                    onPressed: onPressed,
                  ),
                  child: HomeAccountCheckButton(
                    onPressed: onPressed,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
