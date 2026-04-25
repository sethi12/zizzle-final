import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/Controllers/Search_video.dart';
import 'package:zizzle/Screens/Archive_post_screen.dart';
import 'package:zizzle/Screens/Profile_reel_screen.dart';
import 'package:zizzle/Screens/Reel_Screen_Search.dart';
import 'package:zizzle/Screens/Search_Screen_profile.dart';
import 'package:zizzle/Screens/savedpostscreen.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import 'package:zizzle/widgets/videoplayersearch.dart';

class ArchiveScreen extends StatefulWidget {
  final username;
  const ArchiveScreen({super.key, required this.username});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late SearchVideoController videoController;
  late List<DocumentSnapshot<Map<String, dynamic>>> filteredPosts;
  late List<DocumentSnapshot<Map<String, dynamic>>> filteredReels;

  Future<void> fetchData() async {
    // Fetch data for 'Posts' where 'isGlobalOptionEnabled' is true
    QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore
        .instance
        .collection('Posts')
        .where("username", isEqualTo: widget.username)
        .where("Archive", isEqualTo: true)
        .get();

    QuerySnapshot<Map<String, dynamic>> reelsSnapshot = await FirebaseFirestore
        .instance
        .collection('reels')
        .where("username", isEqualTo: widget.username)
        .where("Archive", isEqualTo: true)
        .get();

    // Now, you can work with the filtered postsSnapshot and reelsSnapshot where 'isGlobalOptionEnabled' is true
    filteredPosts = postsSnapshot.docs;
    filteredReels = reelsSnapshot.docs;

    // ... Rest of your code handling the fetched data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Archives ${widget.username}"),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: const ParticleBurstLoaderr(),
            );
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: filteredPosts.length + filteredReels.length,
            itemBuilder: (context, index) {
              if (index < filteredPosts.length) {
                // Display Posts
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ArchivePostScreen(
                          uid: filteredPosts[index]['uid'],
                          username: filteredPosts[index]['username'],
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    filteredPosts[index]['posturl'],
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                // Display Reels Thumbnails
                int reelsIndex = index - filteredPosts.length;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileVideoScreen(
                            uid: filteredReels[reelsIndex]['uid'],
                            videoid: filteredReels[reelsIndex]['id']),
                      ),
                    );
                    print(filteredReels[reelsIndex]['uid']);
                    print(filteredReels[reelsIndex]['id']);
                  },
                  child: VideplayerSearch(
                    videourl: filteredReels[reelsIndex]['videourl'],
                    id: filteredReels[reelsIndex]['id'],
                    thumnail: filteredReels[reelsIndex]['thumbnail'],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
