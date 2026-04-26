// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_it/get_it.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart'; 
// import 'package:zizzle/Ai/WakeWord.dart';
// import 'package:zizzle/Controllers/reelsfeed.dart';
// import 'package:zizzle/Screens/Comment_reel_screen.dart';
// import 'package:zizzle/Screens/GlobalReelBenefitScreen.dart';
// import 'package:zizzle/Screens/ReelLikesScreen.dart';
// import 'package:zizzle/Screens/profile_screen.dart';
// import 'package:zizzle/resources/firestoremethods.dart';
// import 'package:zizzle/services/alert_service.dart';

// import 'package:zizzle/utils/utils.dart';
// import 'package:zizzle/widgets/CircleTickIcon.dart';
// import 'package:zizzle/widgets/blueTick.dart';
// import 'package:zizzle/widgets/pulseloader.dart';

// class ReelFeedUI extends StatefulWidget {
//   @override
//   State<ReelFeedUI> createState() => _ReelFeedUIState();
// }

// class _ReelFeedUIState extends State<ReelFeedUI> {
//   late final ReelsController controller;
//   late WakeWordService wakeWordService;
//   var storeduid;
//   var myusername;
//   var email;
//   void getuid() async {
//     final prefs = await SharedPreferences.getInstance();
//     myusername = prefs.getString('username');
//     var existinguser = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(myusername)
//         .get();
//     storeduid = existinguser.data()?['uid'];
//     setState(() {});
//   }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   controller = Get.find(); // initialize first
//   //   controller.fetchVideos(); // load current reels
//   //   // controller.startListeningForNewReels(); // start listening for new reels
//   //   getuid(); // get user id in background, doesn't block video loading
//   // }
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.find<ReelsController>();

//     // Only fetch if not already loaded
//     if (controller.videos.isEmpty) {
//       print("Empty");
//       controller.fetchVideos();
//     }
//     if (Platform.isIOS) {
//       // Always listen for new reels
//       controller.startListeningForNewReels();
//     }
//     wakeWordService = WakeWordService(context: context);
//     wakeWordService.stop();
//     getuid(); // fetch stored uid
//   }

//   void getemail(String username) async {
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('username', isEqualTo: username)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         email = querySnapshot.docs.first.data()['email'];
//         print('✅ User email: $email');
//       } else {
//         print('❌ No user found with username: $username');
//       }
//     } catch (e) {
//       print('🔥 Error fetching email: $e');
//     }
//   }

//   @override
//   void dispose() {
//     if (Platform.isAndroid) {
//       controller.dispose();
//     }
//     controller.pauseAllVideos();
//     controller.stopListeningForNewReels();
//     controller.audioPlayer.stop();
//     super.dispose();
//     wakeWordService.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sizes3 = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Obx(() {
//         if (controller.controllers.isEmpty) {
//           return const Center(child: ParticleBurstLoaderr());
//         }

//         return PageView.builder(
//             controller: controller.pageController,
//             scrollDirection: Axis.vertical,
//             itemCount: controller.controllers.length,
//             onPageChanged: (index) {
//               // if (Platform.isAndroid) {
//               //   if (!controller.allowedIndexes.contains(index)) {
//               //     // Block scroll if the index is not allowed
//               //     controller.pageController
//               //         .jumpToPage(controller.currentIndex.value);
//               //     return;
//               //   }
//               // } else {
//               controller.onPageChanged(index);
//               for (int i = 0; i < controller.controllers.length; i++) {
//                 if (i == index) {
//                   controller.controllers[i].play();
//                 } else {
//                   controller.controllers[i].pause();
//                 }
//               }
//             }
//             // },
//             ,
//             itemBuilder: (context, index) {
//               final videoController = controller.controllers[index];
//               final reelId = controller.videos[index].id;

//               if (!videoController.value.isInitialized) {
//                 return const Center(child: ParticleBurstLoaderr());
//               }

//               return StreamBuilder<DocumentSnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('reels')
//                     .doc(reelId)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData || !snapshot.data!.exists) {
//                     return const Center(child: ParticleBurstLoaderr());
//                   }

//                   final data =
//                       snapshot.data!.data() as Map<String, dynamic>? ?? {};

