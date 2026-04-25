import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:rhino_flutter/rhino.dart';
import 'package:rhino_flutter/rhino_manager.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:zizzle/Screens/add_post_screen.dart';
import 'package:zizzle/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class WakeWordService {
  final BuildContext context;
  final FlutterTts _tts = FlutterTts();
  PorcupineManager? _porcupineManager;
  RhinoManager? _rhinoManager;
  final ValueNotifier<bool> isListening = ValueNotifier(false);
  // ✅ Use global Navigationservice from GetIt
  final Navigationservice _navigationservice = GetIt.I<Navigationservice>();
  WakeWordService({required this.context});

  Future<void> init() async {
    try {
      final String wakePath = await _copyAsset(
          'assets/hey-zizzle_en_ios_v3_0_0.ppn', 'hey_zizzle.ppn');
      final String rhnPath = await _copyAsset(
          'assets/Post_en_ios_v3_0_0.rhn', 'zizzle_commands.rhn');

      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        "3qHo8Zv7eQ0Et8VBMlvl868sFRLifgPBivWvUcCSIPA8i21Ngd7R6w==",
        [wakePath],
        _onWakeWord,
      );

      _rhinoManager = await RhinoManager.create(
        "3qHo8Zv7eQ0Et8VBMlvl868sFRLifgPBivWvUcCSIPA8i21Ngd7R6w==",
        rhnPath,
        _onInference,
        sensitivity: 0.7,
        endpointDurationSec: 2.5,
        requireEndpoint: true,
        processErrorCallback: (e) => print("Rhino error: $e"),
      );

      await _porcupineManager?.start();
      print('🎧 Wake-word listening started');
    } catch (e) {
      print('Error initializing WakeWordService: $e');
    }
  }

  Future<String> _copyAsset(String asset, String name) async {
    final data = await rootBundle.load(asset);
    final file =
        File('${(await getApplicationDocumentsDirectory()).path}/$name');
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }

  void _onWakeWord(int index) async {
    print('🎤 Wake word detected!');
    isListening.value = true;
    await _tts.speak("Yes? I'm listening");
    try {
      await _rhinoManager?.process();
    } catch (e) {
      print('Rhino process error: $e');
      isListening.value = false;
    }
  }

  void _onInference(RhinoInference inference) async {
    if (inference.isUnderstood == true) {
      final intent = inference.intent!;
      print('Intent: $intent, slots: ${inference.slots}');
      await _executeIntent(intent);
    } else {
      print('Did not understand.');
      await _tts.speak("Sorry I didn't get that.");
      isListening.value = false;
    }

    // ✅ hide Siri wave after command is done
    // isListening.value = false;

    // Resume wake-word listening
    await _porcupineManager?.start();
  }

  Future<void> _executeIntent(String intent) async {
    switch (intent) {
      case 'Post_photo':
        await _tts.speak("Opening Add Post screen");
        _navigationservice.pushnamed("/postphoto");
        isListening.value = false;
        break;
      case 'Settings':
        await _tts.speak("Opening Settings");
        _navigationservice.pushReplacementname("/home");
        isListening.value = false;
        break;
      // add more case blocks for other commands…
      default:
        await _tts.speak("Command not recognized");
    }
  }

  Future<void> stop() async {
    await _porcupineManager?.stop();
    await _porcupineManager?.delete();
    await _rhinoManager?.delete();
    isListening.value = false;
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:get_it/get_it.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:porcupine_flutter/porcupine_manager.dart';
// import 'package:rhino_flutter/rhino.dart';
// import 'package:rhino_flutter/rhino_manager.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:zizzle/Screens/profile_screen.dart';
// import 'package:zizzle/services/navigation_service.dart';

// class WakeWordService {
//   final BuildContext context;
//   final FlutterTts _tts = FlutterTts();
//   PorcupineManager? _porcupineManager;
//   RhinoManager? _rhinoManager;
//   final ValueNotifier<bool> isListening = ValueNotifier(false);
//   static const _audioChannel = MethodChannel('wakeword_service/audio');
//   final Navigationservice _navigationservice = GetIt.I<Navigationservice>();

//   WakeWordService({required this.context});

//   Future<void> init() async {
//     try {
//       // 🔊 Configure audio session (Siri-like)
//       await _configureAudioSession();
//       await _forceSpeaker();
//       final String wakePath = await _copyAsset(
//           'assets/hey-zizzle_en_ios_v3_0_0.ppn', 'hey_zizzle.ppn');
//       final String rhnPath = await _copyAsset(
//           'assets/Post_en_ios_v3_0_0.rhn', 'zizzle_commands.rhn');

//       // ✅ Wake-word always listening
//       _porcupineManager = await PorcupineManager.fromKeywordPaths(
//         "3qHo8Zv7eQ0Et8VBMlvl868sFRLifgPBivWvUcCSIPA8i21Ngd7R6w==",
//         [wakePath],
//         _onWakeWord,
//       );

//       // ✅ Rhino created but not running until wake word detected
//       _rhinoManager = await RhinoManager.create(
//         "3qHo8Zv7eQ0Et8VBMlvl868sFRLifgPBivWvUcCSIPA8i21Ngd7R6w==",
//         rhnPath,
//         _onInference,
//         sensitivity: 0.7,
//         endpointDurationSec: 2.5,
//         requireEndpoint: true,
//         processErrorCallback: (e) => print("Rhino error: $e"),
//       );

//       // ▶️ Start Porcupine (background mic)
//       await _porcupineManager?.start();
//       print('🎧 Wake-word listening started (mic + speaker enabled)');
//     } catch (e) {
//       print('Error initializing WakeWordService: $e');
//     }
//   }

//   Future<void> _configureAudioSession() async {
//     await Future.delayed(
//         const Duration(milliseconds: 300)); // wait for Flutter engine
//     final session = await AudioSession.instance;

//     final config = AudioSessionConfiguration(
//       avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
//       avAudioSessionCategoryOptions:
//           AVAudioSessionCategoryOptions.mixWithOthers |
//               AVAudioSessionCategoryOptions.defaultToSpeaker |
//               AVAudioSessionCategoryOptions.allowBluetooth |
//               AVAudioSessionCategoryOptions.allowBluetoothA2dp,
//       avAudioSessionMode: AVAudioSessionMode.voiceChat,
//       androidAudioAttributes: const AndroidAudioAttributes(
//         contentType: AndroidAudioContentType.speech,
//         usage: AndroidAudioUsage.voiceCommunication,
//       ),
//       androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
//       androidWillPauseWhenDucked: false,
//     );

//     await session.configure(config);

//     // Activate safely
//     try {
//       await session.setActive(true);
//       print("✅ Audio session activated");
//     } catch (e) {
//       print("❌ Audio session activation failed: $e");
//     }
//   }

//   Future<String> _copyAsset(String asset, String name) async {
//     final data = await rootBundle.load(asset);
//     final file =
//         File('${(await getApplicationDocumentsDirectory()).path}/$name');
//     await file.writeAsBytes(data.buffer.asUint8List());
//     return file.path;
//   }

//   /// 🎤 Wake word detected
//   void _onWakeWord(int index) async {
//     print('🎤 Wake word detected!');
//     isListening.value = true;

//     await _tts.speak("Yes? I'm listening");

//     await _porcupineManager?.stop(); // stop wake word temporarily

//     try {
//       await _rhinoManager?.process(); // mic fully on
//     } catch (e) {
//       print('Rhino process error: $e');
//       isListening.value = false;
//       await _porcupineManager?.start();
//     }
//   }

//   /// 🤖 Rhino inference complete
//   void _onInference(RhinoInference inference) async {
//     if (inference.isUnderstood == true) {
//       final intent = inference.intent!;
//       print('✅ Intent: $intent, slots: ${inference.slots}');
//       await _executeIntent(intent);
//     } else {
//       print('❌ Did not understand.');
//       await _tts.speak("Sorry, I didn't get that.");
//     }

//     isListening.value = false;

//     await _rhinoManager?.delete(); // mic off
//     _rhinoManager = await RhinoManager.create(
//       "3qHo8Zv7eQ0Et8VBMlvl868sFRLifgPBivWvUcCSIPA8i21Ngd7R6w==",
//       await _copyAsset('assets/Post_en_ios_v3_0_0.rhn', 'zizzle_commands.rhn'),
//       _onInference,
//     );

//     await _porcupineManager?.start(); // restart wake-word
//   }

//   Future<void> _executeIntent(String intent) async {
//     switch (intent) {
//       case 'Post_photo':
//         await _tts.speak("Opening Add Post screen");
//         _navigationservice.pushnamed("/postphoto");
//         break;
//       case 'Settings':
//         await _tts.speak("Opening Settings");
//         _navigationservice.pushReplacementname("/settings");
//         Future.delayed(const Duration(seconds: 2), () {
//           ProfileScreen.globalKey.currentState?.openSettingsIcon();
//         });
//         break;
//       default:
//         await _tts.speak("Command not recognized");
//     }
//   }

//   Future<void> _forceSpeaker() async {
//     try {
//       await _audioChannel.invokeMethod('forceSpeaker');
//       print("✅ Speaker forced successfully");
//     } on PlatformException catch (e) {
//       print("❌ Could not force speaker: $e");
//     }
//   }

//   Future<void> stop() async {
//     try {
//       // Stop Porcupine and delete it
//       if (_porcupineManager != null) {
//         await _porcupineManager!.stop();
//         await _porcupineManager!.delete();
//         _porcupineManager = null;
//       }

//       // Stop Rhino and delete it
//       if (_rhinoManager != null) {
//         await _rhinoManager!.delete();
//         _rhinoManager = null;
//       }

//       // Deactivate audio session (releases mic)
//       final session = await AudioSession.instance;
//       if (session != null) {
//         await session.setActive(false);
//       }

//       isListening.value = false;
//       print("✅ WakeWordService fully stopped, mic released");
//     } catch (e) {
//       print("❌ Error stopping WakeWordService: $e");
//     }
//   }
// }
