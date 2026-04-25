import 'dart:io';

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

import 'package:zizzle/utils/utils.dart';
import 'package:zizzle/widgets/CircleTickIcon.dart';
import 'package:zizzle/widgets/blueTick.dart';
import 'package:zizzle/widgets/pulseloader.dart';

class ReelFeedUI extends StatefulWidget {
  @override
  State<ReelFeedUI> createState() => _ReelFeedUIState();
}

class _ReelFeedUIState extends State<ReelFeedUI> {
  late final ReelsController controller;
  late WakeWordService wakeWordService;
  var storeduid;
  var myusername;
  var email;
  void getuid() async {
    final prefs = await SharedPreferences.getInstance();
    myusername = prefs.getString('username');
    var existinguser = await FirebaseFirestore.instance
        .collection('users')
        .doc(myusername)
        .get();
    storeduid = existinguser.data()?['uid'];
    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   controller = Get.find(); // initialize first
  //   controller.fetchVideos(); // load current reels
  //   // controller.startListeningForNewReels(); // start listening for new reels
  //   getuid(); // get user id in background, doesn't block video loading
  // }
  @override
  void initState() {
    super.initState();
    controller = Get.find<ReelsController>();

    // Only fetch if not already loaded
    if (controller.videos.isEmpty) {
      print("Empty");
      controller.fetchVideos();
    }
    if (Platform.isIOS) {
      // Always listen for new reels
      controller.startListeningForNewReels();
    }
    wakeWordService = WakeWordService(context: context);
    wakeWordService.stop();
    getuid(); // fetch stored uid
  }

  void getemail(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        email = querySnapshot.docs.first.data()['email'];
        print('✅ User email: $email');
      } else {
        print('❌ No user found with username: $username');
      }
    } catch (e) {
      print('🔥 Error fetching email: $e');
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      controller.dispose();
    }
    controller.pauseAllVideos();
    controller.stopListeningForNewReels();
    controller.audioPlayer.stop();
    super.dispose();
    wakeWordService.stop();
  }

  @override
  Widget build(BuildContext context) {
    final sizes3 = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.controllers.isEmpty) {
          return const Center(child: ParticleBurstLoaderr());
        }

        return PageView.builder(
            controller: controller.pageController,
            scrollDirection: Axis.vertical,
            itemCount: controller.controllers.length,
            onPageChanged: (index) {
              // if (Platform.isAndroid) {
              //   if (!controller.allowedIndexes.contains(index)) {
              //     // Block scroll if the index is not allowed
              //     controller.pageController
              //         .jumpToPage(controller.currentIndex.value);
              //     return;
              //   }
              // } else {
              controller.onPageChanged(index);
              for (int i = 0; i < controller.controllers.length; i++) {
                if (i == index) {
                  controller.controllers[i].play();
                } else {
                  controller.controllers[i].pause();
                }
              }
            }
            // },
            ,
            itemBuilder: (context, index) {
              final videoController = controller.controllers[index];
              final reelId = controller.videos[index].id;

              if (!videoController.value.isInitialized) {
                return const Center(child: ParticleBurstLoaderr());
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reels')
                    .doc(reelId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: ParticleBurstLoaderr());
                  }

                  final data =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double originalAspectRatio =
                          videoController.value.aspectRatio;

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
                      return GestureDetector(
                        onTap: () {
                          if (videoController.value.isPlaying) {
                            videoController.pause();

                            print(
                                "aspect ratio of this video is $originalAspectRatio, adjusted to $adjustedAspectRatio");
                          } else {
                            videoController.play();
                          }
                        }, // trigger rebuild to update icon                        },
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: isAdjusted ? 150 : 0),
                                child: Container(
                                  width: videoWidth,
                                  height: videoHeight,

                                  color: Colors
                                      .black, // optional if video has transparency
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: videoWidth,
                                      height: videoHeight,
                                      child: VideoPlayer(videoController),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // if (!videoController.value.isPlaying)
                            //   Center(
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         color: Colors.black54,
                            //         shape: BoxShape.circle,
                            //       ),
                            //       padding: EdgeInsets.all(12),
                            //       child: Icon(
                            //         Icons.play_arrow,
                            //         size: 48,
                            //         color: Colors.white,
                            //       ),
                            //     ),
                            //   ),
                            // Username and Views
                            Positioned(
                              left: 16,
                              bottom: 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  data['collabreqacc'] == true
                                      ? Row(
                                          children: [
                                            buildprofile(data['profilephoto']),
                                            const SizedBox(width: 3),
                                            GestureDetector(
                                              onTap: () => {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfileScreen(
                                                                username: data[
                                                                    'username'],
                                                                uid: data[
                                                                    'uid'])))
                                              },
                                              child: Text(
                                                '${data['username']}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, right: 4),
                                              child: Text(
                                                "and",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileScreen(
                                                                  username: data[
                                                                      'collabusername'])));
                                                },
                                                child: Text(
                                                  data['collabusername'],
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            buildprofile(data['profilephoto']),
                                            const SizedBox(width: 3),
                                            GestureDetector(
                                              onTap: () => {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfileScreen(
                                                                username: data[
                                                                    'username'],
                                                                uid: data[
                                                                    'uid'])))
                                              },
                                              child: Text(
                                                '${data['username'] ?? 'Unknown'}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if ((data.containsKey('Verified') &&
                                                data['Verified'] == true))
                                              BlueTick()
                                            else if (data
                                                    .containsKey('Monetized') &&
                                                data['Monetized'] ==
                                                    'Monitized')
                                              CircleTickIcon()
                                          ],
                                        ),
                                  const SizedBox.shrink(),
                                  Text(
                                    data['caption'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox.shrink(),
                                  Row(
                                    children: [
                                      data['Location'] != ""
                                          ? Icon(Icons.location_on)
                                          : SizedBox.shrink(),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        data['Location'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child:
                                                data['orignalsongname'] != null
                                                    ? Icon(
                                                        Icons.music_note,
                                                        size: 18,
                                                        color: Colors.white,
                                                      )
                                                    : SizedBox.shrink()),
                                        TextSpan(
                                          text: data['orignalsongname'] != null
                                              ? data['videoAudioName']
                                              : data['orignalsongname'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                            // Buttons on the right
                            Positioned(
                              right: 20,
                              bottom: 65,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: (data['likes'] as List<dynamic>)
                                              .contains(myusername)
                                          ? Colors.red
                                          : Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      Firestoremethods()
                                          .LikeVideo(data['id'], myusername);
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              width: double.infinity,
                                              height: 800,
                                              child: ReelLikesScreen(
                                                uid: data['uid'],
                                                postid: data['id'],
                                              ),
                                            );
                                          });
                                    },
                                    child: Text(
                                      '${(data['likes'] as List<dynamic>?)?.length ?? 0}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  IconButton(
                                    icon: const Icon(Icons.comment,
                                        color: Colors.white, size: 28),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentReelScreen(
                                                    id: data['id'],
                                                  )));
                                    },
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    data['commentcount'].toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  data['orignalsongurl'] != null &&
                                          data['orignalsongurl']
                                              .toString()
                                              .isNotEmpty
                                      ? Icon(
                                          Icons.music_note,
                                          color: Colors.white,
                                          size: 28,
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            videoController.value.volume == 0
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              videoController.setVolume(
                                                videoController.value.volume ==
                                                        0
                                                    ? 1
                                                    : 0,
                                              );
                                            });
                                          },
                                        ),
                                  const SizedBox(height: 20),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert,
                                        color:
                                            Color.fromARGB(255, 232, 206, 206),
                                        size: 28),
                                    onPressed: () {
                                      // More options
                                      if (data['uid'] == storeduid &&
                                          data['username'] == myusername) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            backgroundColor:
                                                Colors.black.withOpacity(1.0),
                                            child: ListView(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 17),
                                              shrinkWrap: true,
                                              children: [
                                                InkWell(
                                                  child: Text("Delete Post"),
                                                  onTap: () async {
                                                    Firestoremethods()
                                                        .deletereel(data['id']);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                Divider(),
                                                InkWell(
                                                  child:
                                                      data['Archive'] == false
                                                          ? Text("Archive")
                                                          : Text("UnArchive"),
                                                  onTap: () {
                                                    if (data['Archive'] ==
                                                        false) {
                                                      print("NOt Archived");
                                                      FirebaseFirestore.instance
                                                          .collection("reels")
                                                          .doc(data['id'])
                                                          .update({
                                                        "Archive": true
                                                      });
                                                    } else {
                                                      FirebaseFirestore.instance
                                                          .collection("reels")
                                                          .doc(data['id'])
                                                          .update({
                                                        "Archive": false
                                                      });
                                                    }

                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                Divider(),
                                                // InkWell(
                                                //   child:
                                                //       Text("Make it Private"),
                                                //   onTap: () {
                                                //     FirebaseFirestore.instance
                                                //         .collection("reels")
                                                //         .doc(data.id)
                                                //         .update({
                                                //       "Audience": "Private"
                                                //     });
                                                //     Navigator.of(context)
                                                //         .pop();
                                                //   },
                                                // ),
                                                // Divider(),
                                                InkWell(
                                                  child: Text("Make it Global"),
                                                  onTap: () async {
                                                    getemail(myusername);
                                                    if (data['Audience'] ==
                                                        'Public') {
                                                      if (data['isGlobalOptionEnabled'] ==
                                                              false &&
                                                          (data['GlobalPaymentActivation'] ==
                                                              false)) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        GlobalReelBenfitScreen(
                                                                          docid:
                                                                              data['id'],
                                                                          email:
                                                                              email,
                                                                        )));
                                                      } else {
                                                        GetIt.I<AlertService>()
                                                            .showError(
                                                                'Reel Already Global');
                                                      }
                                                    } else {
                                                      GetIt.I<AlertService>()
                                                          .showError(
                                                              'Private Reel Can not be Global');
                                                    }
                                                  },
                                                ),
                                                const Divider(),
                                                InkWell(
                                                  onTap: () {
                                                    Firestoremethods()
                                                        .savedvideo(data['id'],
                                                            myusername);
                                                    Navigator.pop(context);
                                                  },
                                                  child: (data['saved'] ?? [])
                                                          .contains(myusername)
                                                      ? Text("UnSave")
                                                      : Text("Save"),
                                                )
                                              ].toList(),
                                            ),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                                  backgroundColor: Colors.black
                                                      .withOpacity(1.0),
                                                  child: ListView(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 17),
                                                    shrinkWrap: true,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Firestoremethods()
                                                              .savedvideo(
                                                                  data['id'],
                                                                  myusername);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: (data['saved'] ??
                                                                    [])
                                                                .contains(
                                                                    myusername)
                                                            ? Text("UnSave")
                                                            : Text("Save"),
                                                      )
                                                    ].toList(),
                                                  ),
                                                ));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Slim video progress bar
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            });
      }),
    );
  }
}

buildprofile(String profilephoto) {
  return SizedBox(
    width: 45,
    height: 45,
    child: Stack(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image(
              image: NetworkImage(profilephoto),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ),
  );
}
