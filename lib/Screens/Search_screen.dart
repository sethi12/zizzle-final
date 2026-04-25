// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:zizzle/widgets/blueTick.dart';
// import '/Controllers/Search_video.dart';
// import '/Screens/Reel_Screen_Search.dart';
// import '/Screens/Search_Screen_profile.dart';
// import '/Screens/profile_screen.dart';
// import '/utils/colors.dart';
// import '/widgets/CircleTickIcon.dart';
// import '/widgets/CircleTickIconSearch.dart';
// import '/widgets/Video_player.dart';
// import '/widgets/post_card.dart';
// import '/model/user.dart' as u;
// import '../widgets/videoplayersearch.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//   bool isShowUsers = false;
//   late SearchVideoController videoController;
//   var isMonetized;
//   var isverified;
//   late List<DocumentSnapshot<Map<String, dynamic>>> filteredPosts;
//   late List<DocumentSnapshot<Map<String, dynamic>>> filteredReels;

//   @override
//   void initState() {
//     super.initState();
//   }

//   // Future<void> fetchData() async {
//   //   // Fetch data for 'Posts' where 'isGlobalOptionEnabled' is true
//   //   QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore
//   //       .instance
//   //       .collection('Posts')
//   //       .where('isGlobalOptionEnabled', isEqualTo: true)
//   //       .get();

//   //   // Fetch data for 'reels' where 'isGlobalOptionEnabled' is true
//   //   QuerySnapshot<Map<String, dynamic>> reelsSnapshot = await FirebaseFirestore
//   //       .instance
//   //       .collection('reels')
//   //       .where('isGlobalOptionEnabled', isEqualTo: true)
//   //       .get();

//   //   // Now, you can work with the filtered postsSnapshot and reelsSnapshot where 'isGlobalOptionEnabled' is true
//   //   filteredPosts = postsSnapshot.docs;
//   //   filteredReels = reelsSnapshot.docs;

//   //   // ... Rest of your code handling the fetched data
//   // }

//   Future<void> fetchData() async {
//     // Fetch posts where either global option or payment activation is true
//     QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore
//         .instance
//         .collection('Posts')
//         .where('Archive', isEqualTo: false)
//         .get();

//     QuerySnapshot<Map<String, dynamic>> reelsSnapshot = await FirebaseFirestore
//         .instance
//         .collection('reels')
//         .where('Archive', isEqualTo: false)
//         .get();

//     // Filter manually since Firestore doesn't support OR queries directly
//     filteredPosts = postsSnapshot.docs.where((doc) {
//       final data = doc.data();
//       return data['isGlobalOptionEnabled'] == true ||
//           data['GlobalPaymentActivation'] == true;
//     }).toList();

//     filteredReels = reelsSnapshot.docs.where((doc) {
//       final data = doc.data();
//       return data['isGlobalOptionEnabled'] == true ||
//           data['GlobalPaymentActivation'] == true;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: mobileBackgroundColor,
//         title: TextFormField(
//           controller: searchController,
//           decoration: InputDecoration(labelText: "Search for user"),
//           onFieldSubmitted: (String s) {
//             print(searchController.text);
//             setState(() {
//               isShowUsers = true;
//             });
//           },
//         ),
//       ),
//       body: isShowUsers
//           ? FutureBuilder(
//               future: getUsers(searchController.text),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(
//                     child: ParticleBurstLoaderr(     );
//                 }
//                 return ListView.builder(
//                   itemCount: (snapshot.data! as dynamic).docs.length,
//                   itemBuilder: (context, index) {
//                     final userDoc =
//                         (snapshot.data! as dynamic).docs[index].data();
//                     bool isVerified = false;
//                     if (userDoc.containsKey('Verified')) {
//                       isVerified = userDoc['Verified'] == true;
//                     }

//                     // ✅ Handle Monetization if needed
//                     var isMonetized = userDoc['Monetization'];

//                     print("✅ isVerified: $isVerified");
//                     print("💰 isMonetized: $isMonetized");

