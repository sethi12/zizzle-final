import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zizzle/Screens/Profile_reel_screen.dart';
import 'package:zizzle/Screens/profile_screen.dart';
import 'package:zizzle/Screens/profileimagecheckScreen.dart';
import 'package:zizzle/widgets/notification.dart';
import 'package:intl/intl.dart';
import 'package:zizzle/widgets/post_card.dart';
import 'package:zizzle/widgets/pulseloader.dart';

class Notificationscreen extends StatefulWidget {
  final String username;
  const Notificationscreen({super.key, required this.username});

  @override
  State<Notificationscreen> createState() => _NotificationscreenState();
}

class _NotificationscreenState extends State<Notificationscreen> {
  // Cache to track previous like counts for each post
  final Map<String, Set<String>> _likeCache = {};
  Set<String> _followersCache = {}; // Moved to class level
  final Map<String, Set<String>> _reellikeCache = {};
  Stream<List<Map<String, dynamic>>> getCombinedNotifications() {
    // Stream 1: Collab Requests
    final collabStream = FirebaseFirestore.instance
        .collection("CollabRequests")
        .where("collabusername", isEqualTo: widget.username)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                "type": "collab",
              };
            }).toList());

    // Stream 2: Post Likes
    final postsStream = FirebaseFirestore.instance
        .collection("Posts")
        .where("username", isEqualTo: widget.username)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> newLikes = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final postId = doc.id;
        final likes = data['likes'];

        if (likes is List && likes.isNotEmpty) {
          final currentLikers = Set<String>.from(likes);
          final cachedLikers = _likeCache[postId] ?? <String>{};

          final newLikers = currentLikers.difference(cachedLikers);

          for (var newUser in newLikers) {
            // Get liker profile image
            final userSnapshot = await FirebaseFirestore.instance
                .collection("users")
                .where("username", isEqualTo: newUser)
                .limit(1)
                .get();

            final profimage = userSnapshot.docs.isNotEmpty
                ? userSnapshot.docs.first.data()['photourl'] ?? ''
                : '';

            // Get current user's profile image (post owner's)
            final ownerSnapshot = await FirebaseFirestore.instance
                .collection("users")
                .where("username", isEqualTo: widget.username)
                .limit(1)
                .get();

            final myprofile = ownerSnapshot.docs.isNotEmpty
                ? ownerSnapshot.docs.first.data()['photourl'] ?? ''
                : '';

            newLikes.add({
              ...data,
              "type": "like",
              "likedBy": newUser,
              "profimage": profimage,
              "postId": postId,
              "timestamp": DateTime.now(),
              "myprofile": myprofile,
            });
          }

          _likeCache[postId] = currentLikers;
        }
      }

      return newLikes;
    });

    // Stream 3: Reel Likes (NEW)
    final reelsStream = FirebaseFirestore.instance
        .collection("reels")
        .where("username", isEqualTo: widget.username)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> newLikes = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final reelId = doc.id;
        final likes = data['likes'];

        if (likes is List && likes.isNotEmpty) {
          final currentLikers = Set<String>.from(likes);
          final cachedLikers = _likeCache[reelId] ?? <String>{};

          final newLikers = currentLikers.difference(cachedLikers);

          for (var newUser in newLikers) {
            final userSnapshot = await FirebaseFirestore.instance
                .collection("users")
                .where("username", isEqualTo: newUser)
                .limit(1)
                .get();

            final profimage = userSnapshot.docs.isNotEmpty
                ? userSnapshot.docs.first.data()['photourl'] ?? ''
                : '';

            final ownerSnapshot = await FirebaseFirestore.instance
                .collection("users")
                .where("username", isEqualTo: widget.username)
                .limit(1)
                .get();

            final myprofile = ownerSnapshot.docs.isNotEmpty
                ? ownerSnapshot.docs.first.data()['photourl'] ?? ''
                : '';

            newLikes.add({
              ...data,
              "type": "reel_like",
              "likedBy": newUser,
              "profimage": profimage,
              "reelId": reelId,
              "timestamp": DateTime.now(),
              "myprofile": myprofile,
            });
          }

          _reellikeCache[reelId] = currentLikers;
        }
      }

      return newLikes;
    });

    // Stream 4: New Followers
    final followersStream = FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: widget.username)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> newFollowers = [];

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final currentFollowers = Set<String>.from(data['followers'] ?? []);

        final newFollowerSet = currentFollowers.difference(_followersCache);

        for (var newFollower in newFollowerSet) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection("users")
              .where("username", isEqualTo: newFollower)
              .limit(1)
              .get();

          final profimage = userSnapshot.docs.isNotEmpty
              ? userSnapshot.docs.first.data()['photourl'] ?? ''
              : '';

          newFollowers.add({
            "type": "follow",
            "follower": newFollower,
            "profimage": profimage,
            "timestamp": DateTime.now(),
          });
        }

        _followersCache = currentFollowers;
      }

      return newFollowers;
    });

    // Combine all 4 streams
    return Rx.combineLatest4<
        List<Map<String, dynamic>>,
        List<Map<String, dynamic>>,
        List<Map<String, dynamic>>,
        List<Map<String, dynamic>>,
        List<Map<String, dynamic>>>(
      collabStream,
      postsStream,
      reelsStream,
      followersStream,
      (collabList, postLikes, reelLikes, followList) {
        return [...collabList, ...postLikes, ...reelLikes, ...followList];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getCombinedNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ParticleBurstLoaderr());
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final docData = data[index];
              final type = docData['type'];

              if (type == "collab") {
                final profilePhoto = docData['profimage'] ?? '';
                final username = docData['username'] ?? '';
                final collabusername = docData['collabusername'] ?? '';
                final postId = docData['postid'];
                final postUrl = docData['posturl'] ?? '';
                final thumbnail = docData['thumbnail'] ?? '';

                if (postId != null && postId.isNotEmpty) {
                  return NotificationWidget(
                    pofilephoto: profilePhoto,
                    collabusername: collabusername,
                    username: username,
                    thumbnail: postUrl,
                    message: "You have a new Post collab Request from",
                    type: "post",
                  );
                } else {
                  return NotificationWidget(
                    pofilephoto: profilePhoto,
                    collabusername: collabusername,
                    username: username,
                    thumbnail: thumbnail,
                    message: "You have a new Reel collab Request from",
                    type: "reel",
                  );
                }
              }

              if (type == "like") {
                final likedBy = docData['likedBy'] ?? 'Someone';
                final thumbnail = docData['posturl'] ?? '';
                final profilePhoto = docData['profimage'] ?? '';
                final postId = docData['postId'] ?? '';
                final timestamp = docData['timestamp'];
                final myprofile = docData['myprofile'];
                return NotificationWidgetLike(
                    username: likedBy,
                    targetUser: widget.username,
                    profilePhoto: profilePhoto,
                    postUrl: thumbnail,
                    postId: postId,
                    timestamp: timestamp is Timestamp
                        ? timestamp.toDate()
                        : (timestamp is DateTime ? timestamp : DateTime.now()),
                    snap: docData,
                    myprofile: myprofile // 👈 ADD THIS
                    );
              }
              if (type == "reel_like") {
                final likedBy = docData['likedBy'] ?? 'Someone';
                final thumbnail =
                    docData['thumbnail'] ?? docData['reelurl'] ?? '';
                final profilePhoto = docData['profimage'] ?? '';
                final reelId = docData['id'] ?? '';
                final uid = docData['uid'] ?? '';
                final timestamp = docData['timestamp'];
                final myprofile = docData['myprofile'];

                return NotificationWidgetReelLike(
                  username: likedBy,
                  targetUser: widget.username,
                  profilePhoto: profilePhoto,
                  reelUrl: thumbnail,
                  reelId: reelId,
                  uid: uid,
                  timestamp: timestamp is Timestamp
                      ? timestamp.toDate()
                      : (timestamp is DateTime ? timestamp : DateTime.now()),
                  snap: docData,
                  myprofile: myprofile,
                );
              }

              if (type == "follow") {
                final follower = docData['follower'] ?? 'Someone';
                final profilePhoto = docData['profimage'] ?? '';
                final timestamp = docData['timestamp'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profilePhoto.isNotEmpty
                        ? NetworkImage(profilePhoto)
                        : const AssetImage('assets/default.png')
                            as ImageProvider,
                  ),
                  title: GestureDetector(
                    onTap: () async {
                      final userSnapshot = await FirebaseFirestore.instance
                          .collection("users")
                          .where("username", isEqualTo: follower)
                          .limit(1)
                          .get();

                      final actualuid = userSnapshot.docs.isNotEmpty
                          ? userSnapshot.docs.first.data()['uid']
                          : null;
                      if (actualuid != null) {
                        print(actualuid);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: actualuid,
                          ),
                        ));
                      }
                    },
                    child: Text(
                      "$follower started following you",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // subtitle: Text(DateFormat('MMM d, h:mm a').format(timestamp)),
                );
              }

              return const SizedBox.shrink(); // fallback
            },
          );
        },
      ),
    );
  }
}
// new class

