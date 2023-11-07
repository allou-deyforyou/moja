import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

import '_service.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => const [];
}

class TransactionStateInit extends TransactionState {
  const TransactionStateInit();
}

class TransactionStatePending extends TransactionState {
  const TransactionStatePending();
}

class TransactionStateFailure<T extends TransactionEvent> extends TransactionState {
  const TransactionStateFailure({
    required this.code,
    this.event,
  });
  final T? event;
  final String code;
  @override
  List<Object?> get props => [code, event];
}

class TransactionStateSubscription extends TransactionState {
  const TransactionStateSubscription({required this.subscription});
  final StreamSubscription subscription;
  @override
  List<Object?> get props => [subscription];
}

class TransactionStateTransactionList extends TransactionState {
  const TransactionStateTransactionList({
    required this.data,
    this.current,
  });
  final List<Transaction> data;
  final Transaction? current;
  @override
  List<Object?> get props => [data];
}

class TransactionStateTransaction extends TransactionState {
  const TransactionStateTransaction({required this.data});
  final Transaction data;
  @override
  List<Object?> get props => [data];
}

class TransactionService extends ValueNotifier<TransactionState> {
  TransactionService([super.value = const TransactionStateInit()]);

  static TransactionService? _instance;
  static TransactionService instance([TransactionState state = const TransactionStateInit()]) {
    return _instance ??= TransactionService(state);
  }

  void reset() => value = const TransactionStateInit();
  Future<void> add(TransactionEvent event) => event.handle(this);
}

abstract class TransactionEvent {
  const TransactionEvent();

  Future<void> handle(TransactionService service);
}

class SearchTransaction extends TransactionEvent {
  const SearchTransaction({
    this.live = false,
    this.ids,
  });
  final bool live;

  final List<String>? ids;
  @override
  Future<void> handle(TransactionService service) async {
    try {
      service.value = const TransactionStateInit();
    } catch (error) {
      service.value = TransactionStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class GetTransaction extends TransactionEvent {
  const GetTransaction({
    this.live = false,
    required this.id,
  });
  final bool live;

  final String id;
  @override
  Future<void> handle(TransactionService service) async {
    try {
      service.value = const TransactionStateInit();
    } catch (error) {
      service.value = TransactionStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class SetTransaction extends TransactionEvent {
  const SetTransaction();
  @override
  Future<void> handle(TransactionService service) async {
    try {
      service.value = const TransactionStateInit();
    } catch (error) {
      service.value = TransactionStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class DeleteTransaction extends TransactionEvent {
  const DeleteTransaction({
    required this.account,
  });
  final Transaction account;
  @override
  Future<void> handle(TransactionService service) async {
    try {
      service.value = const TransactionStateInit();
    } catch (error) {
      service.value = TransactionStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}