//                     return InkWell(
//                       onTap: () async {
//                         final QuerySnapshot userSnapshot =
//                             await FirebaseFirestore.instance
//                                 .collection("users")
//                                 .where("uid",
//                                     isEqualTo: (snapshot.data! as dynamic)
//                                         .docs[index]['uid'])
//                                 .get();
//                         print((snapshot.data! as dynamic).docs[index]['uid']);
//                         if (userSnapshot.docs.isNotEmpty) {
//                           final userDoc = userSnapshot.docs.first;
//                           final user = u.User.fromsnap(userDoc);
//                           print({user.uid, user.username});
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => ProfileScreen(
//                                 uid: (snapshot.data! as dynamic).docs[index]
//                                     ['uid'],
//                                 user: user,
//                               ),
//                             ),
//                           );
//                         } else {
//                           print("User not found ");
//                         }
//                       },
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: NetworkImage(
//                               (snapshot.data! as dynamic).docs[index]
//                                   ['photourl']),
//                         ),
//                         title: Row(
//                           children: [
//                             Text((snapshot.data! as dynamic).docs[index]
//                                 ['username']),
//                             const SizedBox(
//                                 width: 6), // spacing between name and icon

//                             (() {
//                               final userData = (snapshot.data! as dynamic)
//                                   .docs[index]
//                                   .data();

//                               // Check Verified field
//                               if (userData.containsKey('Verified') &&
//                                   userData['Verified'] == true) {
//                                 return BlueTick();
//                               }

//                               // If not verified, check Monetization field
//                               if (userData.containsKey('Monetization') &&
//                                   userData['Monetization'] == 'Monitized') {
//                                 return CircleTickIconSearch();
//                               }

//                               return const SizedBox(); // If neither, return nothing
//                             })(),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             )
//           : GestureDetector(
//               onTap: () {},
//               child: FutureBuilder(
//                 future: fetchData(),
//                 builder: (context, AsyncSnapshot<void> snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                       child: const ParticleBurstLoaderr(       );
//                   }
//                   return GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 0,
//                       mainAxisSpacing: 0,
//                     ),
//                     itemCount: filteredPosts.length + filteredReels.length,
//                     itemBuilder: (context, index) {
//                       if (index < filteredPosts.length) {
//                         // Display Posts
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => SearchScreenProfile(
//                                   uid: filteredPosts[index]['uid'],
//                                   username: filteredPosts[index]['username'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Image.network(
//                             filteredPosts[index]['posturl'],
//                             fit: BoxFit.cover,
//                           ),
//                         );
//                       } else {
//                         // Display Reels Thumbnails
//                         int reelsIndex = index - filteredPosts.length;
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => SearchVideoScreen(
//                                     uid: filteredReels[reelsIndex]['uid'],
//                                     videoid: filteredReels[reelsIndex]['id']),
//                               ),
//                             );
//                             print(filteredReels[reelsIndex]['uid']);
//                             print(filteredReels[reelsIndex]['id']);
//                           },
//                           child: VideplayerSearch(
//                             videourl: filteredReels[reelsIndex]['videourl'],
//                             id: filteredReels[reelsIndex]['id'],
//                             thumnail: filteredReels[reelsIndex]['thumbnail'],
//                           ),
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//     );
//   }

//   Future<QuerySnapshot<Object?>?> getUsers(String searchTerm) async {
//     try {
//       return await FirebaseFirestore.instance
//           .collection("users")
//           .where('username', isGreaterThanOrEqualTo: searchTerm)
//           .where('username', isLessThan: searchTerm + '\uf8ff')
//           .get();
//     } catch (error) {
//       print("Error fetching users: $error");
//       return null; // Handle the error gracefully
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zizzle/Ai/AiChatScreen.dart';
import 'package:zizzle/widgets/blueTick.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Controllers/Search_video.dart';
import '/Screens/Reel_Screen_Search.dart';
import '/Screens/Search_Screen_profile.dart';
import '/Screens/profile_screen.dart';
import '/utils/colors.dart';
import '/widgets/CircleTickIcon.dart';
import '/widgets/CircleTickIconSearch.dart';
import '/widgets/Video_player.dart';
import '/widgets/post_card.dart';
import '/model/user.dart' as u;
import '../widgets/videoplayersearch.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  late SearchVideoController videoController;
  var isMonetized;
  var isverified;
  late List<DocumentSnapshot<Map<String, dynamic>>> filteredPosts;
  late List<DocumentSnapshot<Map<String, dynamic>>> filteredReels;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData() async {
    QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore
        .instance
        .collection('Posts')
        .where('Archive', isEqualTo: false)
        .get();

    QuerySnapshot<Map<String, dynamic>> reelsSnapshot = await FirebaseFirestore
        .instance
        .collection('reels')
        .where('Archive', isEqualTo: false)
        .get();

    filteredPosts = postsSnapshot.docs.where((doc) {
      final data = doc.data();
      return data['isGlobalOptionEnabled'] == true ||
          data['GlobalPaymentActivation'] == true;
    }).toList();

    filteredReels = reelsSnapshot.docs.where((doc) {
      final data = doc.data();
      return data['isGlobalOptionEnabled'] == true ||
          data['GlobalPaymentActivation'] == true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search for a user...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor:
                          Colors.black, // A dark background for the text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                    ),
                    onFieldSubmitted: (String s) {
                      setState(() {
                        isShowUsers = true;
                      });
                    },
                  ),
                ),
                // Your new AI chat button
                IconButton(
                  onPressed: () {
                    // Navigate to the ChatWithAIScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ZizzleAIChatScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.bubble_chart, // A modern-looking icon for AI chat
                    color: Colors.cyanAccent,
                  ),
                  tooltip: 'Chat with AI',
                ),
                // The existing search text field
              ],
            )),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: getUsers(searchController.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: ParticleBurstLoaderr(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    final userDoc =
                        (snapshot.data! as dynamic).docs[index].data();
                    bool isVerified = false;
                    if (userDoc.containsKey('Verified')) {
                      isVerified = userDoc['Verified'] == true;
                    }
                    var isMonetized = userDoc['Monetization'];

                    return InkWell(
                      onTap: () async {
                        final QuerySnapshot userSnapshot =
                            await FirebaseFirestore.instance
                                .collection("users")
                                .where("uid",
                                    isEqualTo: (snapshot.data! as dynamic)
                                        .docs[index]['uid'])
                                .get();
                        if (userSnapshot.docs.isNotEmpty) {
                          final userDoc = userSnapshot.docs.first;
                          final user = u.User.fromsnap(userDoc);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                uid: (snapshot.data! as dynamic).docs[index]
                                    ['uid'],
                                user: user,
                              ),
                            ),
                          );
                        } else {
                          print("User not found ");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                  (snapshot.data! as dynamic).docs[index]
                                      ['photourl']),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        (snapshot.data! as dynamic).docs[index]
                                            ['username'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 6),
                                      if (userDoc.containsKey('Verified') &&
                                          userDoc['Verified'] == true)
                                        BlueTick(),
                                      if (userDoc.containsKey('Monetization') &&
                                          userDoc['Monetization'] ==
                                              'Monitized')
                                        CircleTickIconSearch(),
                                    ],
                                  ),
                                  Text(
                                    userDoc['bio'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: fetchData(),
              builder: (context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: ParticleBurstLoaderr(),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredPosts.length + filteredReels.length,
                  itemBuilder: (context, index) {
                    if (index < filteredPosts.length) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SearchScreenProfile(
                                uid: filteredPosts[index]['uid'],
                                username: filteredPosts[index]['username'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(
                                filteredPosts[index]['posturl'],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else {
                      int reelsIndex = index - filteredPosts.length;
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SearchVideoScreen(
                                  uid: filteredReels[reelsIndex]['uid'],
                                  videoid: filteredReels[reelsIndex]['id']),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: VideplayerSearch(
                            videourl: filteredReels[reelsIndex]['videourl'],
                            id: filteredReels[reelsIndex]['id'],
                            thumnail: filteredReels[reelsIndex]['thumbnail'],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  Future<QuerySnapshot<Object?>?> getUsers(String searchTerm) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThan: searchTerm + '\uf8ff')
          .get();
    } catch (error) {
      print("Error fetching users: $error");
      return null;
    }
  }
}
