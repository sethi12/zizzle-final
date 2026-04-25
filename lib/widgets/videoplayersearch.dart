import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideplayerSearch extends StatefulWidget {
  final String videourl;
  final String id;
  final String thumnail;

  const VideplayerSearch({Key? key, required this.videourl, required this.id, required this.thumnail})
      : super(key: key);

  @override
  State<VideplayerSearch> createState() => _VideplayerSearchState();

}

class _VideplayerSearchState extends State<VideplayerSearch> {
  late VideoPlayerController videoPlayerController;
  bool isVideoInitialized = false;
  int views = 0;
  final _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  Duration _durationPlayed = Duration.zero;
  bool isreelviewed = false;
  @override
  void initState() {
    super.initState();
    // Initialize the controller in the background
    initializeController();
    _timer?.cancel();
  }
  Future<void> initializeController() async {
    videoPlayerController = VideoPlayerController.network(widget.videourl)
      ..initialize().then((value) {
        setState(() {
          isVideoInitialized = true;
        });
        videoPlayerController.play();
        videoPlayerController.setVolume(0);
        videoPlayerController.setLooping(true);
      });

    // Listen for video player events
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isPlaying) {
        // Start the timer when the video starts playing
        _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
          if (mounted) {
            setState(() {
              _durationPlayed += Duration(minutes: 1);
            });

            // Check if 30 seconds have passed
            if (_durationPlayed.inMinutes >= 1 && !isreelviewed) {
              // Update views after 30 seconds
              updateViews();
              setState(() {
                _durationPlayed = Duration.zero; // Reset duration
              });
            }
          } else {
            timer.cancel(); // Stop the timer if the widget is not mounted
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    _timer?.cancel(); // Cancel the timer when disposing
  }

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
        // _durationPlayed =Duration.zero;
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
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Center(
          child: Stack(
            children: [
              // Thumbnail
              Visibility(
                visible: !isVideoInitialized || !videoPlayerController.value.isPlaying,
                child: Image.network(
                  // Replace with the actual thumbnail URL
                  widget.thumnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Video Player
              Visibility(
                visible: isVideoInitialized && videoPlayerController.value.isPlaying,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double videoWidth = size.width;
                    double videoHeight = size.width / videoPlayerController.value.aspectRatio;

                    if (videoWidth < constraints.maxWidth || videoHeight < constraints.maxHeight) {
                      // If the video size is smaller than the device size, use the original size
                      videoWidth = size.width;
                      videoHeight = size.width / videoPlayerController.value.aspectRatio;
                    }

                    return SizedBox(
                      width: videoWidth,
                      height: videoHeight,
                      child: VideoPlayer(videoPlayerController),
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
