import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zizzle/resources/firestore_reels_updation.dart';
import 'package:zizzle/resources/updation_firestore.dart'; // Assuming this contains FirestoreUpdater

class PaymentSuccessScreen extends StatefulWidget {
  final String orderid;
  final String planName; // e.g., "1 Day – ₹19"
  final String docid;
  final String caller;

  const PaymentSuccessScreen(
      {super.key,
      required this.planName,
      required this.orderid,
      required this.docid,
      required this.caller});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();

    /// Activate global options based on plan
    if (widget.caller == "Post") {
      updateforPost(widget.docid, widget.planName);
    }
    if (widget.caller == "Reels") {
      UpdateForReel(widget.docid, widget.planName);
    }
    if (widget.caller == "Badge") {
      AddVerifyBadge();
    }
  }

  void AddVerifyBadge() async {
    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 30));

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.docid)
        .update({
      "Verified": true,
      "VerifiedAt": Timestamp.fromDate(now),
      "VerifiedExpiry": Timestamp.fromDate(expiry),
    });

    print("✅ Badge added for user ${widget.docid} valid until $expiry");
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .where('username', isEqualTo: widget.docid)
        .get();

    for (var doc in postsSnapshot.docs) {
      await FirebaseFirestore.instance.collection('Posts').doc(doc.id).update({
        'Verified': true,
      });
    }

    print("📝 Updated all posts by ${widget.docid} with Verified=true");

    final reelssnapshot = await FirebaseFirestore.instance
        .collection("reels")
        .where("username", isEqualTo: widget.docid)
        .get();

    for (var doc in reelssnapshot.docs) {
      await FirebaseFirestore.instance.collection('reels').doc(doc.id).update({
        'Verified': true,
      });
    }

    print("📝 Updated all reels by ${widget.docid} with Verified=true");
  }

  void updateforPost(String postid, String planname) {
    Duration duration;

    if (widget.planName.contains("1 Day")) {
      duration = const Duration(days: 1);
    } else if (widget.planName.contains("1 Week")) {
      duration = const Duration(days: 7);
    } else if (widget.planName.contains("1 Month")) {
      duration = const Duration(days: 30);
    } else {
      duration = const Duration(days: 1); // default fallback
    }

    FirestoreUpdater().ActivatePaymentGlobalOptions(postid, duration);
    print(widget.orderid);
  }

  void UpdateForReel(String reelid, String planname) {
    Duration duration;

    if (widget.planName.contains("1 Day")) {
      duration = const Duration(days: 1);
    } else if (widget.planName.contains("1 Week")) {
      duration = const Duration(days: 7);
    } else if (widget.planName.contains("1 Month")) {
      duration = const Duration(days: 30);
    } else {
      duration = const Duration(days: 1); // default fallback
    }

    FirestoreReelUpdater().ActivatePaymentGlobalOptionsReels(reelid, duration);
    print(widget.orderid);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.caller == "Badge") {
      // Custom UI for Badge Verification Purchase
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Verified Badge Activated"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.badgeCheck,
                  size: 100,
                  color: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 30),
                const Text(
                  "You’re Officially Verified!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Your verified badge has been successfully activated.\nYour profile now stands out and gains more trust!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white12,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Order ID",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.orderid,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text("Back to Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🔁 Default UI for Post and Reels
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Payment Success"),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.badgeCheck,
                size: 90,
                color: Colors.greenAccent,
              ),
              const SizedBox(height: 30),
              const Text(
                "Payment Successful",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your global boost plan has been activated.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Activated Plan",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.planName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text("Back to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
