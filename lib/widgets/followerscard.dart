import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/Screens/profile_screen.dart';
import '/model/user.dart' as u;

class FollowersCard extends StatelessWidget {
  final String photourl;
  final String username;
  final String uid;
  const FollowersCard(
      {super.key,
      required this.photourl,
      required this.username,
      required this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      child: GestureDetector(
          onTap: () async {
            final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                .collection("users")
                .where("uid", isEqualTo: uid)
                .get();
            print(uid);
            if (userSnapshot.docs.isNotEmpty) {
              final userDoc = userSnapshot.docs.first;
              final user1 = u.User.fromsnap(userDoc);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            user: user1,
                            username: username,
                            uid: uid,
                          )));
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(photourl),
              ),
              SizedBox(width: 10),
              Text(username)
            ],
          )),
    );
  }
}
