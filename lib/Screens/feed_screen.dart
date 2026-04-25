import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:zizzle/Controllers/reelsfeed.dart';
import 'package:zizzle/Screens/notificationscreen.dart';
import 'package:zizzle/utils/utils.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Screens/Home_screen.dart';
import '/Screens/Test_Reel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ads_manager.dart';
import '../services/navigation_service.dart';
import '../utils/colors.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final GetIt _getIt = GetIt.instance;
  late Navigationservice _navigationservice;
  var username;
  var followingList;
  bool hasCollabRequests = false;
  bool _isloaded = false;
  void getusername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    print(username);
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (userSnapshot.exists) {
      followingList = userSnapshot['following'] != null
          ? List.from(userSnapshot['following'])
          : [];
      print('Following List: $followingList');
      setState(() {
        _isloaded = true;
      });
    } else {
      print('User document not found for username: $username');
    }
  }

  @override
  void initState() {
    super.initState();
    getusername();
    Admanager().loadrewardedad();
    _navigationservice = _getIt.get<Navigationservice>();
    checkCollabRequests();
    // Get.lazyPut(() => ReelsController(), fenix: true);
  }

  Future<void> checkCollabRequests() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("CollabRequests")
        .where('collabusername', isEqualTo: username)
        .get();

    setState(() {
      hasCollabRequests = querySnapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isloaded
        ? Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  const Text(
                    "Zizzle",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 25,
                      color: primaryColor,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TestReelScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Reels",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        checkCollabRequests();
                        if (!hasCollabRequests) {
                          showSnackBar("No Collab Request found", context);
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Notificationscreen(username: username)));
                        }
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                    ),
                    if (hasCollabRequests)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _navigationservice.pushnamed("/home");
                  },
                ),
              ],
            ),
            body: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > 0) {
                  _navigationservice.pushnamed("/home");
                }
              },
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Posts').snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: ParticleBurstLoaderr(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "An error occurred. Please try again.",
                        style: TextStyle(color: secondaryColor),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "No posts to show. Start following people to see their posts!",
                          style: TextStyle(fontSize: 16, color: secondaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  List<DocumentSnapshot<Map<String, dynamic>>> globalPosts =
                      snapshot.data!.docs.where((post) {
                    final data = post.data();
                    return (data?['isGlobalOptionEnabled'] == true ||
                        data?['GlobalPaymentActivation'] == true);
                  }).toList();

                  List<DocumentSnapshot<Map<String, dynamic>>> followingPosts =
                      snapshot.data!.docs.where((post) {
                    final data = post.data();
                    return data != null &&
                        data['username'] != null &&
                        (followingList?.contains(data['username']) ?? false) &&
                        data['Audience'] == 'Public' &&
                        data['Archive'] == false;
                  }).toList();

                  List<DocumentSnapshot<Map<String, dynamic>>> combinedPosts = [
                    ...globalPosts,
                    ...followingPosts
                  ];

                  if (combinedPosts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "No posts to show. Follow users or wait for new content!",
                          style: TextStyle(fontSize: 16, color: secondaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                      itemCount: combinedPosts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          snap: combinedPosts[index].data(),
                        );
                      });
                },
              ),
            ))
        : const Center(
            child: ParticleBurstLoaderr(),
          );
  }
}
