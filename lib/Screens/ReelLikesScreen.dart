import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/widgets/followerscard.dart';
import 'package:flutter/material.dart';

class ReelLikesScreen extends StatefulWidget {
  final String uid;
  final String postid;
  const ReelLikesScreen({Key? key, required this.uid, required this.postid})
      : super(key: key);

  @override
  State<ReelLikesScreen> createState() => _ReelLikesScreenState();
}

class _ReelLikesScreenState extends State<ReelLikesScreen> {
  var username;

  @override
  void initState() {
    super.initState();
    getUsername(widget.uid);
    print(widget.postid);
  }

  Future<void> getUsername(String uid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: uid)
              .get();

      if (querySnapshot.size > 0) {
        var data = querySnapshot.docs.first.data();
        setState(() {
          username = data['username'];
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Likes ')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reels')
            .doc(widget.postid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ParticleBurstLoaderr(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Post not found.'),
            );
          }

          var postData = snapshot.data!.data();
          var likes = postData?['likes'] ?? [];
          if (likes.isEmpty) {
            return const Center(
              child: Text('No likes found.'),
            );
          }

          return ListView.builder(
            itemCount: likes.length,
            itemBuilder: (context, index) {
              var userId = likes[index];
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }
                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading user details'),
                    );
                  }
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('User details not found'),
                    );
                  }
                  var userDetails = userSnapshot.data!.data()!;
                  return FollowersCard(
                    photourl: userDetails['photourl'] ?? '',
                    username: userDetails['username'] ?? '',
                    uid: userDetails['uid'] ?? '',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
