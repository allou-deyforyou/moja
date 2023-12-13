import 'dart:async';

import 'package:listenable_tools/async.dart';

import '_service.dart';

class GetRouteEvent extends AsyncEvent<AsyncState> {
  const GetRouteEvent({
    required this.destination,
    required this.source,
  });
  final ({double longitude, double latitude}) source;
  final ({double longitude, double latitude}) destination;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final destinationQuery = '{longitude: ${destination.longitude}, latitude: ${destination.latitude}}';
      final sourceQuery = '{longitude: ${source.longitude}, latitude: ${source.latitude}}';
      final responses = await sql('fn::get_route($sourceQuery, $destinationQuery);');

      final List response = responses.first;
      final data = List.of(response.map((data) => PolyLine.fromMap(data)));

      emit(SuccessState(data));
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
