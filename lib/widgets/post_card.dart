import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zizzle/services/alert_service.dart';
import 'package:zizzle/services/navigation_service.dart';
import 'package:zizzle/songs/SpotifyService.dart';
import 'package:zizzle/widgets/blueTick.dart';
import '/Screens/Global_benefits_screen.dart';
import '/Screens/LikesScreen.dart';
import '/Screens/comment_screen.dart';
import '/Screens/profile_screen.dart';
import '/model/user.dart';
import '/resources/firestoremethods.dart';
import '/utils/colors.dart';
import '/utils/utils.dart';
import '/widgets/CircleTickIcon.dart';
import '/widgets/like_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ads_manager.dart';

class PostCard extends StatefulWidget {
  final snap;
  final String? myprofile;
  const PostCard({super.key, required this.snap, this.myprofile});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool islikeanimating = false;
  String? username;
  String? email;
  var storeduid;
  int commentlength = 0;
  var Monetization;
  final SpotifyService spotifyService = SpotifyService();
  String? currentlyPlayingTrack;
  late Navigationservice _navigationservice;
  late AlertService _alertService;
  final GetIt _getIt = GetIt.instance;
  String? _currentlyPlayingUrl;

  StreamSubscription<Duration>? _positionSubscription; // <-- And this
  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcomments();
    Admanager().loadrewardedad();
    _navigationservice = _getIt.get<Navigationservice>();
    _alertService = _getIt.get<AlertService>();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _currentlyPlayingUrl = null;
        });
      }
    });
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

  void getcomments() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.snap['postid'])
          .collection('Comments')
          .get();
      commentlength = querySnapshot.docs.length;
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString('username');
      print(username);
      var existingUser = await FirebaseFirestore.instance
          .collection("users")
          .doc(username)
          .get();
      storeduid = existingUser.data()?['uid'];
      print(storeduid);
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  void _playPause(String url, int startDuration, int endDuration) async {
    final isSameSong = _currentlyPlayingUrl == url;

    // If the same song is playing, pause it
    if (isSameSong && _audioPlayer.playing) {
      await _audioPlayer.pause();
      _currentlyPlayingUrl = null;
      _positionSubscription?.cancel();
      setState(() {}); // Update UI
      return;
    }

    // Always stop previous song
    await _audioPlayer.stop();
    _positionSubscription?.cancel();

    // Set new song immediately to update icon
    _currentlyPlayingUrl = url;
    setState(() {});

    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.seek(Duration(seconds: startDuration));
      await _audioPlayer.play();

      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        if (position.inSeconds >= endDuration) {
          _audioPlayer.pause();
          _audioPlayer.seek(Duration(seconds: startDuration));
          _currentlyPlayingUrl = null;
          setState(() {}); // Reset icon
        }
      });
    } catch (e) {
      print("Audio play error: $e");
      _currentlyPlayingUrl = null;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mobileBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                  .copyWith(right: 0),
              child: Row(children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.myprofile == null
                        ? widget.snap['profimage']
                        : widget.myprofile,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: widget.snap['collabreqacc'] == false
                                ? Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileScreen(
                                                        username: widget
                                                            .snap['username'],
                                                        uid: widget.snap["uid"],
                                                      )));
                                        },
                                        child: Text(
                                          "${widget.snap['username']}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // ✅ Check if 'Verified' exists and is true
                                      if (widget.snap.containsKey('Verified') &&
                                          widget.snap['Verified'] == true)
                                        BlueTick()

                                      // ✅ If 'Verified' is not true, check for 'Monetized'
                                      else if (widget.snap
                                              .containsKey('Monetized') &&
                                          widget.snap['Monetized'] ==
                                              'Monitized')
                                        CircleTickIcon(),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileScreen(
                                                          username: widget
                                                              .snap['username'],
                                                          uid: widget
                                                              .snap["uid"],
                                                        )));
                                          },
                                          child: Text(widget.snap['username'])),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 14, right: 4),
                                        child: Text("and"),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileScreen(
                                                            username: widget
                                                                    .snap[
                                                                'collabusername'])));
                                          },
                                          child: Text(
                                              widget.snap['collabusername'])),
                                    ],
                                  ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.snap['Location'],
                            ),
                          ),
                          widget.snap['orignalsongname'] != null &&
                                  widget.snap['orignalsongname'] != ""
                              ? Row(
                                  children: [
                                    Icon(Icons.music_note),
                                    Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                            widget.snap['orignalsongname'])),
                                  ],
                                )
                              : Text(""),
                        ],
                      )
                    ],
                  ),
                )),
                storeduid == widget.snap['uid']
                    ? IconButton(
                        onPressed: () {
                          if (storeduid == widget.snap['uid']) {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor:
                                    Colors.grey[900], // Dark, modern background
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Delete Post Option
                                      ListTile(
                                        leading: const Icon(
                                            Icons.delete_forever,
                                            color: Colors.redAccent),
                                        title: const Text(
                                          "Delete Post",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () async {
                                          Firestoremethods().deletepost(
                                              widget.snap['postid']);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      const Divider(
                                          color: Colors.white12,
                                          indent: 16,
                                          endIndent: 16),

                                      // Archive/Unarchive Option
                                      ListTile(
                                        leading: Icon(
                                          widget.snap["Archive"] == false
                                              ? Icons.archive
                                              : Icons.unarchive,
                                          color: Colors.white,
                                        ),
                                        title: Text(
                                          widget.snap["Archive"] == false
                                              ? "Archive"
                                              : "UnArchive",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () {
                                          if (widget.snap["Archive"] == false) {
                                            FirebaseFirestore.instance
                                                .collection("Posts")
                                                .doc(widget.snap['postid'])
                                                .update({"Archive": true});
                                          } else {
                                            FirebaseFirestore.instance
                                                .collection("Posts")
                                                .doc(widget.snap['postid'])
                                                .update({"Archive": false});
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const Divider(
                                          color: Colors.white12,
                                          indent: 16,
                                          endIndent: 16),

                                      // Make it Global Option
                                      ListTile(
                                        leading: const Icon(Icons.public,
                                            color: Colors.blueAccent),
                                        title: const Text(
                                          "Make it Global",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () {
                                          if (widget.snap['Audience'] ==
                                              'Public') {
                                            if ((widget.snap[
                                                        "isGlobalOptionEnabled"] ==
                                                    false) &&
                                                (widget.snap[
                                                        "GlobalPaymentActivation"] !=
                                                    true)) {
                                              getemail(username!);
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      GlobalBenefitsScreen(
                                                    docid:
                                                        widget.snap['postid'],
                                                    email: email,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              _alertService.showToast(
                                                text: "Post Already Global",
                                                icon: Icons.error,
                                              );
                                            }
                                          } else {
                                            _alertService.showToast(
                                              text:
                                                  "Private Post can not be Global",
                                              icon: Icons.error,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // yet to doo............
                          }
                        },
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      )
                    : SizedBox.shrink()
              ])
              //Image Section
              ),
          GestureDetector(
            onDoubleTap: () async {
              final prefs = await SharedPreferences.getInstance();
              username = prefs.getString('username');
              await Firestoremethods().LikePost(
                  widget.snap['postid'],
                  username!,
                  widget.snap['likes'],
                  widget.snap["username"],
                  widget.snap["posturl"],
                  widget.snap["profimage"]);
              setState(() {
                islikeanimating = true;
              });
            },
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                width: double.infinity,
                child: Stack(
                  children: [
                    Image.network(
                      widget.snap['posturl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    widget.snap['orignalsongurl'] != null &&
                            widget.snap['orignalsongurl'] != ""
                        ? Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                _playPause(
                                    widget.snap['orignalsongurl'],
                                    widget.snap['startduration'],
                                    widget.snap['endduration']);
                              },
                              child: Icon(
                                _currentlyPlayingUrl ==
                                        widget.snap['orignalsongurl']
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: islikeanimating ? 1 : 0,
                child: LikeAnimation(
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                  ),
                  isAnimating: islikeanimating,
                  duration: const Duration(milliseconds: 400),
                  onEnd: () {
                    setState(() {
                      islikeanimating = false;
                    });
                  },
                ),
              ),
            ]),
          ),
          //LIke comment share
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(username),
                smallLike: true,
                child: IconButton(
                    onPressed: () async {
                      // final prefs = await SharedPreferences.getInstance();
                      // username = prefs.getString('username');
                      await Firestoremethods().LikePost(
                          widget.snap['postid'],
                          username!,
                          widget.snap['likes'],
                          widget.snap["username"],
                          widget.snap["posturl"],
                          widget.snap["profimage"]);
                    },
                    icon: widget.snap['likes'].contains(username)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 29,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            size: 29,
                          )),
              ),
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                            snap: widget.snap,
                          ))),
                  icon: const Icon(
                    Icons.comment_outlined,
                    size: 29,
                  )),
              // IconButton(
              //     onPressed: () {},
              //     icon: const Icon(
              //       Icons.send,
              //       size: 26,
              //     )),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    color: widget.snap['saved'].contains(username)
                        ? Colors.red
                        : Colors.white,
                  ),
                  onPressed: () {
                    Firestoremethods().savedpost(
                        widget.snap['postid'], username!, widget.snap['saved']);
                  },
                ),
              ))
            ],
          ),

          //Description And Number of comments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                width: double.infinity,
                                height: 800,
                                child: LikesScreen(
                                  uid: widget.snap['uid'],
                                  postid: widget.snap['postid'],
                                ),
                              );
                            });
                      },
                      child: Text(
                        '${widget.snap['likes'].length} likes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "  ${widget.snap['caption']}",
                          ),
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              CommentsScreen(snap: widget.snap))),
                      child: Text(
                        "View all $commentlength comments",
                        style: const TextStyle(
                            fontSize: 16, color: secondaryColor),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datepublished'].toDate()),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
