import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '/Screens/Add_post_screen_details.dart';
import 'package:uuid/uuid.dart';

class PostStorageMethods {
  final FirebaseStorage _Storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var uid = AddpostScreenDetails.uid;
  // adding image to firebase storage
  Future<String> UploadImagetoStorage(
      String childname, Uint8List file, bool isPost) async {
    Reference ref = _Storage.ref().child(childname).child(uid);

    if (isPost) {
      String id = Uuid().v1();
      ref = ref.child(id);
    }
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;
    String downloadurl = await snap.ref.getDownloadURL();
    return downloadurl;
  }
}
