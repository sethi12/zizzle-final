// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart';
// import 'package:get/get.dart';

// class Democontroller extends GetxController {
//   final PageController pageController = PageController();
//   final RxList<DocumentSnapshot> videos = <DocumentSnapshot>[].obs;
//   final RxList<VideoPlayerController> controllers =
//       <VideoPlayerController>[].obs;
//   final RxList<int> likes = <int>[].obs;
//   final RxSet<int> likedIndexes = <int>{}.obs;
//   final RxInt currentIndex = 0.obs;
//   final RxSet<int> allowedIndexes = <int>{}.obs;

//   final String _lastIndexKey = 'last_watched_index';
//   DocumentSnapshot? lastDoc;
//   bool isLoading = false;
//   Timer? _viewTimer;
//   final Set<String> viewedReels = {};
//   final audioPlayer = AudioPlayer();
//   StreamSubscription<Duration>? _audioLoopSub;
//   StreamSubscription<QuerySnapshot>? _newReelsSub;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchVideos();
//   }

//   Future<void> saveLastWatchedIndex(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_lastIndexKey, index);
//   }

//   Future<int?> getLastWatchedIndex() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt(_lastIndexKey);
//   }

//   void pauseAllVideos() {
//     for (var controller in controllers) {
//       if (controller.value.isPlaying) {
//         controller.pause();
//       }
//     }
//   }

//   void onPageChanged(int index) async {
//     if (index == currentIndex.value) return;

//     controllers[currentIndex.value].pause();
//     currentIndex.value = index;

//     await saveLastWatchedIndex(index);

//     controllers[index].play();
//     manageVideoMemory(index);

//     final currentDoc = videos[index].data() as Map<String, dynamic>;
//     final hasOriginalSong =
//         currentDoc['orignalsongurl']?.toString().isNotEmpty ?? false;

//     if (hasOriginalSong) {
//       final int? start = currentDoc['startAudioDuration'];
//       final int? end = currentDoc['endAudioDuration'];
//       controllers[index].seekTo(Duration.zero);
//       controllers[index].setVolume(0.0);
//       await _playOriginalAudio(
//         currentDoc['orignalsongurl'],
//         startAudioDuration: start,
//         endAudioDuration: end,
//       );
//     } else {
//       await _audioLoopSub?.cancel();
//       await audioPlayer.stop();
//       controllers[index].setVolume(1.0);
//     }

//     _startViewTracking(controllers[index], videos[index].id);
//     _preCacheNextVideos(index);

//     if (index >= controllers.length - 2) {
//       fetchMoreVideos();
//     }
//   }

//   Future<void> fetchVideos() async {
//     if (isLoading) return;
//     isLoading = true;

//     final query = FirebaseFirestore.instance
//         .collection('reels')
//         .where('Audience', isEqualTo: "Public")
//         .where('Archive', isEqualTo: false)
//         .orderBy(FieldPath.documentId)
//         .limit(10);
//     final snapshot = await query.get();

//     await _addVideos(snapshot.docs);
//     lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
//     isLoading = false;

//     final lastIndex = await getLastWatchedIndex();
//     if (lastIndex != null && lastIndex < controllers.length) {
//       currentIndex.value = lastIndex;
//       pageController.jumpToPage(lastIndex);
//       controllers[lastIndex].play();
//       onPageChanged(lastIndex);
//     }
//   }

//   Future<void> fetchMoreVideos() async {
//     if (isLoading || lastDoc == null) return;
//     isLoading = true;

//     final snapshot = await FirebaseFirestore.instance
//         .collection('reels')
//         .where('Audience', isEqualTo: "Public")
//         .where('Archive', isEqualTo: false)
//         .orderBy(FieldPath.documentId)
//         .startAfterDocument(lastDoc!)
//         .limit(10)
//         .get();

//     await _addVideos(snapshot.docs);
//     lastDoc = snapshot.docs.last;
//     isLoading = false;
//   }

//   Future<void> _addVideos(List<DocumentSnapshot> docs) async {
//     for (var doc in docs) {
//       await _initializeAndAddVideo(doc);
//     }
//   }

