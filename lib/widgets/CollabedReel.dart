import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/Screens/Profile_reel_screen.dart';
import '../utils/colors.dart';

class CollabedReel extends StatelessWidget {
  final snap;
  const CollabedReel({super.key, required this.snap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(snap['profimage']),
                radius: 22,
              ),
              const SizedBox(width: 20),
              Text(
                snap['username'],
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfileVideoScreen(
                      uid: snap['uid'], videoid: snap['reelid'])));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                snap['thumbnail'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white60,
              ),
              children: [
                TextSpan(
                  text: "${snap['username']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: " wants to collaborate with you "),
                TextSpan(
                  text: "${snap['collabusername']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("reels")
                        .doc(snap['reelid'])
                        .update({"collabreqacc": true});
                    FirebaseFirestore.instance
                        .collection("CollabRequests")
                        .doc(snap['reelid'])
                        .delete();
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("CollabRequests")
                        .doc(snap['reelid'])
                        .delete();
                  },
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  label: const Text("Decline"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: Colors.grey.shade700, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
