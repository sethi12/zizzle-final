import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/Screens/profile_screen.dart';
import '/utils/colors.dart';
import '/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonetizationPolicy extends StatefulWidget {
  const MonetizationPolicy({super.key});

  @override
  State<MonetizationPolicy> createState() => _MonetizationPolicyState();
}

class _MonetizationPolicyState extends State<MonetizationPolicy> {
  var username;
  var _firestore = FirebaseFirestore.instance;
  var existinguser;
  bool done = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdetails();
  }

  void getdetails() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    print(username);
    existinguser = await _firestore.collection("users").doc(username).get();
    print(existinguser.data()?['Monetization']);
  }

  void monitizeaccount() async {
    if (existinguser.data()?['Monetization'] == "Not Monitized") {
      await _firestore
          .collection("users")
          .doc(username)
          .update({'Monetization': "Monitized"});
      setState(() {
        done = true;
      });
      if (done == true) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ProfileScreen()));
        showSnackBar(
            "Congratulations your Account has been Monetized and you got a Zizzle verified Badge",
            context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text("Monetization"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                  children: [
                    TextSpan(
                        text:
                            'Dear users\n\nA warm welcome to our community! We are thrilled to announce an exciting opportunity for all content creators. As part of our new monetization policy, '),
                    TextSpan(
                        text:
                            "we're offering a fantastic deal – 1 CAD for every 1000 views on your reels!",
                        style: TextStyle(color: Colors.blue)),
                    TextSpan(
                        text:
                            '\n\nYour creativity is valuable, and we believe in rewarding you for the engaging content you bring to our platform. This is just the beginning of our commitment to supporting and celebrating your talent. Get ready to turn your passion into profit and embark on a journey of creative fulfillment.\n\nMoreover, we are excited to share that upon monetizing, you will earn the coveted Zizzle verified badge, showcasing your status as a recognized and valued member of our community.\n\nThank you for being an essential part of our community. We look forward to seeing the incredible content you\'ll share and the success you\'ll achieve with this new monetization policy.\n\nHappy creating!'),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              monitizeaccount();
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.blueAccent,
              width: double.infinity, // Set your desired color
              child: Center(
                child: Text(
                  'Monetize Account',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