class NotificationWidgetLike extends StatelessWidget {
  final String username; // liker
  final String targetUser; // post owner
  final String profilePhoto; // liker profile photo
  final String postUrl; // post image
  final String postId; // corrected from postid
  final DateTime timestamp;
  final Map<String, dynamic> snap;
  final String myprofile;
  const NotificationWidgetLike(
      {Key? key,
      required this.username,
      required this.targetUser,
      required this.profilePhoto,
      required this.postUrl,
      required this.postId,
      required this.timestamp,
      required this.snap,
      required this.myprofile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('MMM d, h:mm a').format(timestamp);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profilePhoto.isNotEmpty
            ? NetworkImage(profilePhoto)
            : const AssetImage('assets/default.png') as ImageProvider,
        radius: 25,
      ),
      title: Text(
        "$username liked your post @$targetUser",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // subtitle: Text(timeText),
      trailing: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: postUrl.isNotEmpty
            ? Image.network(
                postUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const SizedBox.shrink(),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageScreen(
              snap: snap,
              myprofile: myprofile,
            ),
          ),
        );
      },
    );
  }
}

class ImageScreen extends StatefulWidget {
  final Map<String, dynamic> snap;
  final String myprofile;
  const ImageScreen({super.key, required this.snap, required this.myprofile});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostCard(
              snap: widget.snap,
              myprofile: widget.myprofile,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationWidgetReelLike extends StatelessWidget {
  final String username;
  final String targetUser;
  final String profilePhoto;
  final String reelUrl;
  final String reelId;
  final DateTime timestamp;
  final Map<String, dynamic> snap;
  final String myprofile;
  final String uid;
  const NotificationWidgetReelLike(
      {Key? key,
      required this.username,
      required this.targetUser,
      required this.profilePhoto,
      required this.reelUrl,
      required this.reelId,
      required this.timestamp,
      required this.snap,
      required this.myprofile,
      required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final timeText = DateFormat('MMM d, h:mm a').format(timestamp);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profilePhoto.isNotEmpty
            ? NetworkImage(profilePhoto)
            : const AssetImage('assets/default.png') as ImageProvider,
        radius: 25,
      ),
      title: Text(
        "$username liked your reel @$targetUser",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // subtitle: Text(timeText),
      trailing: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: reelUrl.isNotEmpty
            ? Image.network(
                reelUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const SizedBox.shrink(),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfileVideoScreen(uid: uid, videoid: reelId)),
        );
      },
    );
  }
}
