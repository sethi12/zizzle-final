import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '/Screens/login_screen.dart';
import '/utils/utils.dart';
import '../utils/colors.dart';
import '../widgets/text_feild_input.dart';
import 'Screen_Signup.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  static String username = _SignupScreenState._usernamecontroller.text;
  static Uint8List? profilepic = _SignupScreenState._image;
}

class _SignupScreenState extends State<SignupScreen> {
  static final TextEditingController _usernamecontroller =
      TextEditingController();
  static Uint8List? _image;

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   _usernamecontroller.dispose();
  // }

  void SelectImage() async {
    Uint8List profileimage = await PickImage(ImageSource.gallery);
    setState(() {
      _image = profileimage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                mobileBackgroundColor,
                Color.fromRGBO(10, 19, 41, 1.0),
                Color.fromRGBO(10, 19, 41, 1.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 1),

              Image.asset("assets/applogo.jpeg", height: 64),

              const SizedBox(height: 44),

              // 🔘 Profile Image Picker
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqKCA0WCWoqjIX5hwq6JFfaakFaA2qzhHOUGdFx7vARMfel6LqTGZPT0Du&s=10",
                          ),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: SelectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 📝 Username field
              TextFeildInput(
                textInputType: TextInputType.text,
                textEditingController: _usernamecontroller,
                hinttext: "Enter your Username",
              ),

              const SizedBox(height: 24),

              // ✅ Next Button
              InkWell(
                onTap: () {
                  String username = _usernamecontroller.text.trim();

                  if (username.isEmpty) {
                    showSnackBar('Please create a username', context);
                  } else if (_image == null) {
                    showSnackBar('Please upload a profile picture', context);
                  } else if (username.length < 3) {
                    showSnackBar(
                        'Username must be at least 3 characters', context);
                  } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
                    showSnackBar(
                      'Username can only contain letters, numbers, and underscores (_) with no spaces',
                      context,
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen2()),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: blueColor.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              Flexible(child: Container(), flex: 2),

              const SizedBox(height: 12),

              // 🔁 Login navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an account?",
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
