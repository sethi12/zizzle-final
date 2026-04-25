import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ReelsController extends GetxController {
  final PageController pageController = PageController();
  final RxList<DocumentSnapshot> videos = <DocumentSnapshot>[].obs;
  final RxList<VideoPlayerController> controllers =
      <VideoPlayerController>[].obs;
  final RxList<int> likes = <int>[].obs;
  final RxSet<int> likedIndexes = <int>{}.obs;
  final RxInt currentIndex = 0.obs;
  DocumentSnapshot? lastDoc;
  final int batchSize = 10;
  bool isLoading = false;
  Timer? _viewTimer;
  final Set<String> viewedReels = {}; // To avoid duplicate view count
  final audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _audioLoopSub;
  // ✅ Getter to access current video document
  StreamSubscription<QuerySnapshot>? _newReelsSub;
  final RxSet<int> allowedIndexes = <int>{}.obs;
  DocumentSnapshot get currentVideo =>
      videos.isNotEmpty ? videos[currentIndex.value] : null as DocumentSnapshot;

  @override
  void onInit() {
    super.onInit();
    // fetchVideos();
  }

  void pauseAllVideos() {
    for (var controller in controllers) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void stopListeningForNewReels() {
    _newReelsSub?.cancel();
    _newReelsSub = null;
  }

  void startListeningForNewReels() {
    _newReelsSub?.cancel(); // Cancel if already listening
    print("started listening");
    _newReelsSub = FirebaseFirestore.instance
        .collection('reels')
        .where('Audience', isEqualTo: "Public")
        .where('Archive', isEqualTo: false)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .listen((snapshot) {
      final newDocs = snapshot.docChanges
          .where((change) => change.type == DocumentChangeType.added)
          .map((change) => change.doc)
          .where(
              (doc) => !videos.any((v) => v.id == doc.id)) // Avoid duplicates
          .toList();

      if (newDocs.isNotEmpty) {
        print("📢 New reel(s) arrived: ${newDocs.length}");
        _addVideos(newDocs); // 👈 Adds at the END by default
      }
    });
  }

  void _startViewTracking(VideoPlayerController controller, String reelId) {
    _viewTimer?.cancel(); // Cancel any existing timers

    int secondsWatched = 0;

    _viewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (controller.value.isPlaying) {
        secondsWatched++;

        if (secondsWatched >= 8 && !viewedReels.contains(reelId)) {
          _incrementView(reelId);
          viewedReels.add(reelId);
          timer.cancel(); // Stop the timer after 1 view increment
        }
      }
    });
  }

  void _incrementView(String reelId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reels')
          .doc(reelId)
          .update({'views': FieldValue.increment(1)});
      print('✅ View incremented for $reelId');
    } catch (e) {
      print('❌ Error incrementing view: $e');
    }
  }

  Future<void> fetchVideos() async {
    if (isLoading) return;
    isLoading = true;

    final query = await FirebaseFirestore.instance
        .collection('reels')
        .where('Audience', isEqualTo: "Public")
        .where('Archive', isEqualTo: false)
        .orderBy(FieldPath.documentId)
        .limit(batchSize);
    final snapshot = await query.get();

    await _addVideos(snapshot.docs);
    lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    isLoading = false;
    // startListeningForNewReels();
  }

  Future<void> fetchMoreVideos() async {
    if (isLoading || lastDoc == null) return;
    isLoading = true;

    final snapshot = await FirebaseFirestore.instance
        .collection('reels')
        .where('Audience', isEqualTo: "Public")
        .where('Archive', isEqualTo: false)
        .orderBy(FieldPath.documentId)
        .startAfterDocument(lastDoc!)
        .limit(batchSize)
        .get();

    await _addVideos(snapshot.docs);
    lastDoc = snapshot.docs.last;

    isLoading = false;
  }

  Future<void> _addVideos(List<DocumentSnapshot> docs) async {
    for (var doc in docs) {
      await _initializeAndAddVideo(doc); // Don't await, run in background
    }
  }

  Future<void> _initializeAndAddVideo(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final url = data['videourl'];

      final fileInfo = await DefaultCacheManager().getSingleFile(url);
      final controller = VideoPlayerController.file(fileInfo);

      await controller.initialize();
      final hasOriginalSong =
          data['orignalsongurl']?.toString().isNotEmpty ?? false;
      controller.setVolume(hasOriginalSong ? 0.0 : 1.0);
      controller.setLooping(true);

      controllers.add(controller);
      videos.add(doc);
      likes.add(data['likes'] ?? 0);
    } catch (e) {
      print("❌ Error loading video: $e");
    }
  }

  Future<void> _playOriginalAudio(
    String url, {
    int? startAudioDuration,
    int? endAudioDuration,
  }) async {
    try {
      await _audioLoopSub?.cancel();
      await audioPlayer.stop();
      await audioPlayer.setLoopMode(LoopMode.off);
      await audioPlayer.setUrl(url);

      final start = Duration(seconds: startAudioDuration ?? 0);
      final end = Duration(
          seconds:
              endAudioDuration ?? (audioPlayer.duration?.inSeconds ?? 999));

      await audioPlayer.seek(start);
      await audioPlayer.play();

      _audioLoopSub = audioPlayer.positionStream.listen((position) async {
        if (position >= end) {
          await audioPlayer.seek(start);
          await audioPlayer.play();
        }
      });
    } catch (e) {
      print("❌ Error playing trimmed audio: $e");
    }
  }

  void toggleLike(int index) {
    if (likedIndexes.contains(index)) {
      likes[index]--;
      likedIndexes.remove(index);
    } else {
      likes[index]++;
      likedIndexes.add(index);
    }
  }

  void _preCacheNextVideos(int currentIndex) {
    for (int i = currentIndex + 1;
        i <= currentIndex + 3 && i < videos.length;
        i++) {
      final data = videos[i].data() as Map<String, dynamic>;
      final url = data['videourl'];
      DefaultCacheManager().downloadFile(url); // silently pre-cache
    }
  }

  void onPageChanged(int index) async {
    if (index == currentIndex.value) return;
    _preCacheNextVideos(index);

    // Pause current video
    controllers[currentIndex.value].pause();

    currentIndex.value = index;

    // Play new video
    controllers[index].play();
    manageVideoMemory(index);

    final currentDoc = videos[index].data() as Map<String, dynamic>;
    final hasOriginalSong =
        currentDoc['orignalsongurl']?.toString().isNotEmpty ?? false;

    if (hasOriginalSong) {
      final int? start = currentDoc['startAudioDuration'];
      final int? end = currentDoc['endAudioDuration'];

      controllers[index].seekTo(Duration.zero);
      controllers[index].setVolume(0.0); // mute
      await _playOriginalAudio(
        currentDoc['orignalsongurl'],
        startAudioDuration: start,
        endAudioDuration: end,
      );
    } else {
      await _audioLoopSub?.cancel();
      await audioPlayer.stop();
      controllers[index].setVolume(1.0); // unmute
    }

    // View tracking
    final reelId = videos[index].id;
    _startViewTracking(controllers[index], reelId);

    // Pre-fetch
    if (index >= controllers.length - 2) {
      fetchMoreVideos();
    }
  }

  @override
  void onClose() {
    _newReelsSub?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    _audioLoopSub?.cancel();
    audioPlayer.dispose();
    _viewTimer?.cancel();
    super.onClose();
  }

  void manageVideoMemory(int index) async {
    allowedIndexes.clear();
    allowedIndexes.add(index);
    if (index > 0) allowedIndexes.add(index - 1);
    if (index + 1 < controllers.length) allowedIndexes.add(index + 1);

    for (int i = 0; i < controllers.length; i++) {
      if (!allowedIndexes.contains(i)) {
        try {
          if (controllers[i].value.isInitialized) {
            controllers[i].dispose();
            controllers[i] =
                VideoPlayerController.network(''); // Dummy controller
          }
        } catch (e) {
          print("Error disposing controller at $i: $e");
        }
      } else if (!controllers[i].value.isInitialized && videos.length > i) {
        await _reInitializeVideo(i);
      }
    }
  }

  Future<void> _reInitializeVideo(int index) async {
    try {
      final data = videos[index].data() as Map<String, dynamic>;
      final url = data['videourl'];
      final file = await DefaultCacheManager().getSingleFile(url);

      final controller = VideoPlayerController.file(file);
      await controller.initialize();

      final hasOriginalSong =
          data['orignalsongurl']?.toString().isNotEmpty ?? false;
      controller.setVolume(hasOriginalSong ? 0.0 : 1.0);
      controller.setLooping(true);

      controllers[index] = controller;
      print("✅ Re-initialized controller at index $index");
    } catch (e) {
      print("❌ Error reinitializing controller at $index: $e");
    }
  }
}
