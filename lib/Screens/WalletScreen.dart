import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/utils/colors.dart';
import '/utils/utils.dart';
import '/widgets/text_feild_input.dart';
import '../widgets/WalletScreenUi.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _upiController = TextEditingController();
  double _totalEarned = 0;
  String? _username;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  bool _reachedLimit = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        title: const Text("Wallet"),
        centerTitle: true,
        elevation: 2,
        backgroundColor: mobileBackgroundColor,
      ),
      body: _username == null
          ? const Center(child: ParticleBurstLoaderr())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection("reels").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ParticleBurstLoaderr());
                }

                _totalEarned = 0;
                _reachedLimit = false;

                for (final reel in snapshot.data!.docs) {
                  final data = reel.data();
                  if (data['username'] == _username &&
                      data['Paid'] == "Not Paid" &&
                      data['views'] != null) {
                    _totalEarned += data['views'] / 1000;
                  }
                }

                if (_totalEarned > 300.0) {
                  _totalEarned = 300.0;
                  _reachedLimit = true;
                }

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildEarningsCard(),
                    const SizedBox(height: 10),
                    _buildReelsList(snapshot),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        "⚠️ You can only request withdrawal once per month.",
                        style:
                            TextStyle(color: Colors.orangeAccent, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _buildWithdrawButton(context),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEarningsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.black12,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              const Text(
                "Total Earnings",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                "CAD ${_totalEarned.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent),
              ),
              if (_reachedLimit)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "You have reached the monthly maximum limit",
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReelsList(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    final unpaidReels = snapshot.data!.docs.where((doc) {
      final data = doc.data();
      return data['username'] == _username && data['Paid'] == "Not Paid";
    }).toList();

    return Expanded(
      child: ListView.builder(
        itemCount: unpaidReels.length,
        itemBuilder: (context, index) {
          final reelData = unpaidReels[index].data();
          return WalletScreenVideoUI(reelData: reelData);
        },
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: () => _handleWithdrawalRequest(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'Request Withdrawal',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _handleWithdrawalRequest(BuildContext context) {
    if (_totalEarned < 50.0) {
      showSnackBar("Minimum withdrawal amount is 50 CAD", context);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_outlined,
                  size: 40, color: Colors.green),
              const SizedBox(height: 10),
              const Text(
                "Monthly Limit Notice",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "You can withdraw up to 300 CAD per month. This helps ensure fair distribution and sustainability.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              TextFeildInput(
                textInputType: TextInputType.text,
                textEditingController: _upiController,
                hinttext: "Enter your UPI ID",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _confirmWithdrawal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm Withdrawal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmWithdrawal(BuildContext context) async {
    if (_upiController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Missing UPI ID"),
          content: const Text("Please enter your UPI ID to proceed."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    final double amountToSend = _totalEarned > 300.0 ? 300.0 : _totalEarned;

    final result = await _addUpiRequest(amountToSend);
    if (result == "Success") {
      await _markReelsPaid();
      Navigator.pop(context);
    }
  }

  Future<String> _addUpiRequest(double amount) async {
    try {
      await FirebaseFirestore.instance
          .collection("Requests")
          .doc(_username)
          .set({
        "username": _username,
        "Amount": "CAD ${amount.toStringAsFixed(2)}",
        "date of request": DateTime.now(),
        "status": "pending",
        "upi id": _upiController.text.trim(),
        "Expiry Date": _expiryDate,
      });
      return "Success";
    } catch (e) {
      print("Error: $e");
      return "Error";
    }
  }

  Future<void> _markReelsPaid() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("reels")
        .where("username", isEqualTo: _username)
        .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance.collection("reels").doc(doc.id).update({
        "Paid": "Paid",
      });
    }
  }
}
