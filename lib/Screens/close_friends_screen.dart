import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '../widgets/followerscard.dart';
import 'package:flutter/material.dart';

class CloseFriendsScreen extends StatefulWidget {
  final uid;
  const CloseFriendsScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends State<CloseFriendsScreen> {
  var username;
  Set<String> _selectedUsers = {}; // Selected users for close friends
  Set<String> _closeFriends = {}; // Existing close friends list
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getUsername(widget.uid);
  }

  Future<void> getUsername(String uid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.size > 0) {
        var data = querySnapshot.docs.first.data();
        setState(() {
          username = data['username'];
          loadCloseFriends(username);
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> loadCloseFriends(String username) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(username).get();

      if (userDoc.exists) {
        var data = userDoc.data();
        setState(() {
          _closeFriends = Set<String>.from(data?['closeFriends'] ?? []);
          _selectedUsers = Set.from(_closeFriends); // Initialize selection
        });
      }
    } catch (e) {
      print('Error loading close friends: $e');
    }
  }

  void _toggleCloseFriend(String userId, bool isSelected) async {
    try {
      if (isSelected) {
        // Add user to closeFriends
        await _firestore.collection('users').doc(username).update({
          'closeFriends': FieldValue.arrayUnion([userId]),
        });
        setState(() {
          _closeFriends.add(userId);
        });
      } else {
        // Remove user from closeFriends
        await _firestore.collection('users').doc(username).update({
          'closeFriends': FieldValue.arrayRemove([userId]),
        });
        setState(() {
          _closeFriends.remove(userId);
        });
      }
    } catch (e) {
      print('Error toggling close friend: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getFollowingDetails(
      String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: Text(
          '${username} Close Friends',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black, // Dark app bar
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color.fromARGB(255, 30, 0, 70),
              ], // Gradient for app bar
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color.fromARGB(255, 10, 0, 30),
            ], // Main background gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select people to add to your close friends list.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70, // Lighter text for dark background
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    _firestore.collection('users').doc(username).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: ParticleBurstLoaderr(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'User not found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  var userData = snapshot.data!.data();
                  var following = userData?['following'] ?? [];
                  if (following.isEmpty) {
                    return const Center(
                      child: Text(
                        'You are not following anyone yet.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: following.length,
                    itemBuilder: (context, index) {
                      var followingId = following[index];
                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: _getFollowingDetails(followingId),
                        builder: (context, detailsSnapshot) {
                          if (detailsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child:
                                  FollowerCardShimmer(), // Placeholder for loading state
                            );
                          }
                          if (detailsSnapshot.hasError ||
                              !detailsSnapshot.hasData ||
                              !detailsSnapshot.data!.exists) {
                            return Container(); // Hide if data is missing or there's an error
                          }
                          var details = detailsSnapshot.data!.data()!;
                          var userId = details['uid'] ?? '';
                          var isCloseFriend = _closeFriends.contains(userId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: InkWell(
                              onTap: () {
                                _toggleCloseFriend(userId, !isCloseFriend);
                              },
                              borderRadius: BorderRadius.circular(15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isCloseFriend
                                      ? LinearGradient(
                                          colors: [
                                            Colors.cyan.shade700,
                                            Colors.blue.shade700,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade900,
                                            Colors.grey.shade800,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: isCloseFriend
                                      ? Border.all(
                                          color: Colors.cyanAccent, width: 2)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage: NetworkImage(
                                            details['photourl'] ?? ''),
                                        backgroundColor:
                                            Colors.blueAccent.shade700,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          details['username'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isCloseFriend
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: isCloseFriend
                                            ? Colors.amberAccent
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A simple placeholder widget for the loading state to improve UX with dark theme
class FollowerCardShimmer extends StatelessWidget {
  const FollowerCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade700,
          ),
          SizedBox(width: 12),
          Container(
            width: 150,
            height: 16,
            color: Colors.grey.shade700,
          ),
          Spacer(),
          Container(
            width: 24,
            height: 24,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }
}
