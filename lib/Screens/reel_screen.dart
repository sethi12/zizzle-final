// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '/Controllers/video_controller.dart';
// import '/Screens/Comment_reel_screen.dart';
// import '/Screens/GlobalReelBenefitScreen.dart';
// import '/Screens/profile_screen.dart';
// import '/ads/ads_manager.dart';
// import '/resources/firestoremethods.dart';
// import '/utils/utils.dart';
// import '/widgets/Video_player.dart';
// import '/widgets/circle_animation.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../model/reel.dart';
// import 'Global_benefits_screen.dart';
// import 'ReelLikesScreen.dart';

// class VideoScreen extends StatefulWidget {
//   VideoScreen({Key? key}) : super(key: key);

//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late final VideoController videoController;
//   late List<Video> videolist;
//   late var data;
//   var storeduid;
//   var username;
//   late final PageController _pageController;
//   int scrollcount = 0;
//   int currentindex = 0;

//   buildprofile(String profilephoto) {
//     return SizedBox(
//       width: 60,
//       height: 60,
//       child: Stack(
//         children: [
//           Positioned(
//             left: 5,
//             child: Container(
//               width: 50,
//               height: 50,
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(25),
//                 child: Image(
//                   image: NetworkImage(profilephoto),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     videoController = Get.put(VideoController());
//     videolist = videoController.videolist;
//     videolist.shuffle();
//     getuid();
//     Admanager().loadintad();
//     _pageController = PageController(initialPage: 0);
//     _pageController.addListener(_pageListener);
//   }

