import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_service.dart';

class SelectRelayEvent extends AsyncEvent<AsyncState> {
  const SelectRelayEvent({
    this.location,
    this.account,
    this.relay,
  });

  final Account? account;
  final Point? location;
  final Relay? relay;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final relayAccountFilters = '->(created WHERE out = ${account?.id})';

      final relayCashInFilters = '->(created WHERE ${Account.amountKey} >= ${account?.amount})';

      final relayCashOutFilters = '->(created WHERE out = ${Account.schema}:cash AND ${Account.amountKey} >= ${account?.amount})';

      final relayIdFilter = '${Relay.idKey} = ${relay?.id}';

      final polygon = await compute((coordinates) => Polygon.fromRadius(coordinates, 1500, sides: 360), location?.coordinates);
      final relayLocationFilter = '${Relay.locationKey}.${Place.positionKey} IN ${polygon?.toSurreal()}';

      const selectRelay = 'SELECT * FROM ${Relay.schema}';

      final responses = await sql(switch (account?.transaction) {
        Transaction.cashout when relay != null => '$selectRelay WHERE $relayAccountFilters AND $relayCashOutFilters AND $relayIdFilter PARALLEL',
        Transaction.cashin when relay != null => '$selectRelay WHERE $relayAccountFilters AND $relayCashInFilters AND $relayIdFilter PARALLEL',
        Transaction.cashout when location != null => '$selectRelay WHERE $relayAccountFilters AND $relayLocationFilter AND $relayCashOutFilters PARALLEL',
        Transaction.cashin when location != null => '$selectRelay WHERE $relayAccountFilters AND $relayLocationFilter AND $relayCashInFilters PARALLEL',
        _ when location != null => '$selectRelay WHERE $relayLocationFilter',
        _ => throw 'No Handle',
      });

      final List response = responses.first;
      final data = List.of(response.map((data) => Relay.fromMap(data)!));

      if (data.isNotEmpty) {
        emit(SuccessState(data, event: this));
      } else {
        emit(FailureState(
          'no-record',
          event: this,
        ));
      }

      FirebaseConfig.firebaseAnalytics.logEvent(
        name: 'select_relay',
        parameters: {
          Relay.idKey: relay?.id,
          Account.amountKey: account?.amount,
          Relay.locationKey: location?.toMap().toString(),
          Account.transactionKey: account?.transaction?.name,
        }..removeWhere((key, value) => value == null),
      );
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}
