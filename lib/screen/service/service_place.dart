import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

import '_service.dart';

abstract class PlaceState extends Equatable {
  const PlaceState();
  @override
  List<Object?> get props => const [];
}

class PlaceStateInit extends PlaceState {
  const PlaceStateInit();
}

class PlaceStatePending extends PlaceState {
  const PlaceStatePending();
}

class PlaceStateFailure<T extends PlaceEvent> extends PlaceState {
  const PlaceStateFailure({
    required this.code,
    this.event,
  });
  final T? event;
  final String code;
  @override
  List<Object?> get props => [code, event];
}

class PlaceStateSubscription extends PlaceState {
  const PlaceStateSubscription({required this.subscription});
  final StreamSubscription subscription;
  @override
  List<Object?> get props => [subscription];
}

class PlaceStatePlaceList extends PlaceState {
  const PlaceStatePlaceList({
    required this.data,
    this.current,
  });
  final List<Place> data;
  final Place? current;
  @override
  List<Object?> get props => [data];
}

class PlaceStatePlace extends PlaceState {
  const PlaceStatePlace({required this.data});
  final Place data;
  @override
  List<Object?> get props => [data];
}

class PlaceService extends ValueNotifier<PlaceState> {
  PlaceService([super.value = const PlaceStateInit()]);

  static PlaceService? _instance;
  static PlaceService instance([PlaceState state = const PlaceStateInit()]) {
    return _instance ??= PlaceService(state);
  }

  void reset() => value = const PlaceStateInit();
  Future<void> add(PlaceEvent event) => event.handle(this);
}

abstract class PlaceEvent {
  const PlaceEvent();

  Future<void> handle(PlaceService service);
}

class SearchPlace extends PlaceEvent {
  const SearchPlace({
    this.live = false,
    this.ids,
  });
  final bool live;

  final List<String>? ids;
  @override
  Future<void> handle(PlaceService service) async {
    try {
      service.value = const PlaceStateInit();
    } catch (error) {
      service.value = PlaceStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class GetPlace extends PlaceEvent {
  const GetPlace({
    this.live = false,
    required this.id,
  });
  final bool live;

  final String id;
  @override
  Future<void> handle(PlaceService service) async {
    try {
      service.value = const PlaceStateInit();
    } catch (error) {
      service.value = PlaceStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class SetPlace extends PlaceEvent {
  const SetPlace();
  @override
  Future<void> handle(PlaceService service) async {
    try {
      service.value = const PlaceStateInit();
    } catch (error) {
      service.value = PlaceStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class DeletePlace extends PlaceEvent {
  const DeletePlace({
    required this.place,
  });
  final Place place;
  @override
  Future<void> handle(PlaceService service) async {
    try {
      service.value = const PlaceStateInit();
    } catch (error) {
      service.value = PlaceStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}