//                   return LayoutBuilder(
//                     builder: (context, constraints) {
//                       double originalAspectRatio =
//                           videoController.value.aspectRatio;

//                       // Flag to check if aspect ratio was adjusted
//                       bool isAdjusted =
//                           (originalAspectRatio - 0.3625).abs() < 0.01;

//                       // Set adjusted aspect ratio accordingly
//                       double adjustedAspectRatio =
//                           isAdjusted ? 0.5625 : originalAspectRatio;

//                       double videoWidth;
//                       double videoHeight;

//                       if (isAdjusted) {
//                         // For adjusted videos: full height of screen, width based on aspect ratio
//                         videoHeight =
//                             constraints.maxHeight; // full height available
//                         videoWidth = videoHeight * adjustedAspectRatio;

//                         // Just in case width exceeds screen width, clamp it
//                         if (videoWidth > constraints.maxWidth) {
//                           videoWidth = constraints.maxWidth;
//                           videoHeight = videoWidth / adjustedAspectRatio;
//                         }
//                       } else {
//                         // For normal videos: full width of screen, height based on aspect ratio
//                         videoWidth = constraints.maxWidth;
//                         videoHeight = videoWidth / adjustedAspectRatio;

//                         // Clamp height if exceeds max height
//                         if (videoHeight > constraints.maxHeight) {
//                           videoHeight = constraints.maxHeight;
//                           videoWidth = videoHeight * adjustedAspectRatio;
//                         }
//                       }
//                       return GestureDetector(
//                         onTap: () {
//                           if (videoController.value.isPlaying) {
//                             videoController.pause();

//                             print(
//                                 "aspect ratio of this video is $originalAspectRatio, adjusted to $adjustedAspectRatio");
//                           } else {
//                             videoController.play();
//                           }
//                         }, // trigger rebuild to update icon                        },
//                         child: Stack(
//                           children: [
//                             Center(
//                               child: Padding(
//                                 padding: EdgeInsets.only(
//                                     bottom: isAdjusted ? 150 : 0),
//                                 child: Container(
//                                   width: videoWidth,
//                                   height: videoHeight,

