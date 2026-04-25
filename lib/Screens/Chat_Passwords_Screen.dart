import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '../utils/colors.dart';

class ChatPasswordsScreen extends StatefulWidget {
  final String uid; // Specify the type for uid
  const ChatPasswordsScreen({super.key, required this.uid});

  @override
  State<ChatPasswordsScreen> createState() => _ChatPasswordsScreenState();
}

class _ChatPasswordsScreenState extends State<ChatPasswordsScreen> {
  Future<Map<String, String?>> fetchOtherUserDetails(
      List<dynamic> participants) async {
    try {
      // Find the other user's UID
      final otherUid = participants.firstWhere((uid) => uid != widget.uid);

      // Fetch the user's document from the "users" collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: otherUid)
          .get();

      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        return {
          'username': userData['username'] ?? 'Unknown',
          'photourl': userData['photourl'] ?? '',
        };
      } else {
        return {'username': 'Unknown', 'photourl': ''};
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return {'username': 'Error', 'photourl': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Locked Chats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where("participants", arrayContains: widget.uid)
              .where("locked", isEqualTo: true) // Filter only locked chats
              .snapshots(),
          builder: (context, snapshot) {
            // Show a loading indicator while the data is being fetched
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: ParticleBurstLoaderr());
            }

            // Handle errors
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "An error occurred: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            // Handle empty data
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_open_outlined,
                      size: 80,
                      color: secondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No locked chats found.',
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

            final chatDocs = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: chatDocs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final chat = chatDocs[index].data();
                final participants = chat['participants'] as List<dynamic>;
                final chatPassword = chat['password'] as String?;

                return FutureBuilder<Map<String, String?>>(
                  future: fetchOtherUserDetails(participants),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: secondaryColor,
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 150,
                              height: 12,
                              color: secondaryColor.withOpacity(0.2),
                            ),
                          ],
                        ),
                      );
                    }

                    if (userSnapshot.hasError || userSnapshot.data == null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                          title: Text('Error fetching user details',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      );
                    }

                    final userDetails = userSnapshot.data!;
                    return Container(
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: userDetails['photourl']!.isNotEmpty
                              ? NetworkImage(userDetails['photourl']!)
                              : null,
                          child: userDetails['photourl']!.isEmpty
                              ? const Icon(Icons.person, color: secondaryColor)
                              : null,
                          backgroundColor: primaryColor.withOpacity(0.2),
                        ),
                        title: Text(
                          userDetails['username']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Password: ${chatPassword ?? "No Password"}',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: const Icon(Icons.lock, color: primaryColor),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
