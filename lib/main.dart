import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sk_app/screens/auth/login_screen.dart';
import 'package:sk_app/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Admin User: ravivi@gmail.com
// Admin Pass: gwapoko

// Sample User:
// barb@gmail.com
// Sample User Pass:
// 123456

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'sk-app-56284',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<void> notificationSetup() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'basic_channel_muted',
          channelName: 'Basic muted notifications ',
          channelDescription: 'Notification channel for muted basic tests',
          importance: NotificationImportance.High,
          playSound: false,
        )
      ],
    );
  }

  Future<void> onForegroundMessage() async {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (message.notification != null) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: Random().nextInt(9999),
              channelKey: 'basic_channel_muted',
              title: '${message.notification!.title}',
              body: '${message.notification!.body}',
              notificationLayout: NotificationLayout.BigText,
            ),
          );
        }
      },
    );
  }

  Future<bool> checkNotificationPermission() async {
    var res = await messaging.requestPermission();
    if (res.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else {
      return false;
    }
  }

  initPermission() async {
    if (await checkNotificationPermission() == true) {
      await notificationSetup();
      await onBackgroundMessage();
      await onForegroundMessage();
    }
  }

  Future<void> getToken() async {
    String? token = await messaging.getToken();
    var res = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get();
    if (res.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(res.docs[0].id)
          .update({"fcmToken": token});
    }
  }

  @override
  void initState() {
    initPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SK App',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state, you can show a loading indicator here if needed
            return const CircularProgressIndicator();
          }

          User? user = snapshot.data;

          if (user != null) {
            getToken();
            if (user.emailVerified) {
              // User is logged in and email is verified, navigate to HomeScreen
              return const HomeScreen();
            } else {
              // User is logged in and email is verified, pero kung eh home, dli mo balik sa loginScreen
              return const HomeScreen();
            }
          }
          // User is not logged in, navigate to LoginScreen
          return LoginScreen();
        },
      ),
    );
  }
}

Future<void> onBackgroundMessage() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(9999),
        channelKey: 'basic_channel_muted',
        title: '${message.notification!.title}',
        body: '${message.notification!.body}',
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }
}
