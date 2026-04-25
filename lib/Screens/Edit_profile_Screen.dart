import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Screens/Add_post_screen_details.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/profile_screen.dart';
import '/resources/Storage_methods.dart';
import '/utils/colors.dart';
import 'dart:io';
import '/utils/utils.dart';
import '/widgets/text_feild_input.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  var userdata = {};
  var storeduid;
  var myusername;
  var photo;
  Uint8List? _image;
  var _isLoading;
  bool _ischanged = false;
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController Catecontroller = TextEditingController();
  final TextEditingController BioController = TextEditingController();
  final TextEditingController _mobilecontroller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: ParticleBurstLoaderr())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: const Text("Edit Profile"),
              actions: [
                TextButton(
                  onPressed: () => Updatetask(),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: _image != null
                              ? MemoryImage(_image!)
                              : NetworkImage(photo) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: SelectImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  buildFieldLabel("Name"),
                  buildTextField(namecontroller, "Enter Your Name"),
                  const SizedBox(height: 16),
                  buildFieldLabel("Category"),
                  buildTextField(Catecontroller, "e.g. Influencer, Creator"),
                  const SizedBox(height: 16),
                  buildFieldLabel("Bio"),
                  buildTextField(BioController, "Enter Your Bio"),
                  const SizedBox(height: 16),
                  buildFieldLabel("Contact"),
                  buildTextField(
                      _mobilecontroller, "Enter Your Contact Number"),
                ],
              ),
            ),
          );
  }

  Widget buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  getdata() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    myusername = prefs.getString('username');
    print(myusername);
    try {
      var existingUser =
          await _firestore.collection("users").doc(myusername).get();
      print(existingUser);
      if (existingUser.exists) {
        storeduid = existingUser.data()?['uid'];
        print("Storeduid==================${storeduid}");
        photo = existingUser.data()?['photourl'];
        print('photo=======${photo}');
      }

      setState(() {});
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  void SelectImage() async {
    Uint8List profileimage = await PickImage(ImageSource.gallery);
    setState(() {
      _image = profileimage;
    });
  }

  void Updatetask() async {
    if (_image != null) {
      setState(() {
        _isLoading = true;
      });
      String photourl = await StorageMethods()
          .UploadImagetoStorage("ProfilePics", _image!, false, storeduid);
      await _firestore.collection('users').doc(myusername).update({
        'photourl': photourl,
      });
      QuerySnapshot querySnapshot = await _firestore
          .collection('Posts')
          .where('uid', isEqualTo: storeduid)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Get the document ID
        String documentId = documentSnapshot.id;

        // Update the specific document using the document ID
        await _firestore.collection('Posts').doc(documentId).update({
          'profimage': photourl,
          // add other fields you want to update here
        });
      }
      QuerySnapshot querySnapshott = await _firestore
          .collection('reels')
          .where('uid', isEqualTo: storeduid)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshott.docs) {
        // Get the document ID
        String documentId = documentSnapshot.id;

        // Update the specific document using the document ID
        await _firestore.collection('reels').doc(documentId).update({
          'profilephoto': photourl,
          // add other fields you want to update here
        });
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
      // part of ifff ======================
    } else {
      setState(() {
        _isLoading = true;
      });
      if (namecontroller.text.isNotEmpty &&
          BioController.text.isEmpty &&
          Catecontroller.text.isEmpty &&
          _mobilecontroller.text.isEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'name': namecontroller.text,
        });
      } else if (namecontroller.text.isEmpty &&
          BioController.text.isNotEmpty &&
          Catecontroller.text.isEmpty &&
          _mobilecontroller.text.isEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'Bio': BioController.text,
        });
      } else if (namecontroller.text.isEmpty &&
          BioController.text.isEmpty &&
          Catecontroller.text.isNotEmpty &&
          _mobilecontroller.text.isEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'Category': Catecontroller.text,
        });
      } else if (namecontroller.text.isEmpty &&
          BioController.text.isEmpty &&
          Catecontroller.text.isEmpty &&
          _mobilecontroller.text.isNotEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'number': _mobilecontroller.text.trim(),
        });
      } else if (namecontroller.text.isNotEmpty &&
          BioController.text.isNotEmpty &&
          Catecontroller.text.isNotEmpty &&
          _mobilecontroller.text.isNotEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'name': namecontroller.text.trim(),
          'Bio': BioController.text.trim(),
          'Category': Catecontroller.text.trim(),
          'number': _mobilecontroller.text.trim()
        });
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }
}
