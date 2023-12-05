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

      final responses = await sql('SELECT * FROM ${Relay.schema}');

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
