import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SelectAccountEvent extends AsyncEvent<AsyncState> {
  const SelectAccountEvent();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final responses = await sql('SELECT * FROM ${Account.schema}');

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

class SetAccountEvent extends AsyncEvent<AsyncState> {
  const SetAccountEvent({
    required this.account,
    required this.balance,
    required this.relay,
  });
  final Account account;
  final Account relay;

  final double balance;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final relayId = relay.id;
      final accountId = account.id;

      final accountQuery = 'LET \$created_id = SELECT VALUE id FROM ONLY created WHERE (in = $relayId and out=$accountId);';
      final accountUpdate = 'RETURN UPDATE ONLY \$created_id SET balance=$balance;';
      final accountCreate = 'RETURN RELATE ONLY $relayId->created->$accountId SET balance=$balance;';
      await sql('$accountQuery RETURN IF (\$created_id != NONE) {$accountUpdate} ELSE {$accountCreate};');

      final data = account.copyWith(amount: balance);

      await SaveAccountEvent(accounts: [data]).handle(emit);

      emit(SuccessState(data));
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
