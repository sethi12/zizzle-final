import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/ads/ads_manager.dart';
import '/widgets/Video_player.dart';
import 'dart:async';
import '../model/reel.dart';

class VideoController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final RxList<Video> _videoList = RxList<Video>();

  List<Video> get videolist => _videoList;
  RxList<Video> get videoListStream => _videoList;
  bool _videosLoaded = false;

  bool get videosLoaded => _videosLoaded;

  @override
  void onInit() {
    super.onInit();
    _videoList.bindStream(_firestore
        .collection("reels")
        .where('Audience', isEqualTo: "Public")
        .snapshots()
        .map((QuerySnapshot query) {
      List<Video> retval = [];
      for (var element in query.docs) {
        retval.add(Video.fromSnap(element));
      }
      return retval;
    }));

    // Preload videos
    //   preloadVideos();
  }

  Future<void> preloadVideos() async {
    for (var video in _videoList) {
      await video.initializeController();
    }
    _videosLoaded = true;
    update(); // Notify listeners that videos are loaded
  }
}
