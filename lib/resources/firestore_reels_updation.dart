import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreReelUpdater {
  static bool isGlobalOptionEnabled = false;
  static Timer? globalOptionTimer;

  void enableGlobalOption(String docId) {
    isGlobalOptionEnabled = true;

    updateFirestore(docId); // Update Firestore when global option is enabled

    // Set a timer to disable the global option after 15 minutes
    globalOptionTimer = Timer(Duration(minutes: 15), () {
      disableGlobalOption(docId);
    });
  }

  void disableGlobalOption(String docId) {
    isGlobalOptionEnabled = false;
    if (globalOptionTimer != null && globalOptionTimer!.isActive) {
      globalOptionTimer!.cancel(); // Cancel the timer if active
    }
    updateFirestore(docId); // Update Firestore when global option is disabled
  }

  void updateFirestore(String docId) {
    FirebaseFirestore.instance.collection('reels').doc(docId).update({
      'isGlobalOptionEnabled': isGlobalOptionEnabled,
    }).then((value) {
      print("Firestore updated successfully");
    }).catchError((error) {
      print("Error updating Firestore: $error");
    });
  }

  // Future<void> updateGlobalOptionStatusForUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var username = prefs.getString('username');
  //   CollectionReference reelsCollection =
  //       FirebaseFirestore.instance.collection('reels');

  //   try {
  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       QuerySnapshot querySnapshott =
  //           await reelsCollection.where('username', isEqualTo: username).get();

  //       for (QueryDocumentSnapshot docSnapshot in querySnapshott.docs) {
  //         transaction.update(reelsCollection.doc(docSnapshot.id),
  //             {'isGlobalOptionEnabled': false});
  //       }
  //     });

  //     print("Successfully updated documents for user: $username");
  //   } catch (e) {
  //     print("Error updating documents: $e");
  //   }
  // }
  Future<void> updateGlobalOptionStatusForUser() async {
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');
    CollectionReference reelsCollection =
        FirebaseFirestore.instance.collection('reels');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        QuerySnapshot querySnapshot =
            await reelsCollection.where('username', isEqualTo: username).get();

        int boostedPostCount = 0;
        Duration totalRemainingTime = Duration.zero;

        for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
          final data = docSnapshot.data() as Map<String, dynamic>;

          // Check if GlobalPlanexpiresAt exists and is a Timestamp
          if (data.containsKey('GlobalPlanexpiresAt') &&
              data['GlobalPlanexpiresAt'] is Timestamp) {
            final Timestamp expiresAt = data['GlobalPlanexpiresAt'];
            final DateTime now = DateTime.now();

            if (expiresAt.toDate().isBefore(now)) {
              // Expired → Disable boost
              transaction.update(reelsCollection.doc(docSnapshot.id), {
                'GlobalPaymentActivation': false,
                'GlobalPlanactivatedAt': null,
                'GlobalPlanexpiresAt': null,
              });

              print("⛔ Global boost expired for post ${docSnapshot.id}");
            } else {
              final Duration remaining = expiresAt.toDate().difference(now);
              boostedPostCount++;
              totalRemainingTime += remaining;

              print(
                  "⏳ Boost active for post ${docSnapshot.id}, expires in ${remaining.inMinutes} minutes");
            }
          }

          // Always disable isGlobalOptionEnabled regardless of boost status
          transaction.update(
            reelsCollection.doc(docSnapshot.id),
            {'isGlobalOptionEnabled': false},
          );
        }

        // After all documents processed, show summary
        if (boostedPostCount > 0) {
          final int d = totalRemainingTime.inDays;
          final int h = totalRemainingTime.inHours % 24;
          final int m = totalRemainingTime.inMinutes % 60;

          Get.snackbar(
            "Global Boost Summary",
            "🔥 $boostedPostCount reels are boosted\nTotal remaining: $d d $h h $m m",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.teal,
            colorText: Colors.white,
            duration: Duration(seconds: 6),
          );
        }
      });

      print("✅ Successfully updated documents for user: $username");
    } catch (e) {
      print("❌ Error updating documents: $e");
    }
  }

  void ActivatePaymentGlobalOptionsReels(
      String postId, Duration duration) async {
    final now = DateTime.now();
    final endTime = now.add(duration);

    try {
      await FirebaseFirestore.instance.collection('reels').doc(postId).update({
        "GlobalPaymentActivation": true,
        'GlobalPlanactivatedAt': Timestamp.fromDate(now),
        'GlobalPlanexpiresAt': Timestamp.fromDate(endTime),
      });

      print("✅ Global Boost enabled for $postId until $endTime");
    } catch (e) {
      print("❌ Failed to enable global boost: $e");
    }
  }
}
