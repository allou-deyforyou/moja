import 'dart:isolate';
import 'dart:math';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_service.dart';

Future<LatLngBounds?> createLatLngBoundsFromList(List<List<double>> rawPositions) async {
  return compute((rawPositions) {
    final positions = List.of(rawPositions.map((item) => LatLng(item[1], item[0])));
    return _createLatLngBoundsFromList(positions);
  }, rawPositions);
}

LatLngBounds? _createLatLngBoundsFromList(List<LatLng> positions) {
  if (positions.isEmpty) return null;

  double minLat = positions[0].latitude;
  double maxLat = positions[0].latitude;
  double minLng = positions[0].longitude;
  double maxLng = positions[0].longitude;

  for (LatLng position in positions) {
    minLat = min(minLat, position.latitude);
    maxLat = max(maxLat, position.latitude);
    minLng = min(minLng, position.longitude);
    maxLng = max(maxLng, position.longitude);
  }

  LatLng southwest = LatLng(minLat, minLng);
  LatLng northeast = LatLng(maxLat, maxLng);

  return LatLngBounds(southwest: southwest, northeast: northeast);
}

class GetRouteEvent extends AsyncEvent<AsyncState> {
  const GetRouteEvent({
    required this.source,
    required this.destination,
  });

  final LatLng source;
  final LatLng destination;

  static List<LatLng> _parseResponse(List<dynamic> response) {
    final data = response.map((data) => Polygon.decode(data));
    return List.of(data.first.coordinates!.map((item) => LatLng(item[1], item[0])));
  }

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      final destinationQuery = '{longitude: ${destination.longitude}, latitude: ${destination.latitude}}';
      final sourceQuery = '{longitude: ${source.longitude}, latitude: ${source.latitude}}';
      final responses = await sql('fn::get_route($sourceQuery, $destinationQuery);');

      final List response = responses.first;
      final data = await compute(_parseResponse, response);
      data.insert(0, source);
      data.add(destination);

      emit(SuccessState(data, event: this));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class TruncateRouteEvent extends AsyncEvent<AsyncState> {
  const TruncateRouteEvent({
    required this.route,
  });

  final List<LatLng> route;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    final receivePort = ReceivePort();
    final controller = StreamController<LatLng>();
    try {
      emit(const PendingState());
      final userLocation = controller.stream;
      receivePort.forEach((data) {
        if (data is SendPort) {
          userLocation.listen(data.send, onDone: () => data.send(null));
        } else if (data case (userLocation: LatLng userLocation, route: List<LatLng>? route)) {
          emit(SuccessState(route?..insert(0, userLocation), event: this));
        }
      });

      Isolate.spawn(
        (entry) async {
          final receivePort = ReceivePort();
          entry.sendPort.send(receivePort.sendPort);
          return receivePort.forEach((data) {
            if (data == null) {
              receivePort.close();
            } else if (data is LatLng) {
              final route = _truncateRoute(entry.route, data, 50.0);
              entry.sendPort.send((userLocation: data, route: route));
            }
          });
        },
        (route: route, sendPort: receivePort.sendPort),
        onError: receivePort.sendPort,
        onExit: receivePort.sendPort,
        errorsAreFatal: true,
      );
      controller.onCancel = receivePort.close;

      emit(SuccessState(controller, event: this));
    } catch (error) {
      receivePort.close();
      controller.close();

      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

List<LatLng>? _truncateRoute(List<LatLng> route, LatLng userLocation, double thresholdDistance) {
  // Trouver le point le plus proche sur la route à partir de la position de l'utilisateur
  int closestPointIndex = _findClosestPointIndex(route, userLocation);

  // Vérifier la distance entre la position actuelle de l'utilisateur et le point le plus proche
  double distance = _calculateDistance(userLocation, route[closestPointIndex]);

  // Si la distance dépasse le seuil, l'utilisateur est considéré comme ayant quitté la ligne
  if (distance > thresholdDistance) {
    return null;
  }

  // Tronquer la route pour inclure uniquement les points à partir de la projection
  return route.sublist(closestPointIndex);
}

int _findClosestPointIndex(List<LatLng> route, LatLng userLocation) {
  double minDistance = double.infinity;
  int closestPointIndex = 0;

  for (int i = 0; i < route.length - 1; i++) {
    LatLng pointA = route[i];
    LatLng pointB = route[i + 1];

    // Trouver la projection orthogonale du point utilisateur sur la ligne (pointA, pointB)
    LatLng projection = _orthogonalProjection(userLocation, pointA, pointB);

    // Calculer la distance entre le point utilisateur et la projection
    double distance = _calculateDistance(userLocation, projection);

    if (distance < minDistance) {
      minDistance = distance;
      closestPointIndex = i + 1; // +1 car nous voulons le point suivant pour tronquer la liste
    }
  }

  return closestPointIndex;
}

LatLng _orthogonalProjection(LatLng p, LatLng a, LatLng b) {
  double apx = p.latitude - a.latitude;
  double apy = p.longitude - a.longitude;
  double abx = b.latitude - a.latitude;
  double aby = b.longitude - a.longitude;

  double ab2 = abx * abx + aby * aby;
  double apAb = apx * abx + apy * aby;
  double t = apAb / ab2;

  if (t < 0.0) {
    return a; // projection est avant le début de la ligne
  } else if (t > 1.0) {
    return b; // projection est après la fin de la ligne
  } else {
    return LatLng(a.latitude + t * abx, a.longitude + t * aby);
  }
}

double _calculateDistance(LatLng ap, LatLng bp) {
  // Formule de distance haversine
  const R = 6371000; // Rayon de la Terre en mètres
  double lat1 = ap.latitude * pi / 180;
  double lat2 = bp.latitude * pi / 180;
  double lon1 = ap.longitude * pi / 180;
  double lon2 = bp.longitude * pi / 180;

  double dlat = lat2 - lat1;
  double dlon = lon2 - lon1;

  double a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}
