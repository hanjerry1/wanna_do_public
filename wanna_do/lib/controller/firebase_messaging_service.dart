import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseMessagingService extends GetxService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<FirebaseMessagingService> init() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('메세지 data: ${message.data}');

      if (message.notification != null) {
        print('메세지 also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('메세지 clicked!');
    });

    return this;
  }
}
