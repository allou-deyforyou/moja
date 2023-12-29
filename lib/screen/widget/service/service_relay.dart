import 'dart:async';

import 'package:listenable_tools/listenable_tools.dart';

import '_service.dart';

class SelectRelayEvent extends AsyncEvent<AsyncState> {
  const SelectRelayEvent({
    required this.account,
    this.relay,
  });
  final Account account;
  final Relay? relay;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final relayFilter = relay != null ? 'AND ${Relay.idKey} = ${relay!.id}' : '';
      final relayAccountFilters = 'WHERE ->(created WHERE out = ${account.id} AND ${Account.amountKey} >= ${account.amount})';
      final relayCashFilters = 'AND ->(created WHERE out = ${Account.schema}:cash AND ${Account.amountKey} >= ${account.amount})';
      final selectRelay = 'SELECT * FROM ${Relay.schema} $relayAccountFilters';
      final responses = await sql(switch (account.transaction!) {
        Transaction.cashout => '$selectRelay $relayCashFilters $relayFilter',
        Transaction.cashin => '$selectRelay $relayFilter',
      });

      final List response = responses.first;
      final data = List.of(response.map((data) => Relay.fromMap(data)!));

      if (data.isNotEmpty) {
        emit(SuccessState(data));
      } else {
        emit(FailureState(
         'no-record',
          event: this,
        ));
      }
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}
