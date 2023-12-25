import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_tools/widget_tools.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const name = 'home';
  static const path = '/';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  /// Assets
  late final BuildContext _scaffoldContext;
  late final PageStorageBucket _pageStorageBucket;

  late ValueNotifier<bool> _myLocationController;
  late AnimationController _pinAnimationController;
  late ValueNotifier<double?> _pinVisibilityController;

  Account? _currentAccount;

  Timer? _interstitialAdTimer;
  late Duration _interstitialAdTimeout;
  InterstitialAd? _interstitialAd;

  late ValueNotifier<bool> _bannerAdLoaded;
  late int _bannerAdIndex;
  BannerAd? _bannerAd;

  void _afterLayout(BuildContext context) {
    _scaffoldContext = context;
    _showLocationWidget();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      request: const AdRequest(),
      adUnitId: AdMobConfig.homeInterstitialAd,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdFailedToLoad: (err) {},
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
      ),
    );
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.fullBanner,
      request: const AdRequest(),
      adUnitId: AdMobConfig.choiceAdBanner,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, err) => ad.dispose(),
        onAdLoaded: (ad) => _bannerAdLoaded.value = true,
      ),
    )..load();
  }

  Future<void> _loadPin() async {
    _pinAnimationController.value = 0.6;
    _pinAnimationController.repeat(min: 0.7, max: 0.8);
  }

  Future<void> _startPin() async {
    _pinAnimationController.value = 0.1;
    await _pinAnimationController.animateTo(0.4);
  }

  Future<void> _stopPin() async {
    await _pinAnimationController.animateTo(0.0);
  }

  void _resetPin() {
    _pinAnimationController.reset();
  }

  LatLng? _placeToLatLng(Place? place) {
    if (place == null) return null;
    return LatLng(
      place.position!.coordinates![1],
      place.position!.coordinates![0],
    );
  }

  void _openMenuScreen() {
    context.pushNamed(HomeMenuScreen.name);
  }

  VoidCallback _openChoiceScreen(Transaction transaction, {Relay? relay}) {
    return () async {
      final data = await context.pushNamed<Account>(
        extra: {
          HomeChoiceScreen.currentRelayKey: relay,
          HomeChoiceScreen.currentTransactionKey: transaction,
          HomeChoiceScreen.currentPositionKey: (
            longitude: _centerPosition!.longitude,
            latitude: _centerPosition!.latitude,
          ),
        },
        HomeChoiceScreen.name,
      );
      if (data != null) {
        _currentAccount = data;
        _selectRelay();
        _openAccountListView();
      }
    };
  }

  void _openAccountScreen() async {
    final data = await context.pushNamed<Account>(
      extra: {HomeAccountScreen.currentAccountKey: _currentAccount},
      HomeAccountScreen.name,
    );
    if (data != null) {
      _currentAccount = data;
      _selectRelay();
      _openAccountListView();
    }
  }

  /// MapLibre
  MaplibreMapController? _mapController;
  UserLocation? _userLocation;
  LatLng? _centerPosition;

  late double _mapPadding;
  late double _zoom;
  late double _tilt;

  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;

    _goToMyPosition();
  }

  Future<void> _onStyleLoadedCallback() async {
    await Future.wait([
      _updateContentInsets(),
      _loadImages(),
    ]);
    if (_relays != null) {
      _addRelayMaplibre(_relays!);
    } else if (_currentRelay != null && _routes != null) {
      _addRelayMaplibre([_currentRelay!]);
      _drawLines(_routes!);
    }

    _goToMyPosition();
  }

  Future<void> _updateContentInsets() {
    return _mapController!.updateContentInsets(EdgeInsets.only(
      bottom: _mapPadding,
      right: 16.0,
      left: 16.0,
    ));
  }

  Future<void> _clearMap() {
    return Future.wait([
      _mapController!.clearLines(),
      _mapController!.clearSymbols(),
    ]);
  }

  Future<void> _loadImages() async {
    final pintData = await rootBundle.load(Assets.images.pin2.path);
    await _mapController!.addImage(
      Assets.images.pin2.keyName,
      pintData.buffer.asUint8List(),
    );
  }

  Future<void> _onMapMoved() async {
    if (_pinVisibilityController.value != null) {
      _startPin();
    }

    _myLocationController.value = false;
  }

  Future<void> _onMapIdle() async {
    if (_pinVisibilityController.value != null) {
      await _stopPin();
      _centerPosition = _mapController!.cameraPosition!.target;

      _searchPlace(_centerPosition!);
    }
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (_myLocationController.value) {
      _goToPosition(
        location.position,
        bearing: switch (_currentRelay) {
          Relay() => _userLocation?.bearing ?? 0.0,
          _ => 0.0,
        },
      );
    }
    _userLocation = location;
  }

  Future<void> _setZoom(double zoom) async {
    if (_mapController == null) return;
    _zoom = zoom;
    await _mapController!.animateCamera(
      CameraUpdate.zoomTo(zoom),
    );
  }

  Future<void> _setTitl(double tilt) async {
    if (_mapController == null) return;
    _tilt = tilt;
    await _mapController!.animateCamera(
      CameraUpdate.tiltTo(tilt),
    );
  }

  void _goToPosition(LatLng position, {double bearing = 0.0}) {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        bearing: bearing,
        target: position,
        tilt: _tilt,
        zoom: _zoom,
      )),
    );
  }

  void _goToMyPosition() async {
    if (_userLocation == null) return;

    _myLocationController.value = true;

    _centerPosition = _userLocation!.position;
    final bearing = _userLocation!.bearing ?? 0.0;
    _goToPosition(_centerPosition!, bearing: bearing);

    _searchPlace(_centerPosition!);
  }

  Future<void> _addRelayMaplibre(List<Relay> relays) async {
    final theme = context.theme;

    await _clearMap();
    await _mapController!.addSymbols(List.of(relays.map((item) {
      return SymbolOptions(
        textHaloColor: theme.colorScheme.surface.toHexStringRGB(),
        textColor: theme.colorScheme.onSurface.toHexStringRGB(),
        geometry: _placeToLatLng(item.location),
        iconImage: Assets.images.pin2.keyName,
        iconOffset: const Offset(0.0, -20.0),
        textOffset: const Offset(0.0, -3.0),
        textField: item.name,
      );
    })));
  }

  Future<void> _drawLines(List<PolyLine> routes) async {
    const options = LineOptions(lineColor: "#ff0000", lineJoin: 'round', lineWidth: 4.0);
    for (final route in routes) {
      await _mapController!.addLine(options.copyWith(LineOptions(
          geometry: route.coordinates!.expand((coordinate) {
        return [LatLng(coordinate[1], coordinate[0])];
      }).toList())));
    }
  }

  /// PlaceService
  late AsyncController<AsyncState> _placeController;

  void _listenPlaceState(BuildContext context, AsyncState state) {
    if (state is PendingState) {
      _loadPin();
    } else {
      _resetPin();
    }
  }

  void _searchPlace(LatLng position) {
    _placeController.run(SearchPlaceEvent(position: (
      longitude: position.longitude,
      latitude: position.latitude,
    )));
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;
  List<Relay>? _relays;
  Relay? _currentRelay;

  void _listenRelayState(BuildContext context, AsyncState state) async {
    if (state case SuccessState<List<Relay>>(:final data)) {
      _addRelayMaplibre(data);
      _relays = List.from(data);
      _bannerAdIndex = Random().nextInt(_relays!.length);
      _relays!.insert(_bannerAdIndex, _relays![_bannerAdIndex]);
    }
  }

  Future<void> _selectRelay() {
    return _relayController.run(SelectRelayEvent(
      account: _currentAccount!,
    ));
  }

  /// RouteService
  late AsyncController<AsyncState> _routeController;
  List<PolyLine>? _routes;

  void _listenRouteState(BuildContext context, AsyncState state) {
    if (state case SuccessState<List<PolyLine>>(:final data)) {
      _drawLines(data);
      _routes = data;
    } else if (state case FailureState<GetRouteEvent>(:final code)) {
      switch (code) {
        default:
          showSnackBar(
            context: context,
            text: 'Le traçage a échoué',
          );
      }
    }
  }

  Future<void> _getRoute(Relay item) {
    final position = _placeToLatLng(item.location)!;
    return _routeController.run(GetRouteEvent(source: (
      longitude: _userLocation!.position.longitude,
      latitude: _userLocation!.position.latitude,
    ), destination: (
      longitude: position.longitude,
      latitude: position.latitude,
    )));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _pageStorageBucket = PageStorageBucket();
    _myLocationController = ValueNotifier(true);
    _pinVisibilityController = ValueNotifier(null);
    _pinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
      value: 0.0,
    );

    _interstitialAdTimeout = Duration.zero;

    _bannerAdLoaded = ValueNotifier(false);
    _loadBannerAd();

    /// MapLibre
    _mapPadding = 0.0;
    _zoom = 16.0;
    _tilt = 60.0;

    /// PlaceService
    _placeController = AsyncController(const InitState());

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  @override
  void dispose() {
    /// Assets
    _interstitialAdTimer?.cancel();

    super.dispose();
  }

  VoidCallback _callRelayModal(Relay item) {
    return () {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return HomeRelayCallModal(
            relay: item.name,
            onCall: () {
              launchUrl(Uri(
                path: item.contacts!.first,
                scheme: 'tel',
              ));
            },
          );
        },
      );
    };
  }

  VoidCallback _openRelaySheet(Relay item) {
    return () async {
      final mediaQuery = context.mediaQuery;
      final height = mediaQuery.size.height;
      final bottom = mediaQuery.padding.bottom;
      final sheetHeight = bottom + kBottomNavigationBarHeight * 3.0;
      _mapPadding = -((height / 2) - sheetHeight);

      _relays = null;
      _currentRelay = item;
      _myLocationController.value = true;
      _pinVisibilityController.value = null;

      await _interstitialAd?.show();
      _interstitialAd = null;

      if (_mapController != null) {
        await Future.wait([
          _updateContentInsets(),
          _setZoom(18.0),
          _setTitl(40.0),
          _clearMap(),
        ]);

        _addRelayMaplibre([item]);
      }
      if (!mounted) return;

      _routeController = AsyncController(const InitState());
      _getRoute(item);

      await showCustomBottomSheet(
        context: _scaffoldContext,
        builder: (context) {
          return HomeAccountBottomSheet(
            content: Column(
              children: [
                ControllerListener(
                  listener: _listenRouteState,
                  controller: _routeController,
                  child: HomeRelayItemWidget(
                    onCallPressed: _callRelayModal(item),
                    location: item.location!.title,
                    image: item.image,
                    name: item.name,
                  ),
                ),
                const Padding(padding: kMaterialListPadding),
                Row(
                  children: [
                    Expanded(
                      child: HomeCashInActionButton(
                        onPressed: _openChoiceScreen(
                          Transaction.cashin,
                          relay: item,
                        ),
                      ),
                    ),
                    Expanded(
                      child: HomeCashOutActionButton(
                        onPressed: _openChoiceScreen(
                          Transaction.cashout,
                          relay: item,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

      _openAccountListView();
    };
  }

  void _openAccountListView() async {
    _interstitialAdTimer = Timer(_interstitialAdTimeout, () async {
      _loadInterstitialAd();

      if (_interstitialAdTimeout <= const Duration(minutes: 5)) {
        _interstitialAdTimeout += const Duration(minutes: 1);
      }
    });

    final mediaQuery = context.mediaQuery;
    _mapPadding = mediaQuery.size.height * 0.5;

    _routes = null;
    _currentRelay = null;
    _pinVisibilityController.value = null;

    if (_mapController != null) {
      await Future.wait([
        _updateContentInsets(),
        _setZoom(14.0),
        _setTitl(0.0),
        _clearMap(),
      ]);
    }
    if (!mounted) return;

    await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        final cashin = _currentAccount!.transaction == Transaction.cashin;
        return HomeSliverBottomSheet(
          slivers: [
            HomeAccountAppBar(
              cashin: cashin,
              bottom: HomeAccountSelectedWidget(
                onTap: _openAccountScreen,
                currency: _currentAccount?.country?.currency,
                amount: _currentAccount!.amount!,
                image: _currentAccount!.image,
                name: _currentAccount!.name,
                cashin: cashin,
              ),
            ),
            ControllerConsumer(
              autoListen: true,
              listener: _listenRelayState,
              controller: _relayController,
              builder: (context, state, child) {
                return switch (state) {
                  PendingState() => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: HomeRelayLoadingListView(),
                    ),
                  SuccessState<List<Relay>>() => SliverList.builder(
                      itemCount: _relays!.length,
                      itemBuilder: (context, index) {
                        final item = _relays![index];
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
                          child: HomeRelayItemWidget(
                            location: item.location!.title,
                            onCallPressed: _callRelayModal(item),
                            onTap: _openRelaySheet(item),
                            image: item.image,
                            name: item.name,
                          ),
                        );
                      },
                    ),
                  FailureState<SelectRelayEvent>(:final code, :final event) => switch (code) {
                      'no-record' => SliverFillRemaining(
                          hasScrollBody: false,
                          child: HomeRelayNoFound(
                            account: _currentAccount!.name,
                            cashin: cashin,
                          ),
                        ),
                      _ => SliverFillRemaining(
                          hasScrollBody: false,
                          child: HomeRelayError(
                            onTry: () => _relayController.run(event!),
                          ),
                        ),
                    },
                  _ => const SliverToBoxAdapter(),
                };
              },
            ),
          ],
        );
      },
    );

    _showLocationWidget();
  }

  void _showLocationWidget() async {
    final mediaQuery = context.mediaQuery;
    final bottom = mediaQuery.padding.bottom;
    _mapPadding = bottom + kBottomNavigationBarHeight * 3.0;

    _pinVisibilityController.value = _mapPadding;

    if (_mapController != null) {
      await Future.wait([
        _updateContentInsets(),
        _setZoom(16.0),
        _setTitl(60.0),
        _clearMap(),
      ]);
    }
    if (!mounted) return;

    await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        return HomeBottomSheetBackground(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ControllerConsumer(
                listener: _listenPlaceState,
                controller: _placeController,
                builder: (context, state, child) {
                  return HomeLocationWidget(
                    suggestionsBuilder: _suggestionsBuilder,
                    title: switch (state) {
                      SuccessState<Place>(:final data) => Text(data.title),
                      FailureState() => const Text(
                          style: TextStyle(color: CupertinoColors.destructiveRed),
                          "Echec de chargement",
                        ),
                      _ => null,
                    },
                  );
                },
              ),
              const Padding(padding: kMaterialListPadding),
              const Divider(),
              const Padding(padding: kMaterialListPadding),
              Row(
                children: [
                  Expanded(
                    child: HomeCashInActionButton(
                      onPressed: _openChoiceScreen(Transaction.cashin),
                    ),
                  ),
                  Expanded(
                    child: HomeCashOutActionButton(
                      onPressed: _openChoiceScreen(Transaction.cashout),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    _showLocationWidget();
  }

  Future<Iterable<Widget>> _suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) async {
    if (_userLocation == null || controller.text.isEmpty) return const [];

    final position = _userLocation!.position;
    final data = searchPlace(query: controller.text, position: (
      longitude: position.longitude,
      latitude: position.latitude,
    ));
    return data.then((places) {
      return places.map((item) {
        return HomeLocationItemWidget(
          onTap: () {
            _myLocationController.value = false;
            _placeController.value = SuccessState(item);
            _goToPosition(_placeToLatLng(item)!);
            Navigator.pop(context);
          },
          subtitle: item.subtitle,
          title: item.title,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _pageStorageBucket,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HomeMenuButton(
              onPressed: _openMenuScreen,
            ),
            ValueListenableBuilder(
              valueListenable: _myLocationController,
              builder: (context, active, child) {
                return HomeLocationButton(
                  onPressed: _goToMyPosition,
                  active: active,
                );
              },
            ),
          ],
        ),
        body: AfterLayout(
          afterLayout: _afterLayout,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProfileLocationMap(
                onMapIdle: _onMapIdle,
                onMapMoved: _onMapMoved,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                onUserLocationUpdated: _onUserLocationUpdated,
              ),
              ValueListenableBuilder<double?>(
                valueListenable: _pinVisibilityController,
                builder: (context, padding, child) {
                  return Visibility(
                    key: ValueKey(padding),
                    visible: padding != null,
                    child: Builder(
                      builder: (context) {
                        return Positioned.fill(
                          bottom: padding,
                          child: ProfileLocationPin(
                            controller: _pinAnimationController,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
