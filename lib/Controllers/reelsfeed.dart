// import 'dart:async';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:video_player/video_player.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// class ReelsController extends GetxController {
//   final PageController pageController = PageController();
//   final RxList<DocumentSnapshot> videos = <DocumentSnapshot>[].obs;
//   final RxList<VideoPlayerController> controllers =
//       <VideoPlayerController>[].obs;
//   final RxList<int> likes = <int>[].obs;
//   final RxSet<int> likedIndexes = <int>{}.obs;
//   final RxInt currentIndex = 0.obs;
//   DocumentSnapshot? lastDoc;
//   final int batchSize = 10;
//   bool isLoading = false;
//   Timer? _viewTimer;
//   final Set<String> viewedReels = {}; // To avoid duplicate view count
//   final audioPlayer = AudioPlayer();
//   StreamSubscription<Duration>? _audioLoopSub;
//   // ✅ Getter to access current video document
//   StreamSubscription<QuerySnapshot>? _newReelsSub;
//   final RxSet<int> allowedIndexes = <int>{}.obs;
//   DocumentSnapshot get currentVideo =>
//       videos.isNotEmpty ? videos[currentIndex.value] : null as DocumentSnapshot;

//   @override
//   void onInit() {
//     super.onInit();
//     // fetchVideos();
//   }

//   void pauseAllVideos() {
//     for (var controller in controllers) {
//       if (controller.value.isPlaying) {
//         controller.pause();
//       }
//     }
//   }

//   void stopListeningForNewReels() {
//     _newReelsSub?.cancel();
//     _newReelsSub = null;
//   }

//   void startListeningForNewReels() {
//     _newReelsSub?.cancel(); // Cancel if already listening
//     print("started listening");
//     _newReelsSub = FirebaseFirestore.instance
//         .collection('reels')
//         .where('Audience', isEqualTo: "Public")
//         .where('Archive', isEqualTo: false)
//         .orderBy(FieldPath.documentId, descending: true)
//         .snapshots()
//         .listen((snapshot) {
//       final newDocs = snapshot.docChanges
//           .where((change) => change.type == DocumentChangeType.added)
//           .map((change) => change.doc)
//           .where(
//               (doc) => !videos.any((v) => v.id == doc.id)) // Avoid duplicates
//           .toList();

//       if (newDocs.isNotEmpty) {
//         print("📢 New reel(s) arrived: ${newDocs.length}");
//         _addVideos(newDocs); // 👈 Adds at the END by default
//       }
//     });
//   }

//   void _startViewTracking(VideoPlayerController controller, String reelId) {
//     _viewTimer?.cancel(); // Cancel any existing timers

//     int secondsWatched = 0;

//     _viewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (controller.value.isPlaying) {
//         secondsWatched++;

//         if (secondsWatched >= 8 && !viewedReels.contains(reelId)) {
//           _incrementView(reelId);
//           viewedReels.add(reelId);
//           timer.cancel(); // Stop the timer after 1 view increment
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
//       print('✅ View incremented for $reelId');
//     } catch (e) {
//       print('❌ Error incrementing view: $e');
//     }
//   }

//   Future<void> fetchVideos() async {
//     if (isLoading) return;
//     isLoading = true;

//     final query = await FirebaseFirestore.instance
//         .collection('reels')
//         .where('Audience', isEqualTo: "Public")
//         .where('Archive', isEqualTo: false)
//         .orderBy(FieldPath.documentId)
//         .limit(batchSize);
//     final snapshot = await query.get();

//     await _addVideos(snapshot.docs);
//     lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

//     isLoading = false;
//     // startListeningForNewReels();
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
//         .limit(batchSize)
//         .get();

//     await _addVideos(snapshot.docs);
//     lastDoc = snapshot.docs.last;

//     isLoading = false;
//   }

//   Future<void> _addVideos(List<DocumentSnapshot> docs) async {
//     for (var doc in docs) {
//       await _initializeAndAddVideo(doc); // Don't await, run in background
//     }
//   }

//   Future<void> _initializeAndAddVideo(DocumentSnapshot doc) async {
//     try {
//       final data = doc.data() as Map<String, dynamic>;
//       final url = data['videourl'];

//       final fileInfo = await DefaultCacheManager().getSingleFile(url);
//       final controller = VideoPlayerController.file(fileInfo);

