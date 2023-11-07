import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

import '_service.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => const [];
}

class AccountStateInit extends AccountState {
  const AccountStateInit();
}

class AccountStatePending extends AccountState {
  const AccountStatePending();
}

class AccountStateFailure<T extends AccountEvent> extends AccountState {
  const AccountStateFailure({
    required this.code,
    this.event,
  });
  final T? event;
  final String code;
  @override
  List<Object?> get props => [code, event];
}

class AccountStateSubscription extends AccountState {
  const AccountStateSubscription({required this.subscription});
  final StreamSubscription subscription;
  @override
  List<Object?> get props => [subscription];
}

class AccountStateAccountList extends AccountState {
  const AccountStateAccountList({
    required this.data,
    this.current,
  });
  final List<Account> data;
  final Account? current;
  @override
  List<Object?> get props => [data];
}

class AccountStateAccount extends AccountState {
  const AccountStateAccount({required this.data});
  final Account data;
  @override
  List<Object?> get props => [data];
}

class AccountService extends ValueNotifier<AccountState> {
  AccountService([super.value = const AccountStateInit()]);

  static AccountService? _instance;
  static AccountService instance([AccountState state = const AccountStateInit()]) {
    return _instance ??= AccountService(state);
  }

  void reset() => value = const AccountStateInit();
  Future<void> add(AccountEvent event) => event.handle(this);
}

abstract class AccountEvent {
  const AccountEvent();

  Future<void> handle(AccountService service);
}

class SearchAccount extends AccountEvent {
  const SearchAccount({
    this.live = false,
    this.ids,
  });
  final bool live;

  final List<String>? ids;
  @override
  Future<void> handle(AccountService service) async {
    try {
      service.value = const AccountStateInit();

      service.value = AccountStateAccountList(
        data: List.generate(6, (index) => Account(name: "Wave", id: '$index', avatar: "link")),
      );
    } catch (error) {
      service.value = AccountStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class GetAccount extends AccountEvent {
  const GetAccount({
    this.live = false,
    required this.id,
  });
  final bool live;

  final String id;
  @override
  Future<void> handle(AccountService service) async {
    try {
      service.value = const AccountStateInit();
    } catch (error) {
      service.value = AccountStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class SetAccount extends AccountEvent {
  const SetAccount();
  @override
  Future<void> handle(AccountService service) async {
    try {
      service.value = const AccountStateInit();
    } catch (error) {
      service.value = AccountStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class DeleteAccount extends AccountEvent {
  const DeleteAccount({
    required this.account,
  });
  final Account account;
  @override
  Future<void> handle(AccountService service) async {
    try {
      service.value = const AccountStateInit();
    } catch (error) {
      service.value = AccountStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}
