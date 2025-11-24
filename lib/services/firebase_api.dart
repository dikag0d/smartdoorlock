import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/api_service.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    print("FCM TOKEN: $token");

    if (token != null) {
      // 🔥 Langsung kirim token ke server TANPA username
      await ApiService.registerToken(token);
      print("Token berhasil dikirim ke server");
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
