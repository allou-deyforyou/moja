import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
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
  Account? _currentAccount;
  late final BuildContext _scaffoldContext;
  late ValueNotifier<bool> _myLocationController;
  late AnimationController _pinAnimationController;

  void _afterLayout(BuildContext context) {
    _scaffoldContext = context;
    _showLocationWidget();
  }

  void _animatePin() {
    _pinAnimationController.repeat(min: 0.15, max: 1.0);
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
          HomeChoiceScreen.currentPositionKey: _centerPosition,
          HomeChoiceScreen.currentTransactionKey: transaction,
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

  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;
  }

  Future<void> _onStyleLoadedCallback() async {
    double bottom = context.mediaQuery.padding.bottom;

    await Future.wait([
      _mapController!.updateContentInsets(EdgeInsets.only(
        bottom: bottom + kBottomNavigationBarHeight * 3,
        right: 16.0,
        left: 16.0,
      )),
      _loadImages(),
    ]);

    _goToMyPosition();
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

  void _onMapIdle() {
    _myLocationController.value = false;
    _centerPosition = _mapController!.cameraPosition!.target;
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (_myLocationController.value) _goToPosition(location.position);
    _userLocation = location;
  }

  void _goToPosition(
    LatLng position, {
    double zoom = 16.0,
    double bearing = 0.0,
  }) {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        bearing: bearing,
        tilt: 60.0,
        zoom: zoom,
      )),
    );
  }

  void _goToMyPosition() async {
    if (_userLocation == null) return;

    _myLocationController.value = true;

    _centerPosition = _userLocation!.position;
    final heading = _userLocation!.heading?.trueHeading;

    _searchPlace(_centerPosition!);

    _goToPosition(_centerPosition!, bearing: heading ?? 0.0);
  }

  Future<void> _addRelayMaplibre(List<Relay> relays) async {
    await _clearMap();
    await _mapController!.addSymbols(List.of(relays.map((item) {
      return SymbolOptions(
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
        return [LatLng(coordinate[0], coordinate[1])];
      }).toList())));
    }
  }

  /// PlaceService
  late AsyncController<AsyncState> _placeController;
  Place? _currentPlace;

  void _listenPlaceState(BuildContext context, AsyncState state) {
    if (state is PendingState) {
      return _animatePin();
    } else if (state case SuccessState<Place>(:final data)) {
      _currentPlace = data;
      _goToPosition(_placeToLatLng(_currentPlace)!);
    }
    return _resetPin();
  }

  void _searchPlace(LatLng position) {
    _placeController.run(SearchPlaceEvent(position: (
      longitude: position.longitude,
      latitude: position.latitude,
    )));
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state case SuccessState<List<Relay>>(:final data)) {
      _addRelayMaplibre(data);
    } else if (state case FailureState<SelectAccountEvent>(:final code)) {
      switch (code) {}
    }
  }

  Future<void> _selectRelay() {
    return _relayController.run(SelectRelayEvent(
      account: _currentAccount!,
    ));
  }

  /// RouteService
  late AsyncController<AsyncState> _routeController;

  void _listenRouteState(BuildContext context, AsyncState state) {
    if (state case SuccessState<List<PolyLine>>(:final data)) {
      _drawLines(data);
    } else if (state case FailureState<SelectAccountEvent>(:final code)) {
      switch (code) {}
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
    _myLocationController = ValueNotifier(true);
    _pinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    /// PlaceService
    _placeController = AsyncController(const InitState());

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  VoidCallback _callRelayModal(Relay item) {
    return () {};
  }

  VoidCallback _openRelaySheet(Relay item) {
    return () async {
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
                  child: HomeAccountItemWidget(
                    location: item.location!.title,
                    onCall: _callRelayModal(item),
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

      await _clearMap();

      _openAccountListView();
    };
  }

  void _openAccountListView() async {
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
            const SliverPadding(
              padding: kMaterialListPadding,
              sliver: SliverToBoxAdapter(child: Divider()),
            ),
            ControllerConsumer(
              listener: _listenRelayState,
              controller: _relayController,
              builder: (context, state, child) {
                return switch (state) {
                  PendingState() => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: HomeAccountLoadingListView(),
                    ),
                  SuccessState<List<Relay>>(:final data) => SliverVisibility(
                      visible: data.isNotEmpty,
                      replacementSliver: const SliverFillRemaining(
                        hasScrollBody: false,
                      ),
                      sliver: SliverList.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return HomeAccountItemWidget(
                            location: item.location!.title,
                            onCall: _callRelayModal(item),
                            onTap: _openRelaySheet(item),
                            image: item.image,
                            name: item.name,
                          );
                        },
                      ),
                    ),
                  _ => const SliverToBoxAdapter(),
                };
              },
            ),
          ],
        );
      },
    );

    await _mapController!.clearSymbols();

    _showLocationWidget();
  }

  void _showLocationWidget() async {
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
                      SuccessState<Place>(:final data) => data.title,
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

  Future<Iterable<Widget>> _suggestionsBuilder(BuildContext context, SearchController controller) async {
    if (_userLocation == null || controller.text.isEmpty) return const [];

    final position = _userLocation!.position;
    final data = searchPlace(query: controller.text, position: (
      longitude: position.longitude,
      latitude: position.latitude,
    ));
    return data.then((places) {
      return places.map((item) {
        return ListTile(
          onTap: () {
            _placeController.value = SuccessState(item);
            Navigator.pop(context);
          },
          leading: const Icon(CupertinoIcons.location_solid),
          subtitle: Text(item.subtitle),
          title: Text(item.title),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: ProfileLocationMap(
          onMapIdle: _onMapIdle,
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoadedCallback,
          onUserLocationUpdated: _onUserLocationUpdated,
        ),
      ),
    );
  }
}
