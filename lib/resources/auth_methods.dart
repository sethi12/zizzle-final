import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/resources/firestore_reels_updation.dart';
import 'package:zizzle/resources/updation_firestore.dart';
import '../services/Notification_service.dart';
import '/Screens/login_screen.dart';
import '/resources/Storage_methods.dart';
import '/model/user.dart' as model;
import '/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authmethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateFcmTokenForUser(String username) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .update({
          'fcmToken': token,
          'lastUpdatedfcmtoken': FieldValue.serverTimestamp(),
        });
        print("FCM Token Updated in Firestore: $token");
      }
    } catch (e) {
      print("Error updating FCM Token: $e");
    }
  }

  Future<String> siginUser(
      {required String username,
      required String number,
      required String email,
      required String password,
      required Uint8List file}) async {
    String res = "Some Error Occured";
    try {
      if (username.isNotEmpty || email.isNotEmpty || password.isNotEmpty) {
        var existinguser =
            await _firestore.collection('users').doc(username).get();
        if (existinguser.exists) {
          SnackBar(
            content: Text(
                "User already exists. Please choose a different username."),
          );
          res = "User already exists. Please choose a different username.";
        } else {
          //firebase auth ------
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          //Storage Methods
          String photourl = await StorageMethods().UploadImagetoStorage(
              "ProfilePics", file, false, _auth.currentUser!.uid);

          model.User user = model.User(
              uid: userCredential.user!.uid,
              username: username,
              email: email,
              password: password,
              followers: [],
              following: [],
              photourl: photourl,
              name: "",
              Category: "",
              Bio: "",
              Monetization: "Not Monitized",
              number: number);
          // with firestore ----
          await _firestore.collection('users').doc(username).set(user.toJson());
          res = "User registered successfully!";
        }
      } else {
        res = "User registered successfully!";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == "invalid-email") {
        res = "the email is badly formatted ";
      } else if (err.code == "weak-password") {
        res = "Password should be at least 6 charecters";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  // logging in user with username

  Future<String> LoginUserwithUsername(
      {required usernamee, required passwordd}) async {
    String ress = "No user Found";
    try {
      String username = usernamee.toString().trim();
      String password = passwordd.toString().trim();

      var existingUser =
          await _firestore.collection("users").doc(username).get();
      print(existingUser);
      if (existingUser.exists) {
        var storedPassword = existingUser.data()?['password'];
        var storedemail = existingUser.data()?['email'];
        print(storedemail);
        print(storedPassword);
        if (password == storedPassword) {
          await _auth.signInWithEmailAndPassword(
              email: storedemail, password: storedPassword);
          ress = "Logged in Successfully";
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('username', username);
          prefs.setString('email', storedemail);
          // 👉 Update FCM Token after login
          await updateFcmTokenForUser(username);

          // 👉 Start listening for token refresh
          NotificationService().listenForTokenRefresh(username);
          // print("Follow $followers");
          await FirestoreUpdater().updateGlobalOptionStatusForUser();
          await FirestoreReelUpdater().updateGlobalOptionStatusForUser();
          await FirestoreUpdater().checkAndUpdateVerificationStatus();
          print(ress);
        } else {
          ress = "Wrong password";
          print(ress);
        }
      } else {
        print(ress);
      }
    } catch (err) {
      ress = err.toString();
    }
    return ress;
  }

// logging in user with email and password
  Future<String> LoginUserwithemailandpassword(
      {required String email, required String password}) async {
    String res = "Some Error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        await FirestoreUpdater().updateGlobalOptionStatusForUser();
        await FirestoreReelUpdater().updateGlobalOptionStatusForUser();
        await FirestoreUpdater().checkAndUpdateVerificationStatus();
        res = "Logged in Succsesfully";

        QuerySnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: email)
                .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Retrieve details from the first matching document
          // var userData = userSnapshot.docs[0].data()['uid'];
          String Eusername = userSnapshot.docs[0].data()['username'];
          String Eemail = userSnapshot.docs[0].data()['email'];
          String euid = userSnapshot.docs[0].data()['uid'];
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('username', Eusername);
          prefs.setString('email', Eemail);
          prefs.setString('uid', euid);
          // 👉 Update FCM Token after login
          await updateFcmTokenForUser(Eusername);

          // 👉 Start listening for token refresh
          NotificationService().listenForTokenRefresh(Eusername);
        }
      } else {
        res = "please enter all the feilds";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
