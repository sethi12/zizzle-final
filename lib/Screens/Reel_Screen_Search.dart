import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/CircleTickIcon.dart';
import 'package:zizzle/widgets/blueTick.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Controllers/Search_video.dart';
import '/Controllers/profile_video_controller.dart';
import '/Controllers/video_controller.dart';
import '/Screens/Comment_reel_screen.dart';
import '/Screens/profile_screen.dart';
import '/resources/firestoremethods.dart';
import '/widgets/Video_player.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ads_manager.dart';
import '../model/reel.dart';
import 'ReelLikesScreen.dart';

class SearchVideoScreen extends StatefulWidget {
  final uid;
  final videoid;
  SearchVideoScreen({Key? key, required this.uid, required this.videoid})
      : super(key: key);

  @override
  State<SearchVideoScreen> createState() => _SearchVideoScreenState();
}

class _SearchVideoScreenState extends State<SearchVideoScreen> {
  late var data;
  late final SearchVideoController videoController;
  var storeduid;
  var username;
  int scrollcount = 0;
  Map<String, dynamic> extraUserData = {};
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

  @override
  void initState() {
    super.initState();
    initialstate();
    Admanager().loadintad();
    // videoController.preloadVideos();
    fetchExtraUserData(widget.uid);
  }

  void fetchExtraUserData(String uid) async {
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('reels')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (userSnap.docs.isNotEmpty) {
        setState(() {
          extraUserData = userSnap.docs.first.data();
        });
      }
      print("extrauserdata is fetched succsessfully $extraUserData");
    } catch (e) {
      print('Error fetching extra user data: $e');
    }
  }

  void initialstate() async {
    videoController = Get.put(SearchVideoController(
      selectedvideoid: widget.videoid,
    ));
    if (videoController.selectedvideoid != widget.videoid) {
      videoController.updateData(
        newvideoid: widget.videoid,
      );
      print("true");
    }
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    var existinguser = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    storeduid = existinguser.data()?['uid'];
    print(storeduid);
    print(widget.uid);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: StreamBuilder<List<Video>>(
      stream: videoController.videoListStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('StreamBuilder: Waiting for data...');
          return ParticleBurstLoaderr();
        }

        if (snapshot.hasError) {
          print('StreamBuilder Error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('StreamBuilder: No data available.');
          return Center(
            child: Text('No data available.'),
          );
        }
        data =
            snapshot.data![0]; // Assuming you want the first item in the list

        return PageView.builder(
          itemCount: snapshot.data!.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            scrollcount++;
            if (scrollcount % 5 == 0) {
              Admanager().showintad();
            }
          },
          itemBuilder: (context, index) {
            data = snapshot.data![index];
            print("data uid is ${data.uid}");
            return Stack(
              children: [
                data.orignalsongurl == ""
                    ? VideoPlayerItem(
                        videourl: data.videourl,
                        id: data.id,
                        thumbnail: data.thumbnail,

                        // Pass the current index
                      )
                    : VideoPlayerItem(
                        videourl: data.videourl,
                        id: data.id,
                        thumbnail: data.thumbnail,
                        spotifyPreviewUrl: data.orignalsongurl,
                        endduration: data.endAudioDuration,
                        startduration: data.startAudioDuration,
                      ),
                Column(
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    data.collabreqacc == false
                                        ? Row(
                                            children: [
                                              buildprofile(data.profilephoto),
                                              const SizedBox(width: 3),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileScreen(
                                                                  username: data
                                                                      .username,
                                                                  uid: data
                                                                      .uid)));
                                                },
                                                child: Text(
                                                  data.username,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (extraUserData.containsKey(
                                                      'Verified') &&
                                                  extraUserData['Verified'] ==
                                                      true)
                                                BlueTick()
                                              else if (extraUserData
                                                      .containsKey(
                                                          'Monetized') &&
                                                  extraUserData['Monetized'] ==
                                                      'Monitized')
                                                CircleTickIcon()
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              buildprofile(data.profilephoto),
                                              const SizedBox(width: 3),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProfileScreen(
                                                                    username: data
                                                                        .username,
                                                                    uid: data
                                                                        .uid)));
                                                  },
                                                  child: Text(
                                                    data.username,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4, right: 4),
                                                child: Text(
                                                  "and",
                                                  style: TextStyle(
                                                    fontSize: 14,
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
                                                                    username: data
                                                                        .collabusername)));
                                                  },
                                                  child: Text(
                                                    data.collabusername,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                    Text(
                                      data.caption,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    data.Location != ""
                                        ? Text.rich(
                                            TextSpan(children: [
                                              WidgetSpan(
                                                alignment:
                                                    PlaceholderAlignment.middle,
                                                child: Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              TextSpan(
                                                  text: data.Location,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ))
                                            ]),
                                          )
                                        : SizedBox.shrink(),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Icon(
                                              Icons.music_note,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.orignalsongname != null
                                                ? data.videoAudioName
                                                : data.orignalsongname,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 0),
                            width: 60,
                            margin: EdgeInsets.only(top: size.height / 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => Firestoremethods()
                                          .LikeVideo(data.id, username),
                                      child: Icon(
                                        Icons.favorite,
                                        size: 32,
                                        color: data.likes.contains(username)
                                            ? Colors.red
                                            : Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
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
                                                  uid: data.uid,
                                                  postid: data.id,
                                                ),
                                              );
                                            });
                                      },
                                      child: Text(
                                        data.likes.length.toString(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentReelScreen(
                                                    id: data.id,
                                                  ))),
                                      child: Icon(
                                        Icons.comment,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      data.commentcount.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                data.orignalsongurl != null &&
                                        data.orignalsongurl
                                            .toString()
                                            .isNotEmpty
                                    ? Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 28,
                                      )
                                    : Icon(
                                        Icons.volume_up,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                const SizedBox(height: 20),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (data.uid == storeduid) {
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
                                                          .deletereel(data.id);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  Divider(),
                                                  InkWell(
                                                    child: data.Archive == false
                                                        ? Text("Archive")
                                                        : Text("UnArchive"),
                                                    onTap: () {
                                                      if (data.Archive ==
                                                          false) {
                                                        print("NOt Archived");
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("reels")
                                                            .doc(data.id)
                                                            .update({
                                                          "Archive": true
                                                        });
                                                      } else {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("reels")
                                                            .doc(data.id)
                                                            .update({
                                                          "Archive": false
                                                        });
                                                      }

                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  // Divider(),
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
                                                  Divider(),
                                                  InkWell(
                                                    onTap: () {
                                                      Firestoremethods()
                                                          .savedvideo(data.id,
                                                              username);
                                                      Navigator.pop(context);
                                                    },
                                                    child: data.saved
                                                            .contains(username)
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
                                                    backgroundColor: Colors
                                                        .black
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
                                                                    data.id,
                                                                    username);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: data.saved
                                                                  .contains(
                                                                      username)
                                                              ? Text("UnSave")
                                                              : Text("Save"),
                                                        )
                                                      ].toList(),
                                                    ),
                                                  ));
                                        }
                                      },
                                      icon: Icon(Icons.more_vert),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ));
  }

  buildmusicalbum(String profilephoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(11),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.grey, Colors.white],
              ),
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
}
