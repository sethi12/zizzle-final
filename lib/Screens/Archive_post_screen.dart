import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/utils/colors.dart';
import '/widgets/post_card.dart';

class ArchivePostScreen extends StatefulWidget {
  final String uid;
  final String username;

  const ArchivePostScreen({
    Key? key,
    required this.uid,
    required this.username,
  }) : super(key: key);

  @override
  _ArchivePostScreenState createState() => _ArchivePostScreenState();
}

class _ArchivePostScreenState extends State<ArchivePostScreen> {
  @override
  Widget build(BuildContext context) {
    print(widget.uid);
    print(widget.username);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: Text(
            "Zizzle",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          )),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where("Archive", isEqualTo: true)
            .where("username", isEqualTo: widget.username)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ParticleBurstLoaderr(),
            );
          }

          List<DocumentSnapshot<Map<String, dynamic>>> posts =
              snapshot.data!.docs;

          posts.sort((a, b) {
            if (a['uid'] == widget.uid && a['username'] == widget.username) {
              return -1; // Put post with specific uid and username at the beginning
            } else if (b['uid'] == widget.uid &&
                b['username'] == widget.username) {
              return 1;
            } else {
              return 0;
            }
          });

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(snap: posts[index].data());
            },
          );
        },
      ),
    );
  }
}
