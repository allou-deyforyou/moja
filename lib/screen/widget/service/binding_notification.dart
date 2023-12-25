import 'package:service_tools/service_tools.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await runService(const MyService());
}

class NotificationConfig {
  const NotificationConfig._();

  static Future<void> development() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> production() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
