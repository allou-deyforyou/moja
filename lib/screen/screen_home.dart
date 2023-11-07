import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';
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
  Transaction? _currentTransaction;

  void _pushMenuSheet() async {
    context.pushNamed(HomeMenuScreen.name);
  }

  void _pushSearchSheet() async {
    context.pushNamed(HomeSearchScreen.name);
  }

  void _pushCashInSheet() async {
    final data = await context.pushNamed<Transaction>(
      HomeAccountScreen.name,
      extra: TransactionType.cashin,
    );
    if (data != null) {
      _currentTransaction = data;
      _showBoxListSheet();
    }
  }

  void _pushCashOutSheet() async {
    final data = await context.pushNamed<Transaction>(
      HomeAccountScreen.name,
      extra: TransactionType.cashout,
    );
    if (data != null) {
      _currentTransaction = data;
      _showBoxListSheet();
    }
  }

  void _pushTransactionScreen() async {
    final data = await context.pushNamed<Transaction>(
      HomeTransactionScreen.name,
      extra: _currentTransaction,
    );
    if (data != null) {
      _currentTransaction = data;
      _showBoxListSheet();
    }
  }

  void _afterLayout(BuildContext context) {
    _scaffoldContext = context;
    _showFloatingActionButton();
  }

  /// PlaceService
  late final PlaceService _placeService;

  void _listenPlaceState(BuildContext context, PlaceState state) {
    if (state is PlaceStateInit) {
      _searchPlace();
    } else if (state is PlaceStatePlaceList) {
      _searchBox();
    }
  }

  Future<void> _searchPlace() {
    return _placeService.add(const SearchPlace(live: true));
  }

  /// BoxService
  late final BoxService _boxService;

  void _listenBoxState(BuildContext context, BoxState state) {}

  Future<void> _searchBox() {
    return _boxService.add(const SearchBox(live: true));
  }

  @override
  void initState() {
    super.initState();

    /// PlaceService
    _placeService = PlaceService();

    /// BoxService
    _boxService = BoxService();
  }

  void _showBoxItemBottomSheet() async {
    final data = await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        return HomeAccountItemBottomSheet(
          trailing: HomeSelectorListTile(onTap: _pushTransactionScreen),
          child: const SizedBox.shrink(),
        );
      },
    );
    if (data != null) {
    } else {
      _showBoxListSheet();
    }
  }

  void _showBoxListSheet() async {
    final data = await showCustomBottomSheet(
      context: _scaffoldContext,
      builder: (context) {
        return ValueListenableBuilder(
          valueListenable: _boxService,
          child: HomeSelectorListTile(onTap: _pushTransactionScreen),
          builder: (context, state, trailing) {
            return HomeAccountListView(
              trailing: trailing,
              itemCount: 10,
              itemBuilder: (context, index) {
                return HomeAccountItemCard(
                  title: const Text("Boba Pro"),
                  subtitle: const Text("Angré Marché"),
                  onPressed: _showBoxItemBottomSheet,
                );
              },
            );
          },
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
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              HomeCashInFloatingActionButton(
                onPressed: _pushCashInSheet,
              ),
              const SizedBox(height: 8.0),
              HomeCashOutFloatingActionButton(
                onPressed: _pushCashOutSheet,
              ),
            ],
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: AfterLayout(
        afterLayout: _afterLayout,
        child: const Placeholder(),
      ),
      appBar: HomeAppBar(
        leading: HomeBarsFilledButton(
          onPressed: _pushMenuSheet,
        ),
        middle: ValueListenableListener(
          listener: _listenBoxState,
          valueListenable: _boxService,
          child: ValueListenableConsumer(
            autoListen: true,
            listener: _listenPlaceState,
            valueListenable: _placeService,
            builder: (context, state, child) {
              return HomePositionFilledButton(
                onPressed: _pushSearchSheet,
                child: const Text("Koumassi Mairie"),
              );
            },
          ),
        ),
        trailing: HomeNotifsFilledButton(
          onPressed: () {},
        ),
      ),
    );
  }
}
