import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '/Controllers/video_controller.dart';

import '../model/reel.dart'; // Import VideoController if not already imported

class VideoPlayerItem extends StatefulWidget {
  final String videourl;
  final String id;
  final String? spotifyPreviewUrl; // Nullable, in case no song is selected
  final String thumbnail;
  final int? endduration;
  final int? startduration;
  // final int currentindex;
  //  List<Video> videolist; // Add videolist here
  VideoPlayerItem(
      {Key? key,
      required this.videourl,
      required this.id,
      required this.thumbnail,
      this.endduration,
      this.startduration,
      this.spotifyPreviewUrl})
      : super(key: key);
  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  AudioPlayer? _audioPlayer; // For Spotify preview
  bool isVideoInitialized = false;
  int views = 0;
  final _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  Duration _durationPlayed = Duration.zero;
  bool isreelviewed = false;

  @override
  void initState() {
    super.initState();
    initializeController();
    if (widget.spotifyPreviewUrl != null) {
      _initializeSpotifyPlayer(widget.spotifyPreviewUrl!);
    }
    _timer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer?.dispose();
    videoPlayerController.dispose();
    _timer?.cancel(); // Cancel the timer when disposing
  }

  Future<void> _initializeSpotifyPlayer(String previewUrl) async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer?.setUrl(previewUrl);

    // Seek to startduration if provided
    final start = widget.startduration ?? 0;
    await _audioPlayer?.seek(Duration(seconds: start));

    // Don't loop full audio automatically, manual control
    await _audioPlayer?.setLoopMode(LoopMode.off);

    // Listen to position updates to stop at endduration
    _audioPlayer?.positionStream.listen((position) {
      final end = widget.endduration ?? 0;
      if (end > 0 && position.inSeconds >= end) {
        _audioPlayer?.pause();
        // Optionally, seek back to start to prepare for next play
        _audioPlayer?.seek(Duration(seconds: start));
      }
    });
  }

  Future<void> initializeController() async {
    videoPlayerController = VideoPlayerController.network(widget.videourl);
    await videoPlayerController.initialize();

    setState(() {
      isVideoInitialized = true;
    });

    // Don't use built-in looping
    // videoPlayerController.setLooping(true);

    // Load audio if present
    if (widget.spotifyPreviewUrl != null) {
      await _initializeSpotifyPlayer(widget.spotifyPreviewUrl!);
      videoPlayerController.setVolume(0); // Mute video audio
    } else {
      videoPlayerController.setVolume(1);
    }

    bool _hasStarted = false;

    // Start the video
    videoPlayerController.play();

    videoPlayerController.addListener(() async {
      final controller = videoPlayerController;
      final position = controller.value.position;
      final duration = controller.value.duration;

      if (controller.value.isPlaying && !_hasStarted) {
        _hasStarted = true;
        if (_audioPlayer != null) {
          // On video start or replay, seek audio to startduration and play
          final start = widget.startduration ?? 0;
          await _audioPlayer?.seek(Duration(seconds: start));
          await _audioPlayer?.play();
        }
      }

      if (_hasStarted &&
          duration != null &&
          position >= duration &&
          !controller.value.isPlaying) {
        _hasStarted = false;

        await controller.seekTo(Duration.zero);

        if (_audioPlayer != null) {
          final start = widget.startduration ?? 0;
          await _audioPlayer?.seek(Duration(seconds: start));
        }

        await Future.delayed(Duration(milliseconds: 100));

        controller.play();
        _audioPlayer?.play();
      }

      // Views timer
      if (controller.value.isPlaying) {
        if (_timer == null || !_timer!.isActive) {
          _timer = Timer.periodic(Duration(seconds: 8), (Timer timer) {
            if (mounted) {
              setState(() {
                _durationPlayed += Duration(seconds: 8);
              });

              if (_durationPlayed.inSeconds >= 8 && !isreelviewed) {
                updateViews();
                setState(() {
                  _durationPlayed = Duration.zero;
                });
              }
            } else {
              timer.cancel();
            }
          });
        }
      }
    });
  }

  // void preloadNextVideo() async {
  //   if (widget.currentindex < widget.videolist.length - 1) {
  //     await VideoPlayerController.network(widget.videolist[widget.currentindex + 1].videourl).initialize();
  //   }
  // }

  void updateViews() async {
    try {
      // Increment the view count in Firestore
      await _firestore.collection("reels").doc(widget.id).update({
        'views': FieldValue.increment(1),
      });

      // Update the local views count
      setState(() {
        views++;
        isreelviewed = true;
      });

      print('$views views');
    } catch (e) {
      print('Error updating views: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      // onTap: () {
      //   if (videoPlayerController.value.isPlaying) {
      //     videoPlayerController.pause();
      //   } else {
      //     videoPlayerController.play();
      //   }
      // },
      onTap: () {
        if (videoPlayerController.value.isPlaying) {
          videoPlayerController.pause();
          _audioPlayer?.pause();
        } else {
          videoPlayerController.play();
          _audioPlayer?.play();
        }
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Center(
          child: Stack(
            children: [
              // Thumbnail
              Visibility(
                visible: !isVideoInitialized ||
                    !videoPlayerController.value.isPlaying,
                child: Image.network(
                  widget.thumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              if (!videoPlayerController
                  .value.isPlaying) // Show pause icon when paused
                Center(
                  child: Icon(
                    Icons.pause,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              // Video Player
              Visibility(
                visible:
                    isVideoInitialized && videoPlayerController.value.isPlaying,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // double videoWidth = size.width;
                    // double videoHeight =
                    //     size.width / videoPlayerController.value.aspectRatio;

                    // if (videoWidth < constraints.maxWidth ||
                    //     videoHeight < constraints.maxHeight) {
                    //   // If the video size is smaller than the device size, use the original size
                    //   videoWidth = size.width;
                    //   videoHeight =
                    //       size.width / videoPlayerController.value.aspectRatio;
                    // }
                    double originalAspectRatio =
                        videoPlayerController.value.aspectRatio;

                    // Flag to check if aspect ratio was adjusted
                    bool isAdjusted =
                        (originalAspectRatio - 0.3625).abs() < 0.01;

                    // Set adjusted aspect ratio accordingly
                    double adjustedAspectRatio =
                        isAdjusted ? 0.5625 : originalAspectRatio;

                    double videoWidth;
                    double videoHeight;

                    if (isAdjusted) {
                      // For adjusted videos: full height of screen, width based on aspect ratio
                      videoHeight =
                          constraints.maxHeight; // full height available
                      videoWidth = videoHeight * adjustedAspectRatio;

                      // Just in case width exceeds screen width, clamp it
                      if (videoWidth > constraints.maxWidth) {
                        videoWidth = constraints.maxWidth;
                        videoHeight = videoWidth / adjustedAspectRatio;
                      }
                    } else {
                      // For normal videos: full width of screen, height based on aspect ratio
                      videoWidth = constraints.maxWidth;
                      videoHeight = videoWidth / adjustedAspectRatio;

                      // Clamp height if exceeds max height
                      if (videoHeight > constraints.maxHeight) {
                        videoHeight = constraints.maxHeight;
                        videoWidth = videoHeight * adjustedAspectRatio;
                      }
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: isAdjusted ? 150 : 0),
                      child: SizedBox(
                        width: videoWidth,
                        height: videoHeight,
                        child: VideoPlayer(videoPlayerController),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
