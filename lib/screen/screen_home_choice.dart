import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '_screen.dart';

class HomeChoiceScreen extends StatefulWidget {
  const HomeChoiceScreen({
    super.key,
    required this.currentTransaction,
    required this.currentPosition,
    required this.currentRelay,
  });
  final Relay? currentRelay;
  final Transaction currentTransaction;
  final ({double longitude, double latitude}) currentPosition;

  static const currentRelayKey = 'currentRelay';
  static const currentPositionKey = 'currentPosition';
  static const currentTransactionKey = 'currentTransaction';

  static const name = 'home-choice';
  static const path = 'choice';
  @override
  State<HomeChoiceScreen> createState() => _HomeChoiceScreenState();
}

class _HomeChoiceScreenState extends State<HomeChoiceScreen> {
  /// Assets
  late final Relay? _currentRelay;
  late List<Account> _relayAccounts;
  late final Transaction _currentTransaction;
  late final ({double longitude, double latitude}) _currentPosition;

  late ValueNotifier<bool> _bannerAdLoaded;
  late int _bannerAdIndex;
  late AdSize _bannerSize;
  BannerAd? _bannerAd;

  void _loadAd() {
    _bannerAd = BannerAd(
      size: _bannerSize,
      request: const AdRequest(),
      adUnitId: AdMobConfig.choiceAdBanner,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, err) => ad.dispose(),
        onAdLoaded: (ad) => _bannerAdLoaded.value = true,
      ),
    )..load();
  }

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
    if (state case SuccessState<List<Account>>(:final data)) {
      _relayAccounts = List.from(data);
      _bannerAdIndex = Random().nextInt(_relayAccounts.length);
      _relayAccounts.insert(_bannerAdIndex, _relayAccounts[_bannerAdIndex]);
    }
  }

  Future<void> _selectAccount() {
    return _accountController.run(
      SelectAccountEvent(
        relay: _currentRelay,
        position: (
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude,
        ),
      ),
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

    _bannerSize = const AdSize(width: 640, height: 60);
    _bannerAdLoaded = ValueNotifier(false);
    _loadAd();

    /// AccountService
    if (_currentRelay != null) {
      _accountController = AsyncController<AsyncState>(const InitState());
    } else {
      _accountController = currentAccounts;
    }

    if (_accountController.value is! SuccessState<List<Account>>) {
      _selectAccount();
    }
  }

  @override
  void dispose() {
    /// Assets
    _bannerAd?.dispose();

    super.dispose();
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
          ControllerBuilder(
            autoListen: true,
            listener: _listenAccountState,
            controller: _accountController,
            builder: (context, state, child) {
              return switch (state) {
                PendingState() => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeChoiceLoadingListView(),
                  ),
                SuccessState<List<Account>>() => SliverMainAxisGroup(
                    slivers: [
                      SliverList.builder(
                        itemCount: _relayAccounts.length,
                        itemBuilder: (context, index) {
                          final item = _relayAccounts[index];
                          return Visibility(
                            visible: index != _bannerAdIndex,
                            replacement: ValueListenableBuilder(
                              valueListenable: _bannerAdLoaded,
                              builder: (context, loaded, child) {
                                return CustomBannerAdWidget(
                                  loaded: loaded,
                                  ad: _bannerAd!,
                                );
                              },
                            ),
                            child: HomeChoiceCard(
                              onPressed: _openAccountScreen(item),
                              image: item.image,
                              name: item.name,
                            ),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 60.0),
                      ),
                    ],
                  ),
                FailureState<String>(:final data) => switch (data) {
                    'no-record' => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: HomeChoiceNoSupport(),
                      ),
                    _ => SliverFillRemaining(
                        hasScrollBody: false,
                        child: HomeChoiceError(
                          onTry: _selectAccount,
                        ),
                      ),
                  },
                _ => const SliverToBoxAdapter(),
              };
            },
          ),
        ],
      ),
    );
  }
}
