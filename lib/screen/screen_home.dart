import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:moja/screen/widget/service/service_relay.dart';
import 'package:widget_tools/widget_tools.dart';

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
  late ValueNotifier<bool> _myLocationController;
  Account? _currentAccount;

  late AnimationController _pinAnimationController;

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

  void _pushMenuSheet() async {
    context.pushNamed(HomeMenuScreen.name);
  }

  void _pushCashInSheet() async {
    final data = await context.pushNamed<Account>(HomeChoiceScreen.name, extra: {
      HomeChoiceScreen.transactionKey: Transaction.cashin,
    });
    if (data != null) {
      _currentAccount = data;
      _selectRelay();
      _openAccountListView();
    }
  }

  void _pushCashOutSheet() async {
    final data = await context.pushNamed<Account>(HomeChoiceScreen.name, extra: {
      HomeChoiceScreen.transactionKey: Transaction.cashout,
    });
    if (data != null) {
      _currentAccount = data;
      _selectRelay();
      _openAccountListView();
    }
  }

  void _openAccountScreen() async {
    final data = await context.pushNamed<Account>(HomeAccountScreen.name, extra: {
      HomeAccountScreen.accountKey: _currentAccount,
    });
    if (data != null) {
      _currentAccount = data;
      _selectRelay();
      _openAccountListView();
    }
  }

  void _afterLayout(BuildContext context) {
    _scaffoldContext = context;
    _showLocationWidget();
  }

  /// MapLibre
  MaplibreMapController? _mapController;
  UserLocation? _userLocation;

  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;

    double bottom = context.mediaQuery.padding.bottom;
    await _mapController!.updateContentInsets(EdgeInsets.only(
      bottom: bottom + kBottomNavigationBarHeight * 3,
      right: 16.0,
      left: 16.0,
    ));

    _goToMyPosition();
  }

  void _onMapIdle() {
    _myLocationController.value = false;
  }

  void _onMapMoved() {}

  void _onUserLocationUpdated(UserLocation location) {
    if (_myLocationController.value) _goToPosition(location.position);
    _userLocation = location;
  }

  void _goToPosition(LatLng position, {double zoom = 16.0}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        tilt: 60.0,
        zoom: zoom,
      )),
    );
  }

  void _goToMyPosition() async {
    if (_userLocation != null) {
      _myLocationController.value = true;
      _goToPosition(_userLocation!.position);
      _searchPlaceByPoint(_userLocation!.position);
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

  void _searchPlaceByPoint([LatLng? center]) {
    center ??= _mapController!.cameraPosition!.target;
    _placeController.run(SearchPlaceEvent(position: (
      center.longitude,
      center.latitude,
    )));
  }

  /// RelayService
  late final AsyncController<AsyncState> _relayController;

  void _listenRelayState(BuildContext context, AsyncState state) {
    if (state case FailureState<SelectAccountEvent>(:final code)) {
      switch (code) {}
    }
  }

  Future<void> _selectRelay() {
    return _relayController.run(SelectRelayEvent(
      account: _currentAccount!,
    ));
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _myLocationController = ValueNotifier(false);
    _pinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    /// PlaceService
    _placeController = AsyncController(const InitState());

    /// RelayService
    _relayController = AsyncController(const InitState());
  }

  VoidCallback _openRelaySheet(Relay relay) {
    return () async {
      final data = await showCustomBottomSheet(
        context: _scaffoldContext,
        builder: (context) {
          return const HomeAccountBottomSheet();
        },
      );
      if (data != null) {
      } else {
        _openAccountListView();
      }
    };
  }

  void _openAccountListView() async {
    final data = await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        final cashin = _currentAccount!.transaction == Transaction.cashin;
        return HomeSliverBottomSheet(
          slivers: [
            HomeAccountAppBar(
              cashin: cashin,
              bottom: HomeAccountSelectedWidget(
                onTap: _openAccountScreen,
                amount: _currentAccount!.amount!,
                image: _currentAccount!.image,
                name: _currentAccount!.name,
                cashin: cashin,
              ),
            ),
            SliverPadding(padding: kMaterialListPadding / 2),
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
                            onTap: _openRelaySheet(item),
                            location: item.location!.title,
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
    if (data != null) {
    } else {
      _showLocationWidget();
    }
  }

  void _showLocationWidget() async {
    final data = await showCustomBottomSheet(
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
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: HomeCashInActionButton(
                      onPressed: _pushCashInSheet,
                    ),
                  ),
                  Expanded(
                    child: HomeCashOutActionButton(
                      onPressed: _pushCashOutSheet,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (data != null) {
    } else {
      _showLocationWidget();
    }
  }

  Future<Iterable<Widget>> _suggestionsBuilder(BuildContext context, SearchController controller) async {
    if (_userLocation != null) {
      final position = _userLocation!.position;
      final data = searchPlaceByQuery(query: controller.text, position: (
        position.longitude,
        position.latitude,
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
    return [];
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
            onPressed: _pushMenuSheet,
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
          onMapMoved: _onMapMoved,
          onMapCreated: _onMapCreated,
          onUserLocationUpdated: _onUserLocationUpdated,
        ),
      ),
    );
  }
}
