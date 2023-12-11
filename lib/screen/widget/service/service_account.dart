import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

AsyncController<AsyncState> get currentAccounts => singleton(AsyncController<AsyncState>(const InitState()), Country.schema);


class SelectAccountEvent extends AsyncEvent<AsyncState> {
  const SelectAccountEvent({
    required this.position,
  });

  final ({double longitude, double latitude}) position;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final countryFilter = '->located->(${Country.schema} WHERE (${position.longitude}, ${position.latitude}) INSIDE ${Country.boundaryKey})';
      final responses = await sql('SELECT *, ->located->${Country.schema}.* AS ${Account.countryKey} FROM ${Account.schema} WHERE cash=NONE AND $countryFilter;');

      final List response = responses.first;
      final data = List.of(response.map((data) => Account.fromMap(data)!));

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
