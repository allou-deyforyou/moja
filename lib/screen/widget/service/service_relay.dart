import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class SelectRelayEvent extends AsyncEvent<AsyncState> {
  const SelectRelayEvent({
    required this.account,
  });
  final Account account;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final relayAccountFilters = 'WHERE ->(created WHERE out = ${account.id} AND ${Account.amountKey} >= ${account.amount})';
      final relayCashFilters = 'AND ->(created WHERE out = ${Account.schema}:cash AND ${Account.amountKey} >= ${account.amount})';
      final selectRelay = 'SELECT * FROM ${Relay.schema} $relayAccountFilters';
      final responses = await sql(switch (account.transaction!) {
        Transaction.cashout => '$selectRelay $relayCashFilters',
        Transaction.cashin => selectRelay,
      });

      final List response = responses.first;
      final data = List.of(response.map((data) => Relay.fromMap(data)!));

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