//                                   color: Colors
//                                       .black, // optional if video has transparency
//                                   child: FittedBox(
//                                     fit: BoxFit.contain,
//                                     child: SizedBox(
//                                       width: videoWidth,
//                                       height: videoHeight,
//                                       child: VideoPlayer(videoController),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // if (!videoController.value.isPlaying)
//                             //   Center(
//                             //     child: Container(
//                             //       decoration: BoxDecoration(
//                             //         color: Colors.black54,
//                             //         shape: BoxShape.circle,
//                             //       ),
//                             //       padding: EdgeInsets.all(12),
//                             //       child: Icon(
//                             //         Icons.play_arrow,
//                             //         size: 48,
//                             //         color: Colors.white,
//                             //       ),
//                             //     ),
//                             //   ),
//                             // Username and Views
//                             Positioned(
//                               left: 16,
//                               bottom: 40,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   data['collabreqacc'] == true
//                                       ? Row(
//                                           children: [
//                                             buildprofile(data['profilephoto']),
//                                             const SizedBox(width: 3),
//                                             GestureDetector(
//                                               onTap: () => {
//                                                 Navigator.of(context).push(
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             ProfileScreen(
//                                                                 username: data[
//                                                                     'username'],
//                                                                 uid: data[
//                                                                     'uid'])))
//                                               },
//                                               child: Text(
//                                                 '${data['username']}',
//                                                 style: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4, right: 4),
//                                               child: Text(
//                                                 "and",
//                                                 style: TextStyle(
//                                                   fontSize: 16,
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             GestureDetector(
//                                                 onTap: () {
//                                                   Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               ProfileScreen(
//                                                                   username: data[
//                                                                       'collabusername'])));
//                                                 },
//                                                 child: Text(
//                                                   data['collabusername'],
//                                                   style: TextStyle(
//                                                     fontSize: 20,
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 )),
//                                           ],
//                                         )
//                                       : Row(
//                                           children: [
//                                             buildprofile(data['profilephoto']),
//                                             const SizedBox(width: 3),
//                                             GestureDetector(
//                                               onTap: () => {
//                                                 Navigator.of(context).push(
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             ProfileScreen(
//                                                                 username: data[
//                                                                     'username'],
//                                                                 uid: data[
//                                                                     'uid'])))
//                                               },
//                                               child: Text(
//                                                 '${data['username'] ?? 'Unknown'}',
//                                                 style: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             if ((data.containsKey('Verified') &&
//                                                 data['Verified'] == true))
//                                               BlueTick()
//                                             else if (data
//                                                     .containsKey('Monetized') &&
//                                                 data['Monetized'] ==
//                                                     'Monitized')
//                                               CircleTickIcon()
//                                           ],
//                                         ),
//                                   const SizedBox.shrink(),
//                                   Text(
//                                     data['caption'],
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox.shrink(),
//                                   Row(
//                                     children: [
//                                       data['Location'] != ""
//                                           ? Icon(Icons.location_on)
//                                           : SizedBox.shrink(),
//                                       SizedBox(
//                                         width: 3,
//                                       ),
//                                       Text(
//                                         data['Location'],
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Text.rich(
//                                     TextSpan(
//                                       children: [
//                                         WidgetSpan(
//                                             alignment:
//                                                 PlaceholderAlignment.middle,
//                                             child:
//                                                 data['orignalsongname'] != null
//                                                     ? Icon(
//                                                         Icons.music_note,
//                                                         size: 18,
//                                                         color: Colors.white,
//                                                       )
//                                                     : SizedBox.shrink()),
//                                         TextSpan(
//                                           text: data['orignalsongname'] != null
//                                               ? data['videoAudioName']
//                                               : data['orignalsongname'],
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),

//                             // Buttons on the right
//                             Positioned(
//                               right: 20,
//                               bottom: 65,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   IconButton(
//                                     icon: Icon(
//                                       Icons.favorite,
//                                       color: (data['likes'] as List<dynamic>)
//                                               .contains(myusername)
//                                           ? Colors.red
//                                           : Colors.white,
//                                       size: 32,
//                                     ),
//                                     onPressed: () {
//                                       Firestoremethods()
//                                           .LikeVideo(data['id'], myusername);
//                                     },
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       showModalBottomSheet(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return Container(
//                                               width: double.infinity,
//                                               height: 800,
//                                               child: ReelLikesScreen(
//                                                 uid: data['uid'],
//                                                 postid: data['id'],
//                                               ),
//                                             );
//                                           });
//                                     },
//                                     child: Text(
//                                       '${(data['likes'] as List<dynamic>?)?.length ?? 0}',
//                                       style: const TextStyle(
//                                           color: Colors.white, fontSize: 14),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//                                   IconButton(
//                                     icon: const Icon(Icons.comment,
//                                         color: Colors.white, size: 28),
//                                     onPressed: () {
//                                       Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   CommentReelScreen(
//                                                     id: data['id'],
//                                                   )));
//                                     },
//                                   ),
//                                   const SizedBox(
//                                     height: 5,
//                                   ),
//                                   Text(
//                                     data['commentcount'].toString(),
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//                                   data['orignalsongurl'] != null &&
//                                           data['orignalsongurl']
//                                               .toString()
//                                               .isNotEmpty
//                                       ? Icon(
//                                           Icons.music_note,
//                                           color: Colors.white,
//                                           size: 28,
//                                         )
//                                       : IconButton(
//                                           icon: Icon(
//                                             videoController.value.volume == 0
//                                                 ? Icons.volume_off
//                                                 : Icons.volume_up,
//                                             color: Colors.white,
//                                             size: 28,
//                                           ),
//                                           onPressed: () {
//                                             setState(() {
//                                               videoController.setVolume(
//                                                 videoController.value.volume ==
//                                                         0
//                                                     ? 1
//                                                     : 0,
//                                               );
//                                             });
//                                           },
//                                         ),
//                                   const SizedBox(height: 20),
//                                   IconButton(
//                                     icon: const Icon(Icons.more_vert,
//                                         color:
//                                             Color.fromARGB(255, 232, 206, 206),
//                                         size: 28),
//                                     onPressed: () {
//                                       // More options
//                                       if (data['uid'] == storeduid &&
//                                           data['username'] == myusername) {
//                                         showDialog(
//                                           context: context,
//                                           builder: (context) => Dialog(
//                                             backgroundColor:
//                                                 Colors.black.withOpacity(1.0),
//                                             child: ListView(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 16,
//                                                       horizontal: 17),
//                                               shrinkWrap: true,
//                                               children: [
//                                                 InkWell(
//                                                   child: Text("Delete Post"),
//                                                   onTap: () async {
//                                                     Firestoremethods()
//                                                         .deletereel(data['id']);
//                                                     Navigator.of(context).pop();
//                                                   },
//                                                 ),
//                                                 Divider(),
//                                                 InkWell(
//                                                   child:
//                                                       data['Archive'] == false
//                                                           ? Text("Archive")
//                                                           : Text("UnArchive"),
//                                                   onTap: () {
//                                                     if (data['Archive'] ==
//                                                         false) {
//                                                       print("NOt Archived");
//                                                       FirebaseFirestore.instance
//                                                           .collection("reels")
//                                                           .doc(data['id'])
//                                                           .update({
//                                                         "Archive": true
//                                                       });
//                                                     } else {
//                                                       FirebaseFirestore.instance
//                                                           .collection("reels")
//                                                           .doc(data['id'])
//                                                           .update({
//                                                         "Archive": false
//                                                       });
//                                                     }

//                                                     Navigator.of(context).pop();
//                                                   },
//                                                 ),
//                                                 Divider(),
//                                                 // InkWell(
//                                                 //   child:
//                                                 //       Text("Make it Private"),
//                                                 //   onTap: () {
//                                                 //     FirebaseFirestore.instance
//                                                 //         .collection("reels")
//                                                 //         .doc(data.id)
//                                                 //         .update({
//                                                 //       "Audience": "Private"
//                                                 //     });
//                                                 //     Navigator.of(context)
//                                                 //         .pop();
//                                                 //   },
//                                                 // ),
//                                                 // Divider(),
//                                                 InkWell(
//                                                   child: Text("Make it Global"),
//                                                   onTap: () async {
//                                                     getemail(myusername);
//                                                     if (data['Audience'] ==
//                                                         'Public') {
//                                                       if (data['isGlobalOptionEnabled'] ==
//                                                               false &&
//                                                           (data['GlobalPaymentActivation'] ==
//                                                               false)) {
//                                                         Navigator.of(context).push(
//                                                             MaterialPageRoute(
//                                                                 builder:
//                                                                     (context) =>
//                                                                         GlobalReelBenfitScreen(
//                                                                           docid:
//                                                                               data['id'],
//                                                                           email:
//                                                                               email,
//                                                                         )));
//                                                       } else {
//                                                         GetIt.I<AlertService>()
//                                                             .showError(
//                                                                 'Reel Already Global');
//                                                       }
//                                                     } else {
//                                                       GetIt.I<AlertService>()
//                                                           .showError(
//                                                               'Private Reel Can not be Global');
//                                                     }
//                                                   },
//                                                 ),
//                                                 const Divider(),
//                                                 InkWell(
//                                                   onTap: () {
//                                                     Firestoremethods()
//                                                         .savedvideo(data['id'],
//                                                             myusername);
//                                                     Navigator.pop(context);
//                                                   },
//                                                   child: (data['saved'] ?? [])
//                                                           .contains(myusername)
//                                                       ? Text("UnSave")
//                                                       : Text("Save"),
//                                                 )
//                                               ].toList(),
//                                             ),
//                                           ),
//                                         );
//                                       } else {
//                                         showDialog(
//                                             context: context,
//                                             builder: (context) => Dialog(
//                                                   backgroundColor: Colors.black
//                                                       .withOpacity(1.0),
//                                                   child: ListView(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         vertical: 16,
//                                                         horizontal: 17),
//                                                     shrinkWrap: true,
//                                                     children: [
//                                                       InkWell(
//                                                         onTap: () {
//                                                           Firestoremethods()
//                                                               .savedvideo(
//                                                                   data['id'],
//                                                                   myusername);
//                                                           Navigator.pop(
//                                                               context);
//                                                         },
//                                                         child: (data['saved'] ??
//                                                                     [])
//                                                                 .contains(
//                                                                     myusername)
//                                                             ? Text("UnSave")
//                                                             : Text("Save"),
//                                                       )
//                                                     ].toList(),
//                                                   ),
//                                                 ));
//                                       }
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // Slim video progress bar
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             });
//       }),
//     );
//   }
// }

// buildprofile(String profilephoto) {
//   return SizedBox(
//     width: 45,
//     height: 45,
//     child: Stack(
//       children: [
//         Container(
//           width: 35,
//           height: 35,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(25),
//             child: Image(
//               image: NetworkImage(profilephoto),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }




import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:zizzle/Ai/WakeWord.dart';
import 'package:zizzle/Controllers/reelsfeed.dart';
import 'package:zizzle/Screens/Comment_reel_screen.dart';
import 'package:zizzle/Screens/GlobalReelBenefitScreen.dart';
import 'package:zizzle/Screens/ReelLikesScreen.dart';
import 'package:zizzle/Screens/profile_screen.dart';
import 'package:zizzle/resources/firestoremethods.dart';
import 'package:zizzle/services/alert_service.dart';
import 'package:zizzle/widgets/CircleTickIcon.dart';
import 'package:zizzle/widgets/blueTick.dart';
import 'package:zizzle/widgets/pulseloader.dart';

class ReelFeedUI extends StatefulWidget {
  @override
  State<ReelFeedUI> createState() => _ReelFeedUIState();
}

class _ReelFeedUIState extends State<ReelFeedUI> with WidgetsBindingObserver {
  late final ReelsController rc;
  late WakeWordService wakeWordService;
  String? storeduid;
  String? myusername;
  String? email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    rc = Get.find<ReelsController>();

    if (rc.slots.isEmpty) rc.fetchVideos();
    if (Platform.isIOS) rc.startListeningForNewReels();

    wakeWordService = WakeWordService(context: context);
    wakeWordService.stop();
    _loadUser();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause when app goes to background, resume when comes back
    if (state == AppLifecycleState.paused) {
      rc.pauseAllVideos();
      rc.audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      final idx = rc.currentIndex.value;
      if (idx < rc.slots.length && rc.slots[idx].isReady) {
        rc.slots[idx].controller?.play();
      }
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    myusername = prefs.getString('username');
    if (myusername == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(myusername)
        .get();
    storeduid = doc.data()?['uid'];
    if (mounted) setState(() {});
  }

  Future<void> _loadEmail(String username) async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) email = q.docs.first.data()['email'];
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    rc.pauseAllVideos();
    rc.stopListeningForNewReels();
    rc.audioPlayer.stop();
    wakeWordService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Show loader on very first load only
        if (rc.isFirstLoad.value) {
          return const Center(child: ParticleBurstLoaderr());
        }

        return PageView.builder(
          controller: rc.pageController,
          scrollDirection: Axis.vertical,
          itemCount: rc.slots.length,
          onPageChanged: rc.onPageChanged,
          itemBuilder: (context, index) {
            return Obx(() {
              final slot = rc.slots[index];

              // ── Not ready yet — show thumbnail ─────────────────────
              if (!slot.isReady) {
                return _Thumbnail(url: slot.reel.bestThumbnail);
              }

              final vc = slot.controller!;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reels')
                    .doc(slot.reel.id)
                    .snapshots(),
                builder: (ctx, snap) {
                  if (!snap.hasData || !snap.data!.exists) {
                    return _Thumbnail(url: slot.reel.bestThumbnail);
                  }
                  final data = snap.data!.data() as Map<String, dynamic>? ?? {};

                  return GestureDetector(
                    onTap: () => vc.value.isPlaying
                        ? vc.pause()
                        : vc.play(),
                    child: LayoutBuilder(builder: (ctx, constraints) {
                      // ── Aspect ratio logic (original preserved) ───
                      final double origAR = vc.value.aspectRatio;
                      final bool isPortrait = (origAR - 0.3625).abs() < 0.01;
                      final double ar = isPortrait ? 0.5625 : origAR;

                      double vw, vh;
                      if (isPortrait) {
                        vh = constraints.maxHeight;
                        vw = vh * ar;
                        if (vw > constraints.maxWidth) {
                          vw = constraints.maxWidth;
                          vh = vw / ar;
                        }
                      } else {
                        vw = constraints.maxWidth;
                        vh = vw / ar;
                        if (vh > constraints.maxHeight) {
                          vh = constraints.maxHeight;
                          vw = vh * ar;
                        }
                      }

                      return Stack(
                        children: [
                          // ── Video ──────────────────────────────────
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: isPortrait ? 150 : 0),
                              child: SizedBox(
                                width: vw,
                                height: vh,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: vw,
                                    height: vh,
                                    child: VideoPlayer(vc),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ── Pause icon overlay ─────────────────────
                          ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: vc,
                            builder: (_, val, __) {
                              if (!val.isPlaying && !val.isBuffering) {
                                return const Center(
                                  child: Icon(Icons.play_arrow,
                                      size: 64,
                                      color: Colors.white54),
                                );
                              }
                              if (val.isBuffering) {
                                return const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // ── Bottom left info ───────────────────────
                          Positioned(
                            left: 16,
                            bottom: 40,
                            right: 80,
                            child: _BottomInfo(data: data, ctx: context),
                          ),

                          // ── Right side actions ─────────────────────
                          Positioned(
                            right: 12,
                            bottom: 60,
                            child: _ActionColumn(
                              data: data,
                              vc: vc,
                              myusername: myusername,
                              context: context,
                              onMoreOptions: () =>
                                  _showOptions(context, data),
                            ),
                          ),
                        ],
                      );
                    }),
                  );
                },
              );
            });
          },
        );
      }),
    );
  }

  // ── More options ──────────────────────────────────────────────────
  void _showOptions(BuildContext context, Map<String, dynamic> data) {
    final isOwner =
        data['uid'] == storeduid && data['username'] == myusername;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: ListView(
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shrinkWrap: true,
          children: isOwner
              ? [
                  _opt('Delete', () {
                    Firestoremethods().deletereel(data['id']);
                    Navigator.pop(context);
                  }),
                  const Divider(color: Colors.white12),
                  _opt(
                    data['Archive'] == false ? 'Archive' : 'Unarchive',
                    () {
                      FirebaseFirestore.instance
                          .collection('reels')
                          .doc(data['id'])
                          .update({
                        'Archive': !(data['Archive'] == true)
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(color: Colors.white12),
                  _opt('Make Global', () async {
                    await _loadEmail(myusername!);
                    if (data['Audience'] == 'Public') {
                      if (data['isGlobalOptionEnabled'] == false &&
                          data['GlobalPaymentActivation'] == false) {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => GlobalReelBenfitScreen(
                                    docid: data['id'],
                                    email: email)));
                      } else {
                        GetIt.I<AlertService>()
                            .showError('Already Global');
                      }
                    } else {
                      GetIt.I<AlertService>()
                          .showError('Private reels cannot be Global');
                    }
                  }),
                  const Divider(color: Colors.white12),
                  _opt(
                    (data['saved'] ?? []).contains(myusername)
                        ? 'Unsave'
                        : 'Save',
                    () {
                      Firestoremethods()
                          .savedvideo(data['id'], myusername!);
                      Navigator.pop(context);
                    },
                  ),
                ]
              : [
                  _opt(
                    (data['saved'] ?? []).contains(myusername)
                        ? 'Unsave'
                        : 'Save',
                    () {
                      Firestoremethods()
                          .savedvideo(data['id'], myusername!);
                      Navigator.pop(context);
                    },
                  ),
                ],
        ),
      ),
    );
  }

  Widget _opt(String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(label,
              style:
                  const TextStyle(color: Colors.white, fontSize: 15)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Thumbnail placeholder — shown while controller initializes
// ─────────────────────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final String url;
  const _Thumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: Colors.black),
                errorWidget: (_, __, ___) =>
                    Container(color: Colors.black),
              )
            : Container(color: Colors.black),
        const Positioned(
          top: 0, left: 0, right: 0,
          child: LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom info — username, caption, location, song
// ─────────────────────────────────────────────────────────────────────────────
class _BottomInfo extends StatelessWidget {
  final Map<String, dynamic> data;
  final BuildContext ctx;
  const _BottomInfo({required this.data, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username row
        if (data['collabreqacc'] == true)
          _CollabRow(data: data, ctx: ctx)
        else
          _UserRow(data: data, ctx: ctx),

        const SizedBox(height: 6),

        // Caption
        if ((data['caption'] ?? '').isNotEmpty)
          Text(
            data['caption'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),

        // Location
        if ((data['Location'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on,
                color: Colors.white70, size: 13),
            const SizedBox(width: 2),
            Text(data['Location'],
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ]),
        ],

        // Original song name
        if (data['orignalsongname'] != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.music_note,
                color: Colors.white70, size: 13),
            const SizedBox(width: 2),
            Text(
              data['videoAudioName'] ?? data['orignalsongname'] ?? '',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12),
            ),
          ]),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right action column — like, comment, volume, more
// ─────────────────────────────────────────────────────────────────────────────
class _ActionColumn extends StatelessWidget {
  final Map<String, dynamic> data;
  final VideoPlayerController vc;
  final String? myusername;
  final BuildContext context;
  final VoidCallback onMoreOptions;
  const _ActionColumn({
    required this.data,
    required this.vc,
    required this.myusername,
    required this.context,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext ctx) {
    final liked =
        (data['likes'] as List? ?? []).contains(myusername);
    final likeCount = (data['likes'] as List?)?.length ?? 0;
    final commentCount = data['commentcount'] ?? 0;
    final hasOrigAudio = (data['orignalsongurl']?.toString().isNotEmpty ?? false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like
        GestureDetector(
          onTap: () => Firestoremethods()
              .LikeVideo(data['id'], myusername!),
          child: Column(children: [
            Icon(liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.red : Colors.white, size: 30),
            const SizedBox(height: 2),
            Text('$likeCount',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),

        // Comment
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  CommentReelScreen(id: data['id']))),
          child: Column(children: [
            const Icon(Icons.chat_bubble_outline,
                color: Colors.white, size: 28),
            const SizedBox(height: 2),
            Text('$commentCount',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),

        // Volume / music
        if (hasOrigAudio)
          const Icon(Icons.music_note,
              color: Colors.white, size: 28)
        else
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: vc,
            builder: (_, val, __) => GestureDetector(
              onTap: () =>
                  vc.setVolume(val.volume == 0 ? 1.0 : 0.0),
              child: Icon(
                val.volume == 0
                    ? Icons.volume_off
                    : Icons.volume_up,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        const SizedBox(height: 20),

        // More
        GestureDetector(
          onTap: onMoreOptions,
          child: const Icon(Icons.more_vert,
              color: Colors.white70, size: 26),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User rows
// ─────────────────────────────────────────────────────────────────────────────
class _UserRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final BuildContext ctx;
  const _UserRow({required this.data, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => ProfileScreen(
              username: data['username'], uid: data['uid']))),
      child: Row(children: [
        _Avatar(url: data['profilephoto'] ?? ''),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            data['username'] ?? 'Unknown',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
        ),
        if (data['Verified'] == true) ...[
          const SizedBox(width: 4),
          BlueTick(),
        ],
        if (data['Monetized'] == 'Monitized') ...[
          const SizedBox(width: 4),
          CircleTickIcon(),
        ],
      ]),
    );
  }
}

class _CollabRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final BuildContext ctx;
  const _CollabRow({required this.data, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _Avatar(url: data['profilephoto'] ?? ''),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
            builder: (_) => ProfileScreen(
                username: data['username'], uid: data['uid']))),
        child: Text(data['username'] ?? '',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('&',
            style:
                TextStyle(color: Colors.white70, fontSize: 13)),
      ),
      GestureDetector(
        onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
            builder: (_) => ProfileScreen(
                username: data['collabusername']))),
        child: Text(data['collabusername'] ?? '',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar widget
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String url;
  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: Colors.grey.shade800),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.person, color: Colors.white),
              )
            : const Icon(Icons.person,
                color: Colors.white, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// buildprofile — kept for backward compat with any other screens
// ─────────────────────────────────────────────────────────────────────────────
Widget buildprofile(String profilephoto) {
  return SizedBox(
    width: 40,
    height: 40,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: profilephoto.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: profilephoto,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: Colors.grey.shade800),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.person, color: Colors.grey),
            )
          : const Icon(Icons.person, color: Colors.grey),
    ),
  );
}