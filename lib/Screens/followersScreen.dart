import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import 'dart:ui';
import '../widgets/followerscard.dart';
import '../utils/colors.dart';

class FollowersScreen extends StatefulWidget {
  final uid;
  const FollowersScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  var username;
  @override
  void initState() {
    super.initState();
    getUsername(widget.uid);
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getFollowerDetails(
      String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color.fromRGBO(101, 131, 237, 1.0),
              Color.fromRGBO(10, 19, 41, 1.0),
            ],
            center: Alignment.topLeft,
            radius: 1.5,
          ),
        ),
        child: Stack(
          children: [
            _buildContent(),
            _buildAppBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: FutureBuilder(
                future: Future.value(username),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const Text(
                      'Followers',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    );
                  }
                  return Text(
                    'Followers of ${snapshot.data}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                  height: 100, width: 100, child: ParticleBurstLoaderr()),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: secondaryColor),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'User not found.',
                style: TextStyle(color: secondaryColor),
              ),
            );
          }

          var userData = snapshot.data!.data();
          var followers = userData?['followers'] ?? [];
          if (followers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: secondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No followers found.',
                    style: TextStyle(
                      fontSize: 18,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: kToolbarHeight + 20),
              itemCount: followers.length,
              itemBuilder: (context, index) {
                var followerId = followers[index];
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _getFollowerDetails(followerId),
                  builder: (context, detailsSnapshot) {
                    if (detailsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                          height: 70,
                          alignment: Alignment.center,
                          child: const ParticleBurstLoaderr());
                    }
                    if (detailsSnapshot.hasError) {
                      return const ListTile(
                        title: Text(
                          'Error loading follower details',
                          style: TextStyle(color: secondaryColor),
                        ),
                      );
                    }
                    if (!detailsSnapshot.hasData ||
                        !detailsSnapshot.data!.exists) {
                      return const ListTile(
                        title: Text(
                          'Follower details not found',
                          style: TextStyle(color: secondaryColor),
                        ),
                      );
                    }
                    var details = detailsSnapshot.data!.data()!;
                    return FollowersCard(
                      photourl: details['photourl'] ?? '',
                      username: details['username'] ?? '',
                      uid: details['uid'] ?? '',
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
