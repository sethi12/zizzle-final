import '/resources/firestore_reels_updation.dart';
import '/resources/updation_firestore.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'dart:io' as io;
import 'dart:async';

class Admanager {
  Future<void> loadintad() async {
    if (io.Platform.isAndroid) {
      await UnityAds.load(
        placementId: 'Interstitial_Android',
        onComplete: (placementId) => print('Load Complete $placementId'),
        onFailed: (placementId, error, message) =>
            print('Load Failed $placementId: $error $message'),
      );
    } else if (io.Platform.isIOS) {
      await UnityAds.load(
        placementId: 'Interstitial_iOS',
        onComplete: (placementId) => print('Load Complete $placementId'),
        onFailed: (placementId, error, message) =>
            print('Load Failed $placementId: $error $message'),
      );
    }
  }

  Future<void> showintad() async {
    if (io.Platform.isAndroid) {
      UnityAds.showVideoAd(
        placementId: 'Interstitial_Android',
        onStart: (placementId) {},
        onClick: (placementId) {},
        onSkipped: (placementId) {
          print("ad Skipped");
        },
        onComplete: (placementId) {},
        onFailed: (placementId, error, message) {
          loadintad();
          print(message);
          print(error);
        },
      );
    } else if (io.Platform.isIOS) {
      UnityAds.showVideoAd(
        placementId: 'Interstitial_iOS',
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) => print('Video Ad $placementId skipped'),
        onComplete: (placementId) => print('Video Ad $placementId completed'),
        onFailed: (placementId, error, message) {
          loadintad();
          print(message);
          print(error);
        },
      );
    }
  }

  Future<void> loadrewardedad() async {
    if (io.Platform.isAndroid) {
      await UnityAds.load(
        placementId: 'Rewarded_Android',
        onComplete: (placementId) => print('Load Complete $placementId'),
        onFailed: (placementId, error, message) =>
            print('Load Failed $placementId: $error $message'),
      );
    } else if (io.Platform.isIOS) {
      await UnityAds.load(
        placementId: 'Rewarded_iOS',
        onComplete: (placementId) => print('Load Complete $placementId'),
        onFailed: (placementId, error, message) =>
            print('Load Failed $placementId: $error $message'),
      );
    }
  }

  Future<void> showrewardedad(String docid) async {
    if (io.Platform.isAndroid) {
      UnityAds.showVideoAd(
        placementId: 'Rewarded_Android',
        onStart: (placementId) {},
        onClick: (placementId) {},
        onSkipped: (placementId) {
          print("ad Skipped");
          loadrewardedad();
        },
        onComplete: (placementId) {
          FirestoreUpdater().enableGlobalOption(docid);
          loadrewardedad();
        },
        onFailed: (placementId, error, message) {
          loadrewardedad();
          print(message);
          print(error);
        },
      );
    } else if (io.Platform.isIOS) {
      UnityAds.showVideoAd(
        placementId: 'Rewarded_iOS',
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) => loadrewardedad(),
        onComplete: (placementId) {
          FirestoreUpdater().enableGlobalOption(docid);
          loadrewardedad();
        },
        onFailed: (placementId, error, message) {
          loadrewardedad();
          print(message);
          print(error);
        },
      );
    }
  }

  Future<void> showrelrewardedad(String docid) async {
    if (io.Platform.isAndroid) {
      UnityAds.showVideoAd(
        placementId: 'Rewarded_Android',
        onStart: (placementId) {},
        onClick: (placementId) {},
        onSkipped: (placementId) {
          print("ad Skipped");
          loadrewardedad();
        },
        onComplete: (placementId) {
          FirestoreReelUpdater().enableGlobalOption(docid);
          print("Globaloptionenabled");
          loadrewardedad();
        },
        onFailed: (placementId, error, message) {
          loadrewardedad();
          print(message);
          print(error);
        },
      );
    } else if (io.Platform.isIOS) {
      UnityAds.showVideoAd(
        placementId: 'Rewarded_iOS',
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) {
          print("ad Skipped");
          loadrewardedad();
        },
        onComplete: (placementId) {
          FirestoreReelUpdater().enableGlobalOption(docid);
          print("Globaloptionenabled");
          loadrewardedad();
        },
        onFailed: (placementId, error, message) {
          loadrewardedad();
          print(message);
          print(error);
        },
      );
    }
  }
}
