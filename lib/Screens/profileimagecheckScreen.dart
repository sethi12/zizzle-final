import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/utils/colors.dart';
import '/widgets/post_card.dart';

class ProfiileImageCheckScreen extends StatelessWidget {
  final uid;
  const ProfiileImageCheckScreen({super.key, required this.uid});

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
          actions: []),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('uid', isEqualTo: uid)
            .where('Audience', isEqualTo: 'Public')
            .where("Archive", isEqualTo: false)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ParticleBurstLoaderr(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCard(
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
    );
  }
}
