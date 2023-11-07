import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

import '_service.dart';

abstract class BoxState extends Equatable {
  const BoxState();
  @override
  List<Object?> get props => const [];
}

class BoxStateInit extends BoxState {
  const BoxStateInit();
}

class BoxStatePending extends BoxState {
  const BoxStatePending();
}

class BoxStateFailure<T extends BoxEvent> extends BoxState {
  const BoxStateFailure({
    required this.code,
    this.event,
  });
  final T? event;
  final String code;
  @override
  List<Object?> get props => [code, event];
}

class BoxStateSubscription extends BoxState {
  const BoxStateSubscription({required this.subscription});
  final StreamSubscription subscription;
  @override
  List<Object?> get props => [subscription];
}

class BoxStateBoxList extends BoxState {
  const BoxStateBoxList({
    required this.data,
    this.current,
  });
  final List<Box> data;
  final Box? current;
  @override
  List<Object?> get props => [data];
}

class BoxStateBox extends BoxState {
  const BoxStateBox({required this.data});
  final Box data;
  @override
  List<Object?> get props => [data];
}

class BoxService extends ValueNotifier<BoxState> {
  BoxService([super.value = const BoxStateInit()]);

  static BoxService? _instance;
  static BoxService instance([BoxState state = const BoxStateInit()]) {
    return _instance ??= BoxService(state);
  }

  void reset() => value = const BoxStateInit();
  Future<void> add(BoxEvent event) => event.handle(this);
}

abstract class BoxEvent {
  const BoxEvent();

  Future<void> handle(BoxService service);
}

class SearchBox extends BoxEvent {
  const SearchBox({
    this.live = false,
    this.ids,
  });
  final bool live;

  final List<String>? ids;
  @override
  Future<void> handle(BoxService service) async {
    try {
      service.value = const BoxStateInit();
    } catch (error) {
      service.value = BoxStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class GetBox extends BoxEvent {
  const GetBox({
    this.live = false,
    required this.id,
  });
  final bool live;

  final String id;
  @override
  Future<void> handle(BoxService service) async {
    try {
      service.value = const BoxStateInit();
    } catch (error) {
      service.value = BoxStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class SetBox extends BoxEvent {
  const SetBox();
  @override
  Future<void> handle(BoxService service) async {
    try {
      service.value = const BoxStateInit();
    } catch (error) {
      service.value = BoxStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class DeleteBox extends BoxEvent {
  const DeleteBox({
    required this.box,
  });
  final Box box;
  @override
  Future<void> handle(BoxService service) async {
    try {
      service.value = const BoxStateInit();
    } catch (error) {
      service.value = BoxStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}