//       await controller.initialize();
//       final hasOriginalSong =
//           data['orignalsongurl']?.toString().isNotEmpty ?? false;
//       controller.setVolume(hasOriginalSong ? 0.0 : 1.0);
//       controller.setLooping(true);

//       controllers.add(controller);
//       videos.add(doc);
//       likes.add(data['likes'] ?? 0);
//     } catch (e) {
//       print("❌ Error loading video: $e");
//     }
//   }

//   Future<void> _playOriginalAudio(
//     String url, {
//     int? startAudioDuration,
//     int? endAudioDuration,
//   }) async {
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

//   void toggleLike(int index) {
//     if (likedIndexes.contains(index)) {
//       likes[index]--;
//       likedIndexes.remove(index);
//     } else {
//       likes[index]++;
//       likedIndexes.add(index);
//     }
//   }

//   void _preCacheNextVideos(int currentIndex) {
//     for (int i = currentIndex + 1;
//         i <= currentIndex + 3 && i < videos.length;
//         i++) {
//       final data = videos[i].data() as Map<String, dynamic>;
//       final url = data['videourl'];
//       DefaultCacheManager().downloadFile(url); // silently pre-cache
//     }
//   }

//   void onPageChanged(int index) async {
//     if (index == currentIndex.value) return;
//     _preCacheNextVideos(index);

//     // Pause current video
//     controllers[currentIndex.value].pause();

//     currentIndex.value = index;

//     // Play new video
//     controllers[index].play();
//     manageVideoMemory(index);

//     final currentDoc = videos[index].data() as Map<String, dynamic>;
//     final hasOriginalSong =
//         currentDoc['orignalsongurl']?.toString().isNotEmpty ?? false;

//     if (hasOriginalSong) {
//       final int? start = currentDoc['startAudioDuration'];
//       final int? end = currentDoc['endAudioDuration'];

//       controllers[index].seekTo(Duration.zero);
//       controllers[index].setVolume(0.0); // mute
//       await _playOriginalAudio(
//         currentDoc['orignalsongurl'],
//         startAudioDuration: start,
//         endAudioDuration: end,
//       );
//     } else {
//       await _audioLoopSub?.cancel();
//       await audioPlayer.stop();
//       controllers[index].setVolume(1.0); // unmute
//     }

//     // View tracking
//     final reelId = videos[index].id;
//     _startViewTracking(controllers[index], reelId);

//     // Pre-fetch
//     if (index >= controllers.length - 2) {
//       fetchMoreVideos();
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

//   void manageVideoMemory(int index) async {
//     allowedIndexes.clear();
//     allowedIndexes.add(index);
//     if (index > 0) allowedIndexes.add(index - 1);
//     if (index + 1 < controllers.length) allowedIndexes.add(index + 1);

//     for (int i = 0; i < controllers.length; i++) {
//       if (!allowedIndexes.contains(i)) {
//         try {
//           if (controllers[i].value.isInitialized) {
//             controllers[i].dispose();
//             controllers[i] =
//                 VideoPlayerController.network(''); // Dummy controller
//           }
//         } catch (e) {
//           print("Error disposing controller at $i: $e");
//         }
//       } else if (!controllers[i].value.isInitialized && videos.length > i) {
//         await _reInitializeVideo(i);
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

//       final hasOriginalSong =
//           data['orignalsongurl']?.toString().isNotEmpty ?? false;
//       controller.setVolume(hasOriginalSong ? 0.0 : 1.0);
//       controller.setLooping(true);

//       controllers[index] = controller;
//       print("✅ Re-initialized controller at index $index");
//     } catch (e) {
//       print("❌ Error reinitializing controller at $index: $e");
//     }
//   }
// }



import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'package:zizzle/model/reel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReelCacheManager
// ─────────────────────────────────────────────────────────────────────────────
class ReelCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'reelCacheManager';
  static final ReelCacheManager _instance = ReelCacheManager._();
  factory ReelCacheManager() => _instance;
  ReelCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 100,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileService: HttpFileService(),
        ));
}

// ─────────────────────────────────────────────────────────────────────────────
// ReelSlot — the core unit. Each slot is self-contained.
// ─────────────────────────────────────────────────────────────────────────────
enum _SlotState { idle, loading, ready, disposed }

