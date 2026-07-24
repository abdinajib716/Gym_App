import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseDeviceTokenProvider {
  const FirebaseDeviceTokenProvider({this.overrideToken});

  final String? overrideToken;

  Future<String?> readToken() async {
    final override = overrideToken?.trim();
    if (override != null && override.isNotEmpty) return override;

    final initialized = await _ensureFirebaseInitialized();
    if (!initialized) return null;

    try {
      await FirebaseMessaging.instance.requestPermission();
      return FirebaseMessaging.instance.getToken(
        vapidKey: const String.fromEnvironment('FIREBASE_WEB_VAPID_KEY'),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _ensureFirebaseInitialized() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
