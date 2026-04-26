import 'dart:convert';
// import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
// import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:get_it/get_it.dart';
import 'package:zizzle/Payment/Paymentsucces.dart';
import 'package:zizzle/services/alert_service.dart';
import '/ads/ads_manager.dart';
import '/utils/colors.dart';

class GlobalReelBenfitScreen extends StatefulWidget {
  final String docid;
  final String? email;
  GlobalReelBenfitScreen({super.key, required this.docid, required this.email});

  @override
  State<GlobalReelBenfitScreen> createState() => _GlobalReelBenfitScreenState();
}

class _GlobalReelBenfitScreenState extends State<GlobalReelBenfitScreen> {
  String? _selectedPlanName;
  // Future<void> _startPaymentViaFirebase({
  //   required double amount,
  //   required String planName,
  // }) async {
  //   try {
  //     const functionUrl = 'https://createcashfreeorder-jymvzexgxa-uc.a.run.app';

  //     final response = await http.post(
  //       Uri.parse(functionUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'amount': amount,
  //         'customerId': widget.docid,
  //         'customerEmail': widget.email,
  //         'customerPhone': '1234567890',
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
  //         final verifyUrl =
  //             'https://us-central1-zizzle-a5db3.cloudfunctions.net/verifyCashfreePayment';

  //         final verifyResponse = await http.post(
  //           Uri.parse(verifyUrl),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({'orderId': successOrderId}),
  //         );

  //         if (verifyResponse.statusCode == 200) {
  //           final data = jsonDecode(verifyResponse.body);
  //           if (data['status'] == 'PAID') {
  //             if (!mounted) return;
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => PaymentSuccessScreen(
  //                   orderid: successOrderId,
  //                   planName: planName,
  //                   docid: widget.docid,
  //                   caller: "Post",
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

  //     await cfService.doPayment(payment);
  //   } catch (e) {
  //     debugPrint("🔥 Firebase/Payment Error: $e");
  //     GetIt.I<AlertService>().showError('Server Error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text("Global Boost Options"),
        centerTitle: false,
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInfoText(screenWidth),
                    const SizedBox(height: 20),
                    _buildBoostOption(
                      title: "15 Minutes – Free",
                      description:
                          "Boost globally for 15 minutes by watching a rewarded ad.",
                      color: Colors.green,
                      onPressed: () =>
                          Admanager().showrelrewardedad(widget.docid),
                    ),
                    _buildBoostOption(
                      title: "1 Day – ₹19",
                      description:
                          "Get 24-hour global visibility for just ₹19.",
                      color: Colors.orange,
                      onPressed: () {
                        // TODO: Integrate payment flow
                        setState(() {
                          _selectedPlanName = "1 Day – ₹19";
                        });

                        // _startPaymentViaFirebase(
                        //   amount: 1.0,
                        //   planName: "1 Day – ₹19",
                        // );
                      },
                    ),
                    _buildBoostOption(
                      title: "1 Week – ₹99",
                      description: "Gain global reach for 7 days at ₹99.",
                      color: Colors.purple,
                      onPressed: () {
                        // TODO: Integrate payment flow
                        setState(() {
                          _selectedPlanName = "1 Week – ₹99";
                        });

                        // _startPaymentViaFirebase(
                        //   amount: 99.0,
                        //   planName: "1 Week – ₹99",
                        // );
                      },
                    ),
                    _buildBoostOption(
                      title: "1 Month – ₹249",
                      description:
                          "Enjoy maximum exposure for 30 days for ₹249.",
                      color: Colors.blue,
                      onPressed: () {
                        // TODO: Integrate payment flow
                        setState(() {
                          _selectedPlanName = "1 Month – ₹249";
                        });

                        // _startPaymentViaFirebase(
                        //   amount: 249.0,
                        //   planName: "1 Month – ₹249",
                        // );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(double screenWidth) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        children: [
          const TextSpan(
            text:
                'Unlocking the global benefits on Zizzle transforms your content strategy by propelling your posts and reels to the forefront of the platform. The global option ensures that your creations are not confined to your existing followers but are showcased prominently on the search and home screens of all users.\n\n',
          ),
          TextSpan(
            text:
                'What sets this feature apart is its adaptability. The global option operates solely when the Zizzle app is open, automatically disabling when closed. This nuanced approach gives users the flexibility to choose when their content receives global exposure, maintaining a balance between broad visibility and personal privacy.\n\n',
            style: const TextStyle(color: Colors.red),
          ),
          const TextSpan(
            text:
                'This feature encourages a diverse range of users to discover and appreciate your creativity, cultivating a thriving community where content resonates on a global scale.',
          ),
        ],
      ),
    );
  }

  Widget _buildBoostOption({
    required String title,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: mobileBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onPressed,
                child: const Text(
                  'Activate',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
