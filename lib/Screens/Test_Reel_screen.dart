import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/widgets/reel_card.dart';
import '../utils/colors.dart';

class TestReelScreen extends StatefulWidget {
  const TestReelScreen({Key? key}) : super(key: key);

  @override
  State<TestReelScreen> createState() => _TestReelScreenState();
}

class _TestReelScreenState extends State<TestReelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Zizzle",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color.fromRGBO(10, 19, 41, 1.0),
              mobileBackgroundColor,
            ],
            center: Alignment.topCenter,
            radius: 1.5,
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection("reels").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: ParticleBurstLoaderr());
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
                      Icons.videocam_off_outlined,
                      size: 80,
                      color: secondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No reels available.',
                      style: TextStyle(
                        fontSize: 18,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Manual filtering for both fields
            final List<DocumentSnapshot<Map<String, dynamic>>> globalReels =
                snapshot.data!.docs.where((reel) {
              final data = reel.data();
              return data['isGlobalOptionEnabled'] == true ||
                  data['GlobalPaymentActivation'] == true;
            }).toList();

            if (globalReels.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off_outlined,
                      size: 80,
                      color: secondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No global reels found.',
                      style: TextStyle(
                        fontSize: 18,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: globalReels.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return ReelCard(
                  snap: globalReels[index].data(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
