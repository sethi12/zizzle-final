import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Screens/login_screen.dart';
import '/Screens/signup_screen.dart';
import '/Screens/signup_screen.dart';
import '/utils/utils.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import '../widgets/text_feild_input.dart';

class SignupScreen2 extends StatefulWidget {
  const SignupScreen2({super.key});

  @override
  State<SignupScreen2> createState() => _SignupScreenState2();
}

class _SignupScreenState2 extends State<SignupScreen2> {
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String username = SignupScreen.username;
  Uint8List? _profileimage = SignupScreen.profilepic;
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _passwordcontroller.dispose();
    _emailcontroller.dispose();
    _mobileController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // 🔵 App Title
                const Text(
                  "Zizzle",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 50),

                // 🔢 Mobile number field
                TextFeildInput(
                  textInputType: TextInputType.phone,
                  textEditingController: _mobileController,
                  hinttext: "Enter your mobile",
                ),
                const SizedBox(height: 20),

                // 📧 Email field
                TextFeildInput(
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailcontroller,
                  hinttext: "Enter your Email",
                ),
                const SizedBox(height: 20),

                // 🔒 Password field
                TextFeildInput(
                  textInputType: TextInputType.visiblePassword,
                  textEditingController: _passwordcontroller,
                  ispass: true,
                  hinttext: "Enter your password",
                ),

                const SizedBox(height: 32),

                // 🚀 Sign Up Button
                InkWell(
                  onTap: SignUpUser,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [blueColor, Color.fromARGB(255, 0, 140, 255)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const ParticleBurstLoaderr()
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider and navigation to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(width: 6),
                  ],
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void SignUpUser() async {
    final email = _emailcontroller.text.trim();
    final password = _passwordcontroller.text.trim();
    final mobile = _mobileController.text.trim();

    if (username.isEmpty || _profileimage == null) {
      showSnackBar("Profile image or username is missing", context);
      return;
    }

    if (mobile.isEmpty ||
        mobile.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      showSnackBar("Please enter a valid 10-digit mobile number", context);
      return;
    }

    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email)) {
      showSnackBar("Please enter a valid email address", context);
      return;
    }

    if (password.isEmpty || password.length < 6) {
      showSnackBar("Password must be at least 6 characters long", context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String res = await Authmethods().siginUser(
      username: username,
      email: email,
      password: password,
      number: mobile,
      file: _profileimage!,
    );

    if (res == "User registered successfully!") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      showSnackBar("$res Please login", context);
    } else {
      showSnackBar(res, context);
    }

    setState(() {
      _isLoading = false;
    });
  }
}
