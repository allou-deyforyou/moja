import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<AsyncState> get currentAccounts => singleton(AsyncController<AsyncState>(const InitState()), Country.schema);

class SelectAccountEvent extends AsyncEvent<AsyncState> {
  const SelectAccountEvent({
    required this.position,
    this.relay,
  });

  final ({double longitude, double latitude}) position;
  final Relay? relay;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final relayFilter = relay != null ? 'AND <-(created WHERE in=${relay!.id})' : '';
      final countryFilter = 'AND ->located->(${Country.schema} WHERE (${position.longitude}, ${position.latitude}) INSIDE ${Country.boundaryKey})';
      final responses = await sql('SELECT *, ->located->${Country.schema}.* AS ${Account.countryKey} FROM ${Account.schema} WHERE cash=NONE $countryFilter $relayFilter;');

      final List response = responses.first;
      final data = List.of(response.map((data) => Account.fromMap(data)!));

      if (data.isNotEmpty) {
        emit(SuccessState(data));
      } else {
        emit(FailureState(
          code: 'no-record',
          event: this,
        ));
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
