import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '_screen.dart';

class HomeChoiceScreen extends StatefulWidget {
  const HomeChoiceScreen({
    super.key,
    required this.currentTransaction,
    required this.currentPosition,
    required this.currentRelay,
  });
  final Relay? currentRelay;
  final LatLng currentPosition;
  final Transaction currentTransaction;
  static const name = 'home-choice';
  static const path = 'choice';
  static const currentRelayKey = 'currentRelay';
  static const currentPositionKey = 'currentPosition';
  static const currentTransactionKey = 'currentTransaction';
  @override
  State<HomeChoiceScreen> createState() => _HomeChoiceScreenState();
}

class _HomeChoiceScreenState extends State<HomeChoiceScreen> {
  /// Assets
  late final Relay? _currentRelay;
  late final LatLng _currentPosition;
  late final Transaction _currentTransaction;

  late List<Account> _relayAccounts;

  VoidCallback _openAccountScreen(Account account) {
    return () async {
      account = account.copyWith(transaction: _currentTransaction);
      final data = await context.pushNamed<Account>(HomeAccountScreen.name, extra: {
        HomeAccountScreen.currentRelayKey: _currentRelay,
        HomeAccountScreen.currentAccountKey: account,
      });
      if (data != null && mounted) context.pop(data);
    };
  }

  /// AccountService
  late final AsyncController<AsyncState> _accountController;

  void _listenAccountState(BuildContext context, AsyncState state) {
    if (state is InitState) {
      _selectAccount();
    } else if (state case SuccessState<List<Account>>(:final data)) {
      _relayAccounts = data;
    } else if (state case FailureState<SelectAccountEvent>(:final code)) {
      switch (code) {}
    }
  }

  Future<void> _selectAccount() {
    return _accountController.run(
      SelectAccountEvent(position: (
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude,
      )),
    );
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _currentRelay = widget.currentRelay;
    _currentPosition = widget.currentPosition;
    _currentTransaction = widget.currentTransaction;
    _relayAccounts = List.empty(growable: true);

    /// AccountService
    _accountController = currentAccounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: CustomScrollView(
        controller: PrimaryScrollController.maybeOf(context),
        slivers: [
          HomeChoiceSliverAppBar(
            cashin: _currentTransaction == Transaction.cashin,
            relay: _currentRelay?.name,
          ),
          SliverPadding(padding: kMaterialListPadding / 3),
          ControllerConsumer(
            autoListen: true,
            listener: _listenAccountState,
            controller: _accountController,
            builder: (context, state, child) {
              return switch (state) {
                PendingState() => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeChoiceLoadingListView(),
                  ),
                SuccessState<List<Account>>() => SliverList.builder(
                    itemCount: _relayAccounts.length,
                    itemBuilder: (context, index) {
                      final item = _relayAccounts[index];
                      return HomeChoiceCard(
                        onPressed: _openAccountScreen(item),
                        image: item.image,
                        name: item.name,
                      );
                    },
                  ),
                _ => const SliverToBoxAdapter(),
              };
            },
          ),
        ],
      ),
    );
  }
}