//   @override
//   void dispose() {
//     _pageController.removeListener(_pageListener);
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _pageListener() {
//     setState(() {
//       currentindex = _pageController.page?.round() ?? 0;
//     });
//   }

//   // Map<String, dynamic> getNextReelInfo() {
//   //   int nextIndex = getNextReelIndex();
//   //   if (nextIndex < videolist.length) {
//   //     return {
//   //       'id': videolist[nextIndex].id,
//   //       'videourl': videolist[nextIndex].videourl,
//   //     };
//   //   } else {
//   //     return {
//   //       'id': '',
//   //       'videourl': ''
//   //     }; // Handle the case where nextIndex is out of bounds
//   //   }
//   // }
//   //
//   // int getNextReelIndex() {
//   //   if (currentindex < videolist.length - 1) {
//   //     return currentindex + 1;
//   //   } else {
//   //     return 0; // Loop back to the first reel
//   //   }
//   // }

//   void getuid() async {
//     final prefs = await SharedPreferences.getInstance();
//     username = prefs.getString('username');
//     var existinguser = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(username)
//         .get();
//     storeduid = existinguser.data()?['uid'];
//     print(storeduid);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     // Map<String, dynamic> nextReelInfo = getNextReelInfo(); // Get next reel's id and videourl
//     // String nextReelId = nextReelInfo['id'];
//     // String nextReelVideoUrl = nextReelInfo['videourl'];
//     //
//     // print('Next Reel ID: $nextReelId'); // Print the next reel's id
//     // print('Next Reel Video URL: $nextReelVideoUrl');

//     return Scaffold(
//       body: Obx(() {
//         return PageView.builder(
//           physics: CustomScrollPhysics(),
//           itemCount: videolist.length,
//           controller: _pageController,
//           onPageChanged: (index) {
//             scrollcount++;
//             if (scrollcount % 5 == 0) {
//               Admanager().showintad();
//             }
//             setState(() {
//               currentindex = index;
//             });
//           },
//           scrollDirection: Axis.vertical,
//           itemBuilder: (context, index) {
//             data = videolist[index];
//             return Stack(
//               children: [
//                 data.previewUrl == ""
//                     ? VideoPlayerItem(
//                         videourl: data.videourl,
//                         id: data.id,
//                         thumbnail: data.thumbnail,

//                         // Pass the current index
//                       )
//                     : VideoPlayerItem(
//                         videourl: data.videourl,
//                         id: data.id,
//                         thumbnail: data.thumbnail,
//                         spotifyPreviewUrl: data.previewUrl,
//                         endduration: data.endAudioDuration,
//                         startduration: data.startAudioDuration,
//                         // Pass the current index
//                       ),
//                 Column(
//                   children: [
//                     const SizedBox(
//                       height: 100,
//                     ),
//                     Expanded(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Expanded(
//                             child: Container(
//                               padding: const EdgeInsets.only(left: 20),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   data.collabreqacc == false
//                                       ? GestureDetector(
//                                           onTap: () {
//                                             Navigator.of(context).push(
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         ProfileScreen(
//                                                             username:
//                                                                 data.username,
//                                                             uid: data.uid)));
//                                           },
//                                           child: Text(
//                                             data.username,
//                                             style: TextStyle(
//                                               fontSize: 20,
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         )
//                                       : Row(
//                                           children: [
//                                             GestureDetector(
//                                                 onTap: () {
//                                                   Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               ProfileScreen(
//                                                                   username: data
//                                                                       .username,
//                                                                   uid: data
//                                                                       .uid)));
//                                                 },
//                                                 child: Text(
//                                                   data.username,
//                                                   style: TextStyle(
//                                                     fontSize: 20,
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 )),
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
//                                                                   username: data
//                                                                       .collabusername)));
//                                                 },
//                                                 child: Text(
//                                                   data.collabusername,
//                                                   style: TextStyle(
//                                                     fontSize: 20,
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 )),
//                                           ],
//                                         ),
//                                   Text(
//                                     data.caption,
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     data.Location,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: 100,
//                             margin: EdgeInsets.only(top: size.height / 4),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 buildprofile(data.profilephoto),
//                                 Column(
//                                   children: [
//                                     InkWell(
//                                       onTap: () => Firestoremethods()
//                                           .LikeVideo(data.id, username),
//                                       child: Icon(
//                                         Icons.favorite,
//                                         size: 40,
//                                         color: data.likes.contains(username)
//                                             ? Colors.red
//                                             : Colors.white.withOpacity(0.3),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 5,
//                                     ),
//                                     GestureDetector(
//                                       onTap: () {
//                                         showModalBottomSheet(
//                                             context: context,
//                                             builder: (BuildContext context) {
//                                               return Container(
//                                                 width: double.infinity,
//                                                 height: 800,
//                                                 child: ReelLikesScreen(
//                                                   uid: data.uid,
//                                                   postid: data.id,
//                                                 ),
//                                               );
//                                             });
//                                       },
//                                       child: Text(
//                                         data.likes.length.toString(),
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   children: [
//                                     InkWell(
//                                       onTap: () => Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   CommentReelScreen(
//                                                     id: data.id,
//                                                   ))),
//                                       child: Icon(
//                                         Icons.comment,
//                                         size: 40,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 5,
//                                     ),
//                                     Text(
//                                       data.commentcount.toString(),
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   children: [
//                                     IconButton(
//                                       onPressed: () {
//                                         if (data.uid == storeduid) {
//                                           showDialog(
//                                             context: context,
//                                             builder: (context) => Dialog(
//                                               backgroundColor:
//                                                   Colors.black.withOpacity(1.0),
//                                               child: ListView(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 16,
//                                                         horizontal: 17),
//                                                 shrinkWrap: true,
//                                                 children: [
//                                                   InkWell(
//                                                     child: Text("Delete Post"),
//                                                     onTap: () async {
//                                                       Firestoremethods()
//                                                           .deletereel(data.id);
//                                                       Navigator.of(context)
//                                                           .pop();
//                                                     },
//                                                   ),
//                                                   Divider(),
//                                                   InkWell(
//                                                     child: data.Archive == false
//                                                         ? Text("Archive")
//                                                         : Text("UnArchive"),
//                                                     onTap: () {
//                                                       if (data.Archive ==
//                                                           false) {
//                                                         print("NOt Archived");
//                                                         FirebaseFirestore
//                                                             .instance
//                                                             .collection("reels")
//                                                             .doc(data.id)
//                                                             .update({
//                                                           "Archive": true
//                                                         });
//                                                       } else {
//                                                         FirebaseFirestore
//                                                             .instance
//                                                             .collection("reels")
//                                                             .doc(data.id)
//                                                             .update({
//                                                           "Archive": false
//                                                         });
//                                                       }

//                                                       Navigator.of(context)
//                                                           .pop();
//                                                     },
//                                                   ),
//                                                   Divider(),
//                                                   // InkWell(
//                                                   //   child:
//                                                   //       Text("Make it Private"),
//                                                   //   onTap: () {
//                                                   //     FirebaseFirestore.instance
//                                                   //         .collection("reels")
//                                                   //         .doc(data.id)
//                                                   //         .update({
//                                                   //       "Audience": "Private"
//                                                   //     });
//                                                   //     Navigator.of(context)
//                                                   //         .pop();
//                                                   //   },
//                                                   // ),
//                                                   // Divider(),
//                                                   InkWell(
//                                                     child:
//                                                         Text("Make it Global"),
//                                                     onTap: () async {
//                                                       if (data.Audience ==
//                                                           'Public') {
//                                                         if (data.isGlobalOptionEnabled ==
//                                                             false) {
//                                                           Navigator.of(context).push(
//                                                               MaterialPageRoute(
//                                                                   builder:
//                                                                       (context) =>
//                                                                           GlobalReelBenfitScreen(
//                                                                             docid:
//                                                                                 data.id,
//                                                                           )));
//                                                         } else {
//                                                           showSnackBar(
//                                                               "Post Already Global",
//                                                               context);
//                                                         }
//                                                       } else {
//                                                         showSnackBar(
//                                                             "Private post cant be Global",
//                                                             context);
//                                                       }
//                                                     },
//                                                   ),
//                                                   const Divider(),
//                                                   InkWell(
//                                                     onTap: () {
//                                                       Firestoremethods()
//                                                           .savedvideo(data.id,
//                                                               username);
//                                                       Navigator.pop(context);
//                                                     },
//                                                     child: data.saved
//                                                             .contains(username)
//                                                         ? Text("UnSave")
//                                                         : Text("Save"),
//                                                   )
//                                                 ].toList(),
//                                               ),
//                                             ),
//                                           );
//                                         } else {
//                                           showDialog(
//                                               context: context,
//                                               builder: (context) => Dialog(
//                                                     backgroundColor: Colors
//                                                         .black
//                                                         .withOpacity(1.0),
//                                                     child: ListView(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           vertical: 16,
//                                                           horizontal: 17),
//                                                       shrinkWrap: true,
//                                                       children: [
//                                                         InkWell(
//                                                           onTap: () {
//                                                             Firestoremethods()
//                                                                 .savedvideo(
//                                                                     data.id,
//                                                                     username);
//                                                             Navigator.pop(
//                                                                 context);
//                                                           },
//                                                           child: data.saved
//                                                                   .contains(
//                                                                       username)
//                                                               ? Text("UnSave")
//                                                               : Text("Save"),
//                                                         )
//                                                       ].toList(),
//                                                     ),
//                                                   ));
//                                         }
//                                       },
//                                       icon: Icon(Icons.more_horiz),
//                                     )
//                                   ],
//                                 ),
//                                 CircleAnimation(
//                                   child: buildmusicalbum('profile photo'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         );
//       }),
//     );
//   }

//   buildmusicalbum(String profilephoto) {
//     return SizedBox(
//       width: 60,
//       height: 60,
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(11),
//             height: 50,
//             width: 50,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Colors.grey, Colors.white],
//               ),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(25),
//               child: Image(
//                 image: NetworkImage(profilephoto),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CustomScrollPhysics extends ScrollPhysics {
//   const CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

//   @override
//   CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
//     return CustomScrollPhysics(parent: buildParent(ancestor));
//   }

//   @override
//   Simulation createBallisticSimulation(
//       ScrollMetrics position, double velocity) {
//     // Adjust the simulation to introduce a much slower scroll effect
//     return ScrollSpringSimulation(
//       spring,
//       position.pixels,
//       position.pixels + (velocity * 0.1), // Adjust the factor for slower speed
//       velocity,
//       tolerance: tolerance,
//     );
//   }
// }
