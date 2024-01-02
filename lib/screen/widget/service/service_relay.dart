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

      final relayFilter = 'AND ${Relay.idKey} = ${relay?.id}';

      final relayAccountFilters = 'WHERE ->(created WHERE out = ${account.id})';

      final relayCashInFilters = 'AND ->(created ${Account.amountKey} >= ${account.amount})';

      final relayCashOutFilters = 'AND ->(created WHERE out = ${Account.schema}:cash AND ${Account.amountKey} >= ${account.amount})';

      final selectRelay = 'SELECT * FROM ${Relay.schema} $relayAccountFilters';

      final responses = await sql(switch (account.transaction!) {
        Transaction.cashout when relay != null => '$selectRelay $relayCashOutFilters $relayFilter PARALLEL',
        Transaction.cashin when relay != null => '$selectRelay $relayCashInFilters $relayFilter PARALLEL',
        Transaction.cashout => '$selectRelay $relayCashOutFilters PARALLEL',
        Transaction.cashin => '$selectRelay $relayCashInFilters PARALLEL',
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
