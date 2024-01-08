import 'dart:math';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_tools/widget_tools.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import '_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const name = 'home';
  static const path = '/';

  static Future<String?> redirect(BuildContext context, GoRouterState state) async {
    if (await Permission.locationWhenInUse.isGranted) {
      return null;
    }
    return OnBoardingScreen.path;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  /// Assets

  late final BuildContext _scaffoldContext;
  late final PageStorageBucket _pageStorageBucket;
  late DraggableScrollableController _draggableScrollableController;

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
    _interstitialAdTimer = Timer(_interstitialAdTimeout, () async {
      if (_interstitialAd == null) {
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

        if (_interstitialAdTimeout <= const Duration(minutes: 5)) {
          _interstitialAdTimeout += const Duration(minutes: 1);
        }
      }

      _loadInterstitialAd();
    });
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
        _selectAccountRelay(
          account: _currentAccount!,
          location: Point(coordinates: [
            _centerPosition!.longitude,
            _centerPosition!.latitude,
          ]),
        );
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
      _selectAccountRelay(
        account: _currentAccount!,
        location: Point(coordinates: [
          _centerPosition!.longitude,
          _centerPosition!.latitude,
        ]),
      );
      _openAccountListView();
    }
  }

  /// Permission
  late final AsyncController<AsyncState> _permissionController;

  void _listenPermissionState(BuildContext context, AsyncState state) async {
    if (state case SuccessState<Permission>(:final data) when data == Permission.notification) {
      NotificationConfig.enableNotifications();
    } else if (state case FailureState<String>(:final data)) {
      switch (data) {
        case 'no-permission':
          HiveLocalDB.notifications = false;
          break;
        default:
      }
    }
  }

  Future<void> _requestPermission(Permission permission) {
    return _permissionController.run(RequestPermissionEvent(
      permission: permission,
    ));
  }

  /// MapLibre
  MaplibreMapController? _mapController;
  UserLocation? _userLocation;
  LatLng? _centerPosition;

  late double _mapPadding;
  late double _zoom;
  late double _tilt;
  double? _bearing;

  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;
  }

  Future<void> _onStyleLoadedCallback() async {
    await Future.wait([
      _updateContentInsets(),
      _loadImages(),
    ]);
    if (_relays != null) {
      _addRelayMaplibre(_relays!);
    } else if (_currentRelay != null && _route != null) {
      _addRelayMaplibre([_currentRelay!]);
      _drawLines(_route!);
    }
  }

  Future<void> _updateContentInsets() async {
    if (_mapController == null) return;
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
    final pintData = await rootBundle.load(Assets.images.store.path);
    await _mapController!.addImage(
      Assets.images.store.keyName,
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

      _selectRelay(
        location: Point(coordinates: [
          _centerPosition!.longitude,
          _centerPosition!.latitude,
        ]),
      );
    }
  }

  Future<void> _setZoom(double zoom) async {
    await _mapController?.animateCamera(
      CameraUpdate.zoomTo(_zoom = zoom),
    );
  }

  Future<void> _setTitl(double tilt) async {
    await _mapController?.animateCamera(
      CameraUpdate.tiltTo(_tilt = tilt),
    );
  }

  void _goToBounds(LatLngBounds bounds) {
    if (_mapController == null) return;

    final mediaQuery = context.mediaQuery;
    final height = mediaQuery.size.height * 0.75;
    final paddingBottom = mediaQuery.padding.bottom;
    final top = paddingBottom + kBottomNavigationBarHeight;
    final bottom = height + kBottomNavigationBarHeight;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        bottom: bottom,
        right: 24.0,
        left: 24.0,
        top: top,
      ),
    );
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (_userLocation == null || (_myLocationController.value && _pinVisibilityController.value == null)) {
      _goToMyPosition(location);
    } else if (_myLocationController.value) {
      _goToPosition(location.position);
    }

    _userLocation = location;
    _routeTruncateController?.add(_userLocation!.position);
  }

  void _goToPosition(LatLng position) {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        bearing: _bearing ?? 0.0,
        target: position,
        tilt: _tilt,
        zoom: _zoom,
      )),
    );
  }

  void _goToMyPosition([UserLocation? location]) async {
    location ??= _userLocation;
    if (location == null) return;

    _myLocationController.value = true;

    _bearing = location.heading?.trueHeading;

    await _updateContentInsets();

    _goToPosition(location.position);

    if (_pinVisibilityController.value != null) {
      _centerPosition = location.position;

      _selectRelay(
        location: Point(coordinates: [
          _centerPosition!.longitude,
          _centerPosition!.latitude,
        ]),
      );
      _searchPlace(
        _centerPosition!,
      );
    }
  }

  Future<void> _addRelayMaplibre(List<Relay> relays) async {
    final theme = context.theme;

    await _clearMap();
    await _mapController!.addSymbols(List.of(relays.map((item) {
      return SymbolOptions(
        textHaloColor: theme.colorScheme.surface.toHexStringRGB(),
        textColor: theme.colorScheme.onSurface.toHexStringRGB(),
        iconColor: theme.colorScheme.surface.toHexStringRGB(),
        geometry: _placeToLatLng(item.location),
        iconImage: Assets.images.store.keyName,
        iconOffset: const Offset(0.0, -20.0),
        textOffset: switch (defaultTargetPlatform) {
          TargetPlatform.android => const Offset(0.0, -2.8),
          TargetPlatform.iOS => const Offset(0.0, -2.0),
          _ => throw 'Unsupported Platform',
        },
        textField: item.name,
        textHaloBlur: 2.0,
        iconSize: switch (defaultTargetPlatform) {
          TargetPlatform.android => 0.5,
          TargetPlatform.iOS => 0.25,
          _ => throw 'Unsupported Platform',
        },
      );
    })));
  }

  Future<void> _drawLines(List<LatLng> route) async {
    final options = LineOptions(
      lineColor: "#ff0000",
      lineJoin: 'round',
      geometry: route,
      lineWidth: 4.0,
    );

    final line = _mapController!.lines.firstOrNull;
    if (line != null) {
      await _mapController!.updateLine(line, options);
    } else {
      await _mapController!.addLine(options);
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
  late final AsyncController<AsyncState> _accountRelayController;
  late final AsyncController<AsyncState> _relayController;
  List<Relay>? _relays;
  Relay? _currentRelay;

  void _listenRelayState(BuildContext context, AsyncState state) async {
    if (state case SuccessState<List<Relay>>(:final data, :final SelectRelayEvent event)) {
      _addRelayMaplibre(data);
      _relays = List.from(data);
      _bannerAdIndex = Random().nextInt(_relays!.length);
      _relays!.insert(_bannerAdIndex, _relays![_bannerAdIndex]);

      if (event.account == null) return;

      final positions = List.of(_relays!.map((item) => item.location!.position!.coordinates!));
      positions.add(event.location!.coordinates!);
      final bounds = await createLatLngBoundsFromList(positions);
      if (bounds != null) _goToBounds(bounds);
    } else if (state case FailureState<String>(:final data)) {
      switch (data) {
        case 'no-record':
          _relays = null;
          await _clearMap();
          break;
        default:
      }
    }
  }

  Future<void> _selectAccountRelay({
    Account? account,
    Point? location,
  }) {
    return _accountRelayController.run(SelectRelayEvent(
      location: location,
      account: account,
    ));
  }

  Future<void> _selectRelay({
    Point? location,
  }) {
    return _relayController.run(SelectRelayEvent(
      location: location,
    ));
  }

  /// RouteService
  late AsyncController<AsyncState> _routeController;
  StreamController<LatLng>? _routeTruncateController;
  List<LatLng>? _route;

  void _listenRouteState(BuildContext context, AsyncState state) async {
    if (state case SuccessState<List<LatLng>>(:final data)) {
      _route = data;
      _drawLines(data);

      _truncateRoute(data);
    } else if (state case SuccessState<StreamController<LatLng>>(:final data)) {
      _routeTruncateController = data;
    } else if (state case SuccessState<List<LatLng>?>(:final data)) {
      if (data != null) {
        _drawLines(data);
      } else {
        if (_routeController.value is! PendingState) {
          _getRoute(_currentRelay!);
        }
      }
    } else if (state case FailureState<String>(:final data)) {
      switch (data) {
        default:
          final localizations = context.localizations;
          showSnackBar(
            context: context,
            text: localizations.tracingfailed.capitalize(),
          );
      }
    }
  }

  Future<void> _getRoute(Relay item) {
    final position = _placeToLatLng(item.location)!;
    return _routeController.run(GetRouteEvent(
      source: _userLocation!.position,
      destination: position,
    ));
  }

  Future<void> _truncateRoute(List<LatLng> route) {
    _routeTruncateController?.close();
    _routeTruncateController = null;

    return _routeController.run(TruncateRouteEvent(
      route: route,
    ));
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
    _loadInterstitialAd();

    _bannerAdLoaded = ValueNotifier(false);
    _loadBannerAd();

    /// PermissionService
    _permissionController = AsyncController(const InitState());
    if (HiveLocalDB.notifications == null) {
      _requestPermission(Permission.notification);
    }

    /// MapLibre
    _mapPadding = 0.0;
    _zoom = 16.0;
    _tilt = 60.0;

    /// PlaceService
    _placeController = AsyncController(const InitState());

    /// RelayService
    _relayController = AsyncController(const InitState());
    _accountRelayController = AsyncController(const InitState());
  }

  @override
  void dispose() {
    /// Assets
    _interstitialAdTimer?.cancel();

    /// RouteService
    _routeTruncateController?.close();
    _routeTruncateController = null;

    super.dispose();
  }

  VoidCallback _callRelayModal(Relay item) {
    return () {
      final phone = item.contacts!.first;

      void onCall() {
        FirebaseConfig.firebaseAnalytics.logEvent(
          parameters: {Relay.idKey: item.id, Relay.nameKey: item.name},
          name: 'call_relay',
        );
        launchUrl(Uri(scheme: 'tel', path: phone));
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        onCall();
      } else {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return HomeRelayCallModal(
              relay: item.name,
              onCall: onCall,
            );
          },
        );
      }
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
      _getRoute(_currentRelay!);

      _draggableScrollableController.reset();

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
    final mediaQuery = context.mediaQuery;
    _mapPadding = mediaQuery.size.height * 0.5;

    _route = null;
    _relays = null;
    _currentRelay = null;

    _routeTruncateController?.close();
    _routeTruncateController = null;

    _pinVisibilityController.value = null;
    _myLocationController.value = false;

    if (_mapController != null) {
      await Future.wait([
        _updateContentInsets(),
        _setZoom(14.0),
        _setTitl(0.0),
        _clearMap(),
      ]);
    }
    if (!mounted) return;

    _draggableScrollableController = DraggableScrollableController();

    await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        final cashin = _currentAccount!.transaction == Transaction.cashin;
        return HomeSliverBottomSheet(
          controller: _draggableScrollableController,
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
            ControllerBuilder(
              autoListen: true,
              listener: _listenRelayState,
              controller: _accountRelayController,
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
                  FailureState<String>(:final data, :final SelectRelayEvent event) => Builder(
                      builder: (context) {
                        void onTryAgain() => _accountRelayController.run(event);
                        return switch (data) {
                          'no-record' => SliverFillRemaining(
                              hasScrollBody: false,
                              child: HomeRelayNoFound(
                                account: _currentAccount!.name,
                                onTry: onTryAgain,
                                cashin: cashin,
                              ),
                            ),
                          _ => SliverFillRemaining(
                              hasScrollBody: false,
                              child: HomeRelayError(
                                onTry: onTryAgain,
                              ),
                            ),
                        };
                      },
                    ),
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

    _relays = null;

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
              ControllerListener(
                autoListen: true,
                listener: _listenRelayState,
                controller: _relayController,
                child: ControllerBuilder(
                  listener: _listenPlaceState,
                  controller: _placeController,
                  builder: (context, state, child) {
                    return HomeLocationWidget(
                      suggestionsBuilder: _suggestionsBuilder,
                      error: switch (state) {
                        FailureState<String>(:final data) => data,
                        _ => null,
                      },
                      title: switch (state) {
                        SuccessState<Place>(:final data) => data.title,
                        _ => null,
                      },
                    );
                  },
                ),
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
    return ControllerListener(
      listener: _listenPermissionState,
      controller: _permissionController,
      child: PageStorage(
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
      ),
    );
  }
}
