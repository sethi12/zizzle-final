import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '/widgets/CollabedReel.dart';
import '/widgets/Collabedpost.dart';
import '../utils/colors.dart';

class CollabReelScreen extends StatefulWidget {
  var username;
  CollabReelScreen({super.key, required this.username});

  @override
  State<CollabReelScreen> createState() => _CollabReelScreenState();
}

class _CollabReelScreenState extends State<CollabReelScreen> {
  // A simple widget to simulate a shimmering loading card
  Widget _buildShimmerLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 120,
            height: 12,
            color: secondaryColor.withOpacity(0.2),
          ),
          const SizedBox(height: 5),
          Container(
            width: 80,
            height: 12,
            color: secondaryColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Text(
                "Reel Collab Requests",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
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
        child: SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('CollabRequests')
                .where('reelid', isNull: false)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  itemCount: 3,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, index) => _buildShimmerLoadingCard(),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_camera_front_outlined,
                        size: 80,
                        color: secondaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No reel collaboration requests.',
                        style: TextStyle(
                          fontSize: 18,
                          color: secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              List<DocumentSnapshot<Map<String, dynamic>>>
                  collabedRequestReels = snapshot.data!.docs
                      .where((collabRequest) =>
                          collabRequest['collabusername'] == widget.username)
                      .toList();

              if (collabedRequestReels.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_camera_front_outlined,
                        size: 80,
                        color: secondaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No reel collaboration requests for you.',
                        style: TextStyle(
                          fontSize: 18,
                          color: secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: collabedRequestReels.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return CollabedReel(snap: collabedRequestReels[index].data());
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
