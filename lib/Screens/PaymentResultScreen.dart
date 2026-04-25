// payment_result_screen.dart (New File)
import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final String? status;
  final String? orderId;
  final String? uid;

  const PaymentResultScreen({super.key, this.status, this.orderId, this.uid});

  @override
  Widget build(BuildContext context) {
    String message;
    Color color;

    if (status == 'PAID') {
      message = "✅ Success! Verified Badge Purchased for user $uid!";
      color = Colors.green;
      // *** THIS IS THE VERIFICATION POINT IN FLUTTER ***
      print("Payment verification completed: true for Order ID $orderId");
      // You can call a service here to update the user's status in your database
    } else if (status == 'FAILED' || status == 'CANCELLED') {
      message = "❌ Payment Failed or Canceled. Please try again.";
      color = Colors.red;
      print("Payment verification completed: false");
    } else {
      message = "⚠️ Unknown payment result: $status";
      color = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Payment Result")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
