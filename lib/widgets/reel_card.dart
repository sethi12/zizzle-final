import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/CircleTickIcon.dart';
import 'package:zizzle/widgets/blueTick.dart';
import '/Screens/Comment_reel_screen.dart';
import '/Screens/Profile_reel_screen.dart';
import '/Screens/Splash_screen.dart';
import '/resources/firestoremethods.dart';
import '/widgets/Video_player.dart';
import '/widgets/videoplayersearch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/Reel_Screen_Search.dart';
import '../Screens/profile_screen.dart';

class ReelCard extends StatefulWidget {
  final snap;
  const ReelCard({super.key, required this.snap});

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  var username;
  void getusername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getusername();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.snap['profilephoto']),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: widget.snap['collabreqacc'] == false
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                            username: widget.snap['username'],
                                            uid: widget.snap["uid"],
                                          )));
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "${widget.snap['username']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // ✅ Check if 'Verified' exists and is true
                                    if (widget.snap.containsKey('Verified') &&
                                        widget.snap['Verified'] == true)
                                      BlueTick()

                                    // ✅ If 'Verified' is not true, check for 'Monetized'
                                    else if (widget.snap
                                            .containsKey('Monetized') &&
                                        widget.snap['Monetized'] == 'Monitized')
                                      CircleTickIcon(),
                                  ],
                                ),
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
                                                      uid: widget.snap["uid"],
                                                    )));
                                      },
                                      child: Text(widget.snap['username'])),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, right: 4),
                                    child: Text("and"),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileScreen(
                                                        username: widget.snap[
                                                            'collabusername'])));
                                      },
                                      child:
                                          Text(widget.snap['collabusername'])),
                                ],
                              ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchVideoScreen(
                        uid: widget.snap['uid'],
                        videoid: widget.snap['id'],
                      )));
            },
            child: Container(
                width: double.infinity,
                height: 450,
                child: VideplayerSearch(
                  videourl: widget.snap['videourl'],
                  id: widget.snap['id'],
                  thumnail: widget.snap['thumbnail'],
                )),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: GestureDetector(
                    onTap: () {
                      Firestoremethods().LikeVideo(widget.snap['id'], username);
                    },
                    child: Icon(
                      Icons.favorite,
                      size: 34,
                      color: widget.snap['likes'].contains(username)
                          ? Colors.red
                          : Colors.white.withOpacity(0.3),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CommentReelScreen(id: widget.snap['id'])));
                  },
                  child: Icon(
                    Icons.comment_bank_outlined,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