//   Future<void> _initializeAndAddVideo(DocumentSnapshot doc) async {
//     try {
//       final data = doc.data() as Map<String, dynamic>;
//       final url = data['videourl'];
//       final file = await DefaultCacheManager().getSingleFile(url);
//       final controller = VideoPlayerController.file(file);
//       await controller.initialize();
//       controller.setLooping(true);

//       final hasOriginalSong =
//           data['orignalsongurl']?.toString().isNotEmpty ?? false;
//       controller.setVolume(hasOriginalSong ? 0.0 : 1.0);

//       controllers.add(controller);
//       videos.add(doc);
//       likes.add(data['likes'] ?? 0);
//     } catch (e) {
//       print("❌ Error loading video: $e");
//     }
//   }

//   void manageVideoMemory(int index) {
//     if (!Platform.isAndroid) return;

//     allowedIndexes.clear();
//     allowedIndexes.add(index);
//     if (index > 0) allowedIndexes.add(index - 1);
//     if (index + 1 < controllers.length) allowedIndexes.add(index + 1);

//     for (int i = 0; i < controllers.length; i++) {
//       if (!allowedIndexes.contains(i)) {
//         try {
//           controllers[i].dispose();
//           controllers[i] = VideoPlayerController.network('');
//         } catch (e) {
//           print("Error disposing $i: $e");
//         }
//       } else if (!controllers[i].value.isInitialized && videos.length > i) {
//         _reInitializeVideo(i);
//       }
//     }
//   }

//   Future<void> _reInitializeVideo(int index) async {
//     try {
//       final data = videos[index].data() as Map<String, dynamic>;
//       final url = data['videourl'];
//       final file = await DefaultCacheManager().getSingleFile(url);
//       final controller = VideoPlayerController.file(file);
//       await controller.initialize();
//       controller.setLooping(true);

//       final hasOriginalSong =
//           data['orignalsongurl']?.toString().isNotEmpty ?? false;
//       controller.setVolume(hasOriginalSong ? 0.0 : 1.0);

//       controllers[index] = controller;
//     } catch (e) {
//       print("❌ Error reinitializing controller: $e");
//     }
//   }

//   void _preCacheNextVideos(int currentIndex) {
//     for (int i = currentIndex + 1;
//         i <= currentIndex + 3 && i < videos.length;
//         i++) {
//       final data = videos[i].data() as Map<String, dynamic>;
//       final url = data['videourl'];
//       DefaultCacheManager().downloadFile(url);
//     }
//   }

//   void _startViewTracking(VideoPlayerController controller, String reelId) {
//     _viewTimer?.cancel();
//     int secondsWatched = 0;

//     _viewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (controller.value.isPlaying) {
//         secondsWatched++;
//         if (secondsWatched >= 8 && !viewedReels.contains(reelId)) {
//           _incrementView(reelId);
//           viewedReels.add(reelId);
//           timer.cancel();
//         }
//       }
//     });
//   }

//   void _incrementView(String reelId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('reels')
//           .doc(reelId)
//           .update({'views': FieldValue.increment(1)});
//     } catch (e) {
//       print('Error incrementing view: $e');
//     }
//   }

//   Future<void> _playOriginalAudio(String url,
//       {int? startAudioDuration, int? endAudioDuration}) async {
//     try {
//       await _audioLoopSub?.cancel();
//       await audioPlayer.stop();
//       await audioPlayer.setLoopMode(LoopMode.off);
//       await audioPlayer.setUrl(url);

//       final start = Duration(seconds: startAudioDuration ?? 0);
//       final end = Duration(
//           seconds:
//               endAudioDuration ?? (audioPlayer.duration?.inSeconds ?? 999));
//       await audioPlayer.seek(start);
//       await audioPlayer.play();

//       _audioLoopSub = audioPlayer.positionStream.listen((position) async {
//         if (position >= end) {
//           await audioPlayer.seek(start);
//           await audioPlayer.play();
//         }
//       });
//     } catch (e) {
//       print("❌ Error playing trimmed audio: $e");
//     }
//   }

//   @override
//   void onClose() {
//     _newReelsSub?.cancel();
//     for (var c in controllers) {
//       c.dispose();
//     }
//     _audioLoopSub?.cancel();
//     audioPlayer.dispose();
//     _viewTimer?.cancel();
//     super.onClose();
//   }
// }
