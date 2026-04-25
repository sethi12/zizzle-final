import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zizzle/resources/loaderconfig.dart';

class FirestoreUpdater {
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
    FirebaseFirestore.instance.collection('Posts').doc(docId).update({
      'isGlobalOptionEnabled': isGlobalOptionEnabled,
    }).then((value) {
      print("Firestore updated successfully");
    }).catchError((error) {
      print("Error updating Firestore: $error");
    });
  }

  Future<void> updateGlobalOptionStatusForUser() async {
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');
    CollectionReference postsCollection =
        FirebaseFirestore.instance.collection('Posts');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        QuerySnapshot querySnapshot =
            await postsCollection.where('username', isEqualTo: username).get();

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
              transaction.update(postsCollection.doc(docSnapshot.id), {
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
            postsCollection.doc(docSnapshot.id),
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
            "🔥 $boostedPostCount post(s) are boosted\nTotal remaining: $d d $h h $m m",
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

  void ActivatePaymentGlobalOptions(String postId, Duration duration) async {
    final now = DateTime.now();
    final endTime = now.add(duration);

    try {
      await FirebaseFirestore.instance.collection('Posts').doc(postId).update({
        "GlobalPaymentActivation": true,
        'GlobalPlanactivatedAt': Timestamp.fromDate(now),
        'GlobalPlanexpiresAt': Timestamp.fromDate(endTime),
      });

      print("✅ Global Boost enabled for $postId until $endTime");
    } catch (e) {
      print("❌ Failed to enable global boost: $e");
    }
  }

  Future<void> checkAndUpdateVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (!userDoc.exists) return;

    final data = userDoc.data()!;
    final Timestamp? verifiedExpiry = data['VerifiedExpiry'];
    final Monetization = data['Monetization'];
    if (verifiedExpiry != null) {
      final DateTime expiryDate = verifiedExpiry.toDate();
      final DateTime now = DateTime.now();

      if (expiryDate.isBefore(now)) {
        // Expired → remove verification
        await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .update({
          'Verified': false,
          'VerifiedAt': null,
          'VerifiedExpiry': null
        });
        final postsSnapshot = await FirebaseFirestore.instance
            .collection('Posts')
            .where('username', isEqualTo: username)
            .get();

        for (var doc in postsSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('Posts')
              .doc(doc.id)
              .update({
            'Verified': false,
          });
        }

        print("📝 Updated all posts by $username with Verified=false");

        final reelssnapshot = await FirebaseFirestore.instance
            .collection("reels")
            .where("username", isEqualTo: username)
            .get();

        for (var doc in reelssnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('reels')
              .doc(doc.id)
              .update({
            'Verified': false,
          });
        }

        print("📝 Updated all reels by $username with Verified=false");
        print("🛑 Verification expired. Updated Verified=false for $username");
      } else {
        print("✅ Verified is still active for $username");
        final postsSnapshot = await FirebaseFirestore.instance
            .collection('Posts')
            .where('username', isEqualTo: username)
            .get();

        for (var doc in postsSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('Posts')
              .doc(doc.id)
              .update({
            'Verified': true,
          });
        }

        print("📝 Updated all posts by $username with Verified=true");

        final reelssnapshot = await FirebaseFirestore.instance
            .collection("reels")
            .where("username", isEqualTo: username)
            .get();

        for (var doc in reelssnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('reels')
              .doc(doc.id)
              .update({
            'Verified': true,
          });
        }

        print("📝 Updated all reels by $username with Verified=true");
      }
    }
    if (Monetization == 'Monitized') {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .where('username', isEqualTo: username)
          .get();

      for (var doc in postsSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('Posts')
            .doc(doc.id)
            .update({
          'Monetized': "Monitized",
        });
      }

      print(
          "All posts are updated for Monetized users ........................... ${username}");
    }
  }

  Future<void> initLoader() async {
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');
    print("username passed for loader");
    await LoaderConfig().loadFromFirestore(username!);
    // after this, everywhere ParticleBurstLoader() will use Firestore values
    print("username passed for loader");
  }
}
