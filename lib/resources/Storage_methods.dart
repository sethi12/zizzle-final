import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
class StorageMethods{
  final FirebaseStorage _Storage = FirebaseStorage.instance;
  // adding image to firebase storage
Future<String> UploadImagetoStorage(String childname,Uint8List file,bool isPost,String uid)async{

Reference ref  =  _Storage.ref().child(childname).child(uid);
 UploadTask uploadTask = ref.putData(file);

  TaskSnapshot snap =  await uploadTask;
    String downloadurl = await  snap.ref.getDownloadURL();
    return downloadurl;
}
}