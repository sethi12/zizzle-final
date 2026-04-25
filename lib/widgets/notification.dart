import 'package:flutter/material.dart';
import 'package:zizzle/Screens/CollabReelScreen.dart';
import 'package:zizzle/Screens/CollabRequst.dart';

class NotificationWidget extends StatelessWidget {
  final String username;
  final String collabusername;
  final String pofilephoto;
  final String thumbnail;
  final String message;
  final String type;
  const NotificationWidget(
      {super.key,
      required this.pofilephoto,
      required this.collabusername,
      required this.thumbnail,
      required this.username,
      required this.message,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == "post") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CollabRequests(username: collabusername)));
        } else if (type == "reel") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CollabReelScreen(username: collabusername)));
        }
      },
      child: Container(
        width: double
            .infinity, // Ensures the widget stretches to the parent's width
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 15.0,
        ), // Adds uniform padding around the widget
        child: Row(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(pofilephoto),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 10.0), // Space between avatar and text

            // Expanded Text
            Expanded(
              child: Text(
                "$message $username",
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ), // Defines text style
              ),
            ),

            // Thumbnail
            Container(
              width: 40,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(thumbnail),
                  fit: BoxFit.cover, // Ensures the image fits nicely
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
