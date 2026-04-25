// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:just_audio/just_audio.dart';
// import '/Controllers/video_controller.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class VideoPlayerWithSpotify extends StatefulWidget {
//   final String videoUrl;
//   final String? spotifyPreviewUrl; // Nullable, in case no song is selected
//   final String id; // For updating views
//   final String thumbnail; // For video thumbnail

//   const VideoPlayerWithSpotify({
//     required this.videoUrl,
//     this.spotifyPreviewUrl,
//     required this.id,
//     required this.thumbnail,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<VideoPlayerWithSpotify> createState() => _VideoPlayerWithSpotifyState();
// }

// class _VideoPlayerWithSpotifyState extends State<VideoPlayerWithSpotify> {
//   late VideoPlayerController _videoPlayerController;
//   AudioPlayer? _audioPlayer; // For Spotify preview
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Timer? _viewTimer;
//   bool isReelViewed = false;
//   Duration _durationPlayed = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();

//     if (widget.spotifyPreviewUrl != null) {
//       _initializeSpotifyPlayer(widget.spotifyPreviewUrl!);
//     }
//   }

//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     _audioPlayer?.dispose();
//     _viewTimer?.cancel();
//     super.dispose();
//   }

//   void _initializeVideoPlayer() {
//     _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _videoPlayerController.play();
//         if (widget.spotifyPreviewUrl != null) {
//           _videoPlayerController
//               .setVolume(0); // Mute video if Spotify is playing
//         } else {
//           _videoPlayerController.setVolume(1); // Play video audio otherwise
//         }
//         _startViewTimer();
//       });
//     _videoPlayerController.setLooping(true);
//   }

//   Future<void> _initializeSpotifyPlayer(String previewUrl) async {
//     _audioPlayer = AudioPlayer();
//     await _audioPlayer?.setUrl(previewUrl);
//     _audioPlayer?.play();
//   }

//   void _startViewTimer() {
//     _viewTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//       if (mounted && _videoPlayerController.value.isPlaying) {
//         setState(() {
//           _durationPlayed += const Duration(seconds: 8);
//         });
//         if (_durationPlayed.inSeconds >= 8 && !isReelViewed) {
//           _updateViews();
//           setState(() {
//             isReelViewed = true;
//             _durationPlayed = Duration.zero; // Reset duration
//           });
//         }
//       }
//     });
//   }

//   Future<void> _updateViews() async {
//     try {
//       await _firestore.collection("reels").doc(widget.id).update({
//         'views': FieldValue.increment(1),
//       });
//       print("Views updated successfully!");
//     } catch (e) {
//       print("Error updating views: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: () {
//         if (_videoPlayerController.value.isPlaying) {
//           _videoPlayerController.pause();
//           _audioPlayer?.pause();
//         } else {
//           _videoPlayerController.play();
//           _audioPlayer?.play();
//         }
//       },
//       child: Stack(
//         children: [
//           // Thumbnail placeholder
//           if (!_videoPlayerController.value.isInitialized)
//             Image.network(
//               widget.thumbnail,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//             ),
//           // Video Player
//           if (_videoPlayerController.value.isInitialized)
//             VideoPlayer(_videoPlayerController),

//           // Overlay: Pause/Play Indicator
//           if (!_videoPlayerController.value.isPlaying)
//             const Center(
//               child: Icon(
//                 Icons.play_arrow,
//                 size: 64,
//                 color: Colors.white,
//               ),
//             ),
//           Visibility(
//             visible: _videoPlayerController.value.isInitialized &&
//                 _videoPlayerController.value.isPlaying,
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 double videoWidth = size.width;
//                 double videoHeight =
//                     size.width / _videoPlayerController.value.aspectRatio;

//                 if (videoWidth < constraints.maxWidth ||
//                     videoHeight < constraints.maxHeight) {
//                   // If the video size is smaller than the device size, use the original size
//                   videoWidth = size.width;
//                   videoHeight =
//                       size.width / _videoPlayerController.value.aspectRatio;
//                 }

//                 return SizedBox(
//                   width: videoWidth,
//                   height: videoHeight,
//                   child: VideoPlayer(_videoPlayerController),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
