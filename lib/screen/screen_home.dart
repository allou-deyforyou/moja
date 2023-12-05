import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:widget_tools/widget_tools.dart';

import '_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const name = 'home';
  static const path = '/';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Assets
  late final BuildContext _scaffoldContext;
  late ValueNotifier<bool> _myLocationController;
  Account? _currentAccount;

  Future<Iterable<Widget>> _suggestionsBuilder(BuildContext context, SearchController controller) async {
    return [];
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
      _openAccountListView();
    }
  }

  void _pushCashOutSheet() async {
    final data = await context.pushNamed<Account>(HomeChoiceScreen.name, extra: {
      HomeChoiceScreen.transactionKey: Transaction.cashout,
    });
    if (data != null) {
      _currentAccount = data;
      _openAccountListView();
    }
  }

  void _openTransactionScreen() async {
    final data = await context.pushNamed<Account>(HomeAccountScreen.name, extra: {
      HomeChoiceScreen.transactionKey: _currentAccount,
    });
    if (data != null) {
      _currentAccount = data;
      _openAccountListView();
    }
  }

  void _afterLayout(BuildContext context) {
    _scaffoldContext = context;
    _showFloatingActionButton();
  }

  /// MapLibre
  MaplibreMapController? _mapController;
  UserLocation? _userLocation;

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
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

  void _goToPosition(LatLng position, {double zoom = 18.0}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        zoom: zoom,
      )),
    );
  }

  void _goToMyPosition() async {
    if (_userLocation != null) {
      _myLocationController.value = true;
      _goToPosition(_userLocation!.position);
    }
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _myLocationController = ValueNotifier(false);
  }

  void _showBoxItemBottomSheet() async {
    final data = await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        return HomeAccountItemBottomSheet(
          trailing: HomeSelectorListTile(onTap: _openTransactionScreen),
          child: const SizedBox.shrink(),
        );
      },
    );
    if (data != null) {
    } else {
      _openAccountListView();
    }
  }

  void _openAccountListView() async {
    final data = await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        return HomeSliverBottomSheet(
          slivers: [
            HomeAccountAppBar(
              bottom: HomeAccountSelectedWidget(
                onTap: () {},
              ),
            ),
            SliverPadding(padding: kMaterialListPadding / 2),
            SliverList.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return HomeAccountItemWidget(
                  onTap: _showBoxItemBottomSheet,
                );
              },
            ),
          ],
        );
      },
    );
    if (data != null) {
    } else {
      _showFloatingActionButton();
    }
  }

  void _showFloatingActionButton() async {
    final data = await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                HomeCashInFloatingActionButton(
                  onPressed: _pushCashInSheet,
                ),
                const Padding(padding: kMaterialListPadding),
                HomeCashOutFloatingActionButton(
                  onPressed: _pushCashOutSheet,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (data != null) {
    } else {
      _showFloatingActionButton();
    }
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
          Flexible(
            child: HomePositionButton(
              suggestionsBuilder: _suggestionsBuilder,
              title: "Koumassi Mairie",
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _myLocationController,
            builder: (context, active, child) {
              return HomeLocationButton(
                onChanged: (value) => _goToMyPosition(),
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
