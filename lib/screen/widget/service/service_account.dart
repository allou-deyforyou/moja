import 'dart:async';

import 'package:isar/isar.dart';
import 'package:listenable_tools/async.dart';

import '_service.dart';

class SelectAccountEvent extends AsyncEvent<AsyncState> {
  const SelectAccountEvent();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final responses = await sql('SELECT * FROM ${Account.schema} WHERE cash=NONE');

      final List response = responses.first;
      final data = List.of(response.map((data) => Account.fromMap(data)!));

      await SaveAccountEvent(accounts: data).handle(emit);

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class LoadAccountEvent extends AsyncEvent<AsyncState> {
  const LoadAccountEvent({
    this.listen = false,
  });
  final bool listen;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      if (listen) {
        final stream = IsarLocalDB.isar.accounts.watchLazy(fireImmediately: true);
        await stream.forEach((data) async {
          final data = await IsarLocalDB.isar.accounts.where().findAll();
          if (data.isNotEmpty) {
            emit(SuccessState(data));
          } else {
            emit(FailureState(
              code: 'no-record',
              event: this,
            ));
          }
        });
      } else {
        final data = await IsarLocalDB.isar.accounts.where().findAll();
        if (data.isNotEmpty) {
          emit(SuccessState(data));
        } else {
          emit(FailureState(
            code: 'no-record',
            event: this,
          ));
        }
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class SaveAccountEvent extends AsyncEvent<AsyncState> {
  const SaveAccountEvent({
    required this.accounts,
  });
  final List<Account> accounts;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      await IsarLocalDB.isar.writeTxn(() async {
        return IsarLocalDB.isar.accounts.putAll(accounts);
      });

      emit(SuccessState(accounts));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
