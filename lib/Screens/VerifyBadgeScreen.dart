import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
// import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:zizzle/Payment/Paymentsucces.dart';
import 'package:zizzle/services/alert_service.dart';

class VerifyBadgeScreen extends StatefulWidget {
  final String? username;
  final String email;
  final String? number;
  const VerifyBadgeScreen(
      {super.key, required this.username, required this.email, this.number});

  @override
  State<VerifyBadgeScreen> createState() => _VerifyBadgeScreenState();
}

class _VerifyBadgeScreenState extends State<VerifyBadgeScreen> {
  String? number;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.number == null) {
      number = "1234567890";
    } else {
      number = widget.number;
    }
  }

  // Future<void> _startPaymentViaFirebase({
  //   required double amount,
  //   required String username,
  // }) async {
  //   try {
  //     const functionUrl =
  //         'https://createcashfreeorder-jymvzexgxa-uc.a.run.app'; // ✅ Cloud Run URL
  //     const verifyUrl =
  //         'https://us-central1-zizzle-a5db3.cloudfunctions.net/verifyCashfreePayment';

  //     final response = await http.post(
  //       Uri.parse(functionUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'amount': amount,
  //         'customerId': username,
  //         'customerEmail': widget.email,
  //         'customerPhone': number,
  //       }),
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception('Function failed: ${response.body}');
  //     }

  //     final data = jsonDecode(response.body);
  //     final orderId = data['orderId'];
  //     final sessionId = data['sessionId'];

  //     final session = CFSessionBuilder()
  //         .setEnvironment(CFEnvironment.PRODUCTION)
  //         .setOrderId(orderId)
  //         .setPaymentSessionId(sessionId)
  //         .build();

  //     final payment = CFWebCheckoutPaymentBuilder().setSession(session).build();
  //     final cfService = CFPaymentGatewayService();

  //     cfService.setCallback(
  //       (String successOrderId) async {
  //         // ✅ Verify payment
  //         final verifyResponse = await http.post(
  //           Uri.parse(verifyUrl),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({'orderId': successOrderId}),
  //         );

  //         if (verifyResponse.statusCode == 200) {
  //           final data = jsonDecode(verifyResponse.body);
  //           if (data['status'] == 'PAID') {
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => PaymentSuccessScreen(
  //                   orderid: successOrderId,
  //                   planName: username,
  //                   docid: username,
  //                   caller: "Badge",
  //                 ),
  //               ),
  //             );
  //           } else {
  //             GetIt.I<AlertService>().showError("Payment not completed.");
  //           }
  //         } else {
  //           GetIt.I<AlertService>().showError("Failed to verify payment.");
  //         }
  //       },
  //       (CFErrorResponse error, String failedOrderId) {
  //         GetIt.I<AlertService>().showError(
  //           'Payment failed: ${error.getMessage()}',
  //         );
  //       },
  //     );

  //     await cfService.doPayment(payment); // ✅ Awaiting payment
  //   } catch (e) {
  //     debugPrint("🔥 Firebase/Payment Error: $e");
  //     GetIt.I<AlertService>().showError('Server Error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Modern dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Verified Badge"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Verified icon
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[700],
              child: const Icon(
                Icons.verified,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              "Become Verified on Zizzle",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              "Stand out from the crowd with a verified badge. Gain trust, attract more followers, and unlock exclusive features.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Benefits list
            Column(
              children: [
                _benefitRow(Icons.shield, "Boost your credibility"),
                _benefitRow(Icons.flash_on, "Priority in search & explore"),
                _benefitRow(Icons.star, "Get collaboration requests"),
                _benefitRow(Icons.lock, "Access exclusive features"),
              ],
            ),
            const Spacer(),

            // Buy Now button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Proceed to payment or subscription flow
                  // _startPaymentViaFirebase(
                  //     amount: 199, username: widget.username!);
                  // print(number);

                  print(number);
                  final String paymentUrl =
                      "https://inbred-techno.vercel.app/Plan?uid=${widget.username}&email=${widget.email}";

                  final Uri url = Uri.parse(paymentUrl);

                  if (await canLaunchUrl(url)) {
                    // This will open the Plans page in the user's default web browser
                    // to begin the payment process.
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    // Handle error if the URL cannot be launched
                    throw 'Could not launch $paymentUrl';
                  }
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Buy Verified Badge - ₹199/Month"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
