import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Screens/Splash_screen.dart';
import '/resources/firestoremethods.dart';
import '/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final snap;
  const CommentsScreen({super.key, required this.snap});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentcontrolller = TextEditingController();
  var username;
  var profilephoto;
  var uid;
  bool _isloading = false;

  @override
  void dispose() {
    super.dispose();
    _commentcontrolller.dispose();
  }

  @override
  void initState() {
    super.initState();
    getuserdata();
  }

  Future<void> getuserdata() async {
    setState(() {
      _isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    var existinguser = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    profilephoto = existinguser.data()?['photourl'];
    uid = existinguser.data()?['uid'];
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? const Center(
            child: ParticleBurstLoaderr(),
          )
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: const Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mobileBackgroundColor,
                    Color.fromRGBO(10, 19, 41, 1.0),
                    Color.fromRGBO(10, 19, 41, 1.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Posts')
                    .doc(widget.snap['postid'])
                    .collection('Comments')
                    .orderBy('datepublished', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No comments yet. Be the first to comment!",
                        style: TextStyle(color: secondaryColor),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) => CommentCard(
                      snap: snapshot.data!.docs[index].data(),
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                height: kToolbarHeight,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilephoto),
                      radius: 18,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _commentcontrolller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if (_commentcontrolller.text.trim().isNotEmpty) {
                          await Firestoremethods().postcomment(
                              widget.snap['postid'],
                              _commentcontrolller.text,
                              uid,
                              username,
                              profilephoto);
                          setState(() {
                            _commentcontrolller.text = "";
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