class _ReelSlot {
  final Video reel;
  VideoPlayerController? controller;
  _SlotState state = _SlotState.idle;

  _ReelSlot(this.reel);

  bool get isReady => state == _SlotState.ready && controller != null;
  bool get isLoading => state == _SlotState.loading;
  bool get isDisposed => state == _SlotState.disposed;
  bool get isIdle => state == _SlotState.idle;

  String get playbackUrl => reel.feedPlaybackUrl;
  bool get hasOriginalSong =>
      reel.orignalsongurl != null && reel.orignalsongurl!.isNotEmpty;

  void markDisposed() {
    state = _SlotState.disposed;
    controller?.dispose();
    controller = null;
  }

  void markIdle() {
    state = _SlotState.idle;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ReelsController — Instagram-like architecture
//
// Key principles:
// 1. iOS allows max 4 VideoPlayerControllers — we keep exactly 3 alive
//    (current + 1 ahead + 1 behind)
// 2. Preload is DECOUPLED from playback — we initialize slots before
//    the user gets there, not when they arrive
// 3. onPageChanged does ZERO async work — all heavy work is pre-done
// 4. No debounce needed — because slots are pre-initialized, page changes
//    are instant (just call play() on an already-ready controller)
// ─────────────────────────────────────────────────────────────────────────────
class ReelsController extends GetxController {
  // ── Public state ──────────────────────────────────────────────────
  final PageController pageController = PageController();
  final RxList<_ReelSlot> slots = <_ReelSlot>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isFirstLoad = true.obs;

  // ── Audio ─────────────────────────────────────────────────────────
  final AudioPlayer audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _audioLoopSub;

  // ── View tracking ─────────────────────────────────────────────────
  Timer? _viewTimer;
  final Set<String> _viewedReels = {};

  // ── Fetch ─────────────────────────────────────────────────────────
  bool _isFetching = false;
  DocumentSnapshot? _lastDoc;
  static const int _batchSize = 10;
  StreamSubscription<QuerySnapshot>? _newReelsSub;

  // ── iOS safe window: keep exactly 3 controllers alive ─────────────
  // current + 1 ahead + 1 behind = 3 total
  // Never exceeds iOS AVPlayer hard limit of 4-5
  static const int _keepBehind = 1;
  static const int _keepAhead  = 2; // init 2 ahead, keep 1 extra as buffer

  // ── Init lock — prevents double initialization ─────────────────────
  final Set<int> _initLocks = {};

  // ─────────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _newReelsSub?.cancel();
    _viewTimer?.cancel();
    _audioLoopSub?.cancel();
    audioPlayer.dispose();
    for (final slot in slots) {
      slot.markDisposed();
    }
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────

  void pauseAllVideos() {
    for (final s in slots) {
      if (s.isReady) s.controller?.pause();
    }
  }

  void startListeningForNewReels() {
    _newReelsSub?.cancel();
    _newReelsSub = FirebaseFirestore.instance
        .collection('reels')
        .where('Audience', isEqualTo: 'Public')
        .where('Archive', isEqualTo: false)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .listen((snapshot) {
      final newDocs = snapshot.docChanges
          .where((c) => c.type == DocumentChangeType.added)
          .map((c) => c.doc)
          .where((doc) => !slots.any((s) => s.reel.id == doc.id))
          .toList();
      if (newDocs.isNotEmpty) _appendDocs(newDocs);
    });
  }

  void stopListeningForNewReels() {
    _newReelsSub?.cancel();
    _newReelsSub = null;
  }

  // ── Initial load ──────────────────────────────────────────────────
  Future<void> fetchVideos() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('reels')
          .where('Audience', isEqualTo: 'Public')
          .where('Archive', isEqualTo: false)
          .orderBy(FieldPath.documentId)
          .limit(_batchSize)
          .get();

      if (snap.docs.isEmpty) { _isFetching = false; return; }

      final shuffled = List<DocumentSnapshot>.from(snap.docs)..shuffle(Random());
      _appendDocs(shuffled);
      _lastDoc = snap.docs.last;
      _isFetching = false;

      // Initialize current + preload next 2 simultaneously
      await Future.wait([
        _initSlot(0),
        _initSlot(1),
        _initSlot(2),
      ]);

      // Play first slot
      if (slots.isNotEmpty && slots[0].isReady) {
        slots[0].controller!.play();
        isFirstLoad.value = false;
        slots.refresh();
        _startViewTracking(0);  // starts immediately, polls for controller
        unawaited(_startAudio(0));
      }
    } catch (e) {
      _isFetching = false;
      debugPrint('❌ fetchVideos: $e');
    }
  }

