import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/utils/colors.dart';
import 'package:zizzle/widgets/post_card.dart';
import 'package:zizzle/widgets/pulseloader.dart';

class Profileimagecheckprivatescreen extends StatelessWidget {
  final String uid;
  const Profileimagecheckprivatescreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    print(uid);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: Text(
          "Zizzle",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('uid', isEqualTo: uid)
            .where('Audience', isEqualTo: "Private")
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ParticleBurstLoaderr(),
            );
          }

          // Null safety check for snapshot data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No posts available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final snap = snapshot.data!.docs[index].data();

              // Ensure `snap` has required fields
              if (snap == null || snap.isEmpty) {
                return const SizedBox
                    .shrink(); // Skip invalid or empty documents
              }

              return PostCard(
                snap: snap,
              );
            },
          );
        },
      ),
    );
  }
}
