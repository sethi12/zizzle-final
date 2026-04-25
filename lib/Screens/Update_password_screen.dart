import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/utils/colors.dart';

import '../widgets/text_feild_input.dart';

class UpadtePassword extends StatefulWidget {
  final email;
  const UpadtePassword({super.key, required this.email});

  @override
  State<UpadtePassword> createState() => _UpadtePasswordState();
}

class _UpadtePasswordState extends State<UpadtePassword> {
  final TextEditingController updatepassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: mobileBackgroundColor,
          title: Text("Update Your Password"),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Center(
                child: Text(
              "Update Your password after reseting from the mail you got for Your Account for keeping you logged in",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            )),
            SizedBox(
              height: 25,
            ),
            TextFeildInput(
                textInputType: TextInputType.text,
                textEditingController: updatepassword,
                hinttext: "update your password"),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                width: double.infinity,
                padding: EdgeInsets.all(1),
                child: ElevatedButton(
                  onPressed: () {
                    if (updatepassword.text.isNotEmpty) {
                      updatePasswordInFirestore(
                          widget.email, updatepassword.text);
                    }
                  },
                  child: Text("Update Password"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updatePasswordInFirestore(String userEmail, String newPassword) async {
    try {
      QuerySnapshot<Map<String, dynamic>> userQuery = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // Assuming there's only one user with the given email
        DocumentReference userDocRef = userQuery.docs.first.reference;

        // Update the 'password' field in Firestore
        await userDocRef.update({'password': newPassword});
        print('Password updated in Firestore successfully.');
      } else {
        print('User not found with email: $userEmail');
      }
      Navigator.pop(context);
    } catch (error) {
      print('Error updating password in Firestore: $error');
    }
  }
}
