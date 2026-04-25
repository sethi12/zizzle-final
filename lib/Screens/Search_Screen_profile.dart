import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/utils/colors.dart';
import '/widgets/post_card.dart';

class SearchScreenProfile extends StatefulWidget {
  final String uid;
  final String username;

  const SearchScreenProfile({
    Key? key,
    required this.uid,
    required this.username,
  }) : super(key: key);

  @override
  _SearchScreenProfileState createState() => _SearchScreenProfileState();
}

class _SearchScreenProfileState extends State<SearchScreenProfile> {
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
        stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ParticleBurstLoaderr(),
            );
          }

          // Filter posts manually
          List<DocumentSnapshot<Map<String, dynamic>>> posts =
              snapshot.data!.docs.where((doc) {
            final data = doc.data();
            return data['isGlobalOptionEnabled'] == true ||
                data['GlobalPaymentActivation'] == true;
          }).toList();

          // Sort to prioritize this user’s posts
          posts.sort((a, b) {
            if (a['uid'] == widget.uid && a['username'] == widget.username) {
              return -1;
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