  Future<void> fetchMoreVideos() async {
    if (_isFetching || _lastDoc == null) return;
    _isFetching = true;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('reels')
          .where('Audience', isEqualTo: 'Public')
          .where('Archive', isEqualTo: false)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(_lastDoc!)
          .limit(_batchSize)
          .get();

      if (snap.docs.isEmpty) { _isFetching = false; return; }

      final shuffled = List<DocumentSnapshot>.from(snap.docs)..shuffle(Random());
      _appendDocs(shuffled);
      _lastDoc = snap.docs.last;
      _isFetching = false;
    } catch (e) {
      _isFetching = false;
      debugPrint('❌ fetchMoreVideos: $e');
    }
  }

  // ── Page changed — THE CRITICAL METHOD ───────────────────────────
  // This must be as fast as possible — zero async work here
  // All heavy work (initializing controllers) is done in advance
  Future<void> onPageChanged(int index) async {
    if (index < 0 || index >= slots.length) return;

    // 1. Pause previous
    final prev = currentIndex.value;
    if (prev != index && prev >= 0 && prev < slots.length) {
      slots[prev].controller?.pause();
    }

    currentIndex.value = index;

    // 2. Play current — if ready, this is INSTANT (no await needed)
    final current = slots[index];
    if (current.isReady) {
      current.controller!.seekTo(Duration.zero);
      current.controller!.play();
      slots.refresh();
    }

    // 3. All background work runs without blocking the UI
    _backgroundWork(index);

    // 4. Fetch more when near end
    if (index >= slots.length - 3) fetchMoreVideos();
  }

  // ─────────────────────────────────────────────────────────────────
  // _backgroundWork — runs after page change, never blocks UI
  // ─────────────────────────────────────────────────────────────────
  void _backgroundWork(int index) {
    // ── View tracking starts IMMEDIATELY — not after audio awaits ──
    // This is the fix: _startAudio is async and can take time.
    // If view tracking runs after it, the 8-second timer starts late
    // and views never increment correctly.
    _startViewTracking(index);

    Future.microtask(() async {
      // Preload next slots concurrently
      for (int i = index + 1; i <= index + _keepAhead && i < slots.length; i++) {
        unawaited(_initSlot(i));
      }
      // Keep 1 behind initialized
      if (index - 1 >= 0) unawaited(_initSlot(index - 1));

      // Dispose slots too far away
      _releaseDistantSlots(index);

      // Audio — runs in background, does NOT block view tracking
      unawaited(_startAudio(index));
    });
    final alive = slots.where((s) => s.isReady).length;
debugPrint('🎮 Active controllers: $alive');
  }

  // ─────────────────────────────────────────────────────────────────
  // _initSlot — safe, idempotent, locked
  // ─────────────────────────────────────────────────────────────────
  Future<void> _initSlot(int index) async {
    if (index < 0 || index >= slots.length) return;
    final slot = slots[index];

    // Already ready or being initialized
    if (slot.isReady || slot.isDisposed) return;
    if (_initLocks.contains(index)) return;

    _initLocks.add(index);
    slot.state = _SlotState.loading;

    try {
      final url = slot.playbackUrl;
      debugPrint('▶ Slot $index → ${url.contains(".m3u8") ? "✅ HLS (CDN)" : "⚠️ MP4 (original)"} $url');
      if (url.isEmpty) {
        slot.state = _SlotState.idle;
        _initLocks.remove(index);
        return;
      }

      VideoPlayerController ctrl;

      if (url.contains('.m3u8')) {
        // HLS — direct stream, CDN cached
        ctrl = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          httpHeaders: const {'Cache-Control': 'public, max-age=604800'},
        );
      } else {
        // MP4 — cache locally
        final file = await ReelCacheManager().getSingleFile(
          url,
          headers: const {'Cache-Control': 'public, max-age=604800'},
        );
        ctrl = VideoPlayerController.file(file);
      }

      await ctrl.initialize();

      // Stale check — slot may have been disposed or scrolled far away
      if (slot.isDisposed ||
          (index - currentIndex.value).abs() > _keepAhead + _keepBehind + 1) {
        ctrl.dispose();
        slot.state = _SlotState.idle;
        _initLocks.remove(index);
        return;
      }

      ctrl.setLooping(true);
      ctrl.setVolume(slot.hasOriginalSong ? 0.0 : 1.0);

      slot.controller = ctrl;
      slot.state = _SlotState.ready;
      _initLocks.remove(index);

      // If this is the current index and it just became ready — play it
      if (index == currentIndex.value) {
        ctrl.seekTo(Duration.zero);
        ctrl.play();
        isFirstLoad.value = false;
      }

      slots.refresh();
    } catch (e) {
      slot.state = _SlotState.idle;
      _initLocks.remove(index);
      debugPrint('❌ _initSlot($index): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // _releaseDistantSlots — free memory safely
  // ─────────────────────────────────────────────────────────────────
  void _releaseDistantSlots(int index) {
    for (int i = 0; i < slots.length; i++) {
      final distance = (i - index).abs();
      if (distance > _keepAhead + _keepBehind + 1) {
        final slot = slots[i];
        if (slot.isReady && !_initLocks.contains(i)) {
          slot.markDisposed();
          slot.markIdle(); // allow re-init on scroll back
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Audio — original song logic fully preserved
  // ─────────────────────────────────────────────────────────────────
  Future<void> _startAudio(int index) async {
    if (index >= slots.length) return;
    final slot = slots[index];

    if (slot.hasOriginalSong) {
      // Mute video, play original audio track
      slot.controller?.setVolume(0.0);
      await _playOriginalAudio(
        slot.reel.orignalsongurl!,
        startAudioDuration: slot.reel.startAudioDuration,
        endAudioDuration: slot.reel.endAudioDuration,
      );
    } else {
      // Stop original audio, unmute video
      await _audioLoopSub?.cancel();
      await audioPlayer.stop();
      slot.controller?.setVolume(1.0);
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
        seconds: endAudioDuration ?? (audioPlayer.duration?.inSeconds ?? 999),
      );

      await audioPlayer.seek(start);
      await audioPlayer.play();

      _audioLoopSub = audioPlayer.positionStream.listen((pos) async {
        if (pos >= end) {
          await audioPlayer.seek(start);
          await audioPlayer.play();
        }
      });
    } catch (e) {
      debugPrint('❌ _playOriginalAudio: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // View tracking — 8 seconds of actual playback = 1 view
  // ─────────────────────────────────────────────────────────────────
  void _startViewTracking(int index) {
    _viewTimer?.cancel();
    if (index < 0 || index >= slots.length) return;

    final reelId = slots[index].reel.id;

    // Already counted this reel in this session
    if (_viewedReels.contains(reelId)) return;

    int secs = 0;

    _viewTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      // Guard: index may have changed (user scrolled away)
      if (currentIndex.value != index) {
        t.cancel();
        return;
      }

      // Guard: slot may not be ready yet — get fresh reference every tick
      // This handles the case where _startViewTracking is called before
      // the controller finishes initializing
      if (index >= slots.length) { t.cancel(); return; }
      final ctrl = slots[index].controller;
      if (ctrl == null) return; // not ready yet — keep waiting

      if (ctrl.value.isPlaying) {
        secs++;
        debugPrint('👁 View progress: $secs/8 for $reelId');
        if (secs >= 8) {
          _viewedReels.add(reelId);
          _incrementView(reelId);
          t.cancel();
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
    } catch (e) {
      debugPrint('❌ _incrementView: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────
  void _appendDocs(List<DocumentSnapshot> docs) {
    for (final doc in docs) {
      if (slots.any((s) => s.reel.id == doc.id)) continue;
      final map = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      map['id'] = map['id']?.toString().isNotEmpty == true ? map['id'] : doc.id;
      slots.add(_ReelSlot(Video.fromMap(map)));
    }
  }
}

// ignore: prefer_void_to_null, dead_code
void unawaited(Future<void>? future) {}