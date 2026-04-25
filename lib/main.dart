import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:zizzle/Ai/AiChatScreen.dart';
import 'package:zizzle/Ai/WakeWord.dart';
import 'package:zizzle/Controllers/reelsfeed.dart';
import 'package:zizzle/Screens/Splash_screen.dart';
import 'package:zizzle/resources/updation_firestore.dart';
import 'package:zizzle/services/Notification_service.dart';

import 'package:zizzle/services/navigation_service.dart';
import 'package:zizzle/utils/utils.dart';
import 'package:zizzle/widgets/pulseloader.dart';

import 'ads/ads_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String unityAdsGameId = Platform.isIOS ? '5862912' : '5862913';
  await UnityAds.init(
    gameId: unityAdsGameId,
    onComplete: () => print('Initialization Complete'),
    onFailed: (error, message) =>
        print('Initialization Failed: $error $message'),
  );

  Admanager().loadrewardedad();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // final _notificationService = NotificationService();
  // await _notificationService.initFcm();
  // FirebaseMessaging.onBackgroundMessage(handlebackgroundmessage);
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  await Hive.openBox('cachedVideos');
  await registerservices();
  await SharedPreferences.getInstance();

  Get.lazyPut(() => ReelsController(), fenix: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late Navigationservice _navigationservice;
  // final wakeWordService = WakeWordService();

  MyApp({super.key}) {
    _navigationservice = _getIt.get<Navigationservice>();
  }

  final GetIt _getIt = GetIt.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: _navigationservice.navigatorkey,
      debugShowCheckedModeBanner: false,
      title: 'Zizzle',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black12),
      routes: _navigationservice.routes,
      home: SplashScreen(),
    );
  }
}
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late Navigationservice _navigationservice;
//   // late WakeWordService wakeWordService;
//   final GetIt _getIt = GetIt.instance;

//   OverlayEntry? siriOverlay;

//   @override
//   void initState() {
//     super.initState();
//     _navigationservice = _getIt.get<Navigationservice>();

//     // var wakeWordService = WakeWordService(context: context);
//     // wakeWordService.init();

//     // // 🔹 Listen for changes in isListening → show/hide overlay
//     // wakeWordService.isListening.addListener(() {
//     //   if (wakeWordService.isListening.value) {
//     //     _showSiriOverlay();
//     //   } else {
//     //     _hideSiriOverlay();
//     //   }
//     // });
//   }

//   void _showSiriOverlay() {
//     if (siriOverlay != null) return; // already showing

//     siriOverlay = OverlayEntry(
//       builder: (context) => Positioned(
//         bottom: 100,
//         left: 0,
//         right: 0,
//         child: Center(
//           child: Lottie.asset(
//             'assets/loading_siri.json', // 👈 your downloaded file
//             width: 100,
//             height: 100,
//             repeat: true,
//             animate: true,
//           ),
//         ),
//       ),
//     );

//     _navigationservice.navigatorkey?.currentState?.overlay
//         ?.insert(siriOverlay!);
//   }

//   void _hideSiriOverlay() {
//     siriOverlay?.remove();
//     siriOverlay = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       navigatorKey: _navigationservice.navigatorkey,
//       debugShowCheckedModeBanner: false,
//       title: 'Zizzle',
//       theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black12),
//       routes: _navigationservice.routes,
//       home: const SplashScreen(),
//     );
//   }
// }

Future<void> handlebackgroundmessage(RemoteMessage message) async {
  print("Backgroundmessage = ${message.notification?.title}");
}
