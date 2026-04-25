import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Screens/Add_post_screen_details.dart';
import '/Screens/profile_screen.dart';

import '../utils/colors.dart';
import '../widgets/CircleTickIconSearch.dart';

class CollabScreen extends StatefulWidget {
  const CollabScreen({super.key});
  @override
  State<CollabScreen> createState() => _CollabScreenState();
}

class _CollabScreenState extends State<CollabScreen> {
  final TextEditingController searchController = TextEditingController();
  var isMonetized;
  static var collabusername;
  Future<QuerySnapshot<Object?>?>? searchResults; // Adjusted type here

  String searchTerm = ''; // Store the current search term

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(labelText: "Search for user"),
          onChanged: (String s) {
            setState(() {
              searchTerm = s;
              if (s.isNotEmpty) {
                searchResults = getUsers(searchTerm); // Trigger fetch
              } else {
                searchResults = null; // Clear results if search term is empty
              }
            });
          },
        ),
      ),
      body: searchResults == null
          ? const Center(
              child: Text("Enter a username to search."),
            )
          : FutureBuilder(
              future: searchResults,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: ParticleBurstLoaderr(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    isMonetized =
                        (snapshot.data! as dynamic).docs[index]['Monetization'];
                    return InkWell(
                      onTap: () {
                        collabusername =
                            (snapshot.data as dynamic).docs[index]['username'];
                        print(collabusername);
                        Navigator.of(context).pop(collabusername);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]
                                  ['photourl']),
                        ),
                        title: Row(
                          children: [
                            Text((snapshot.data! as dynamic).docs[index]
                                ['username']),
                            const SizedBox(),
                            isMonetized == "Monitized"
                                ? CircleTickIconSearch()
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    );
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
      return null; // Handle the error gracefully
    }
  }
}
