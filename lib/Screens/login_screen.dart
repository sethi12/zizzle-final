import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:zizzle/widgets/pulseloader.dart';

import '/Screens/signup_screen.dart';
import '/resources/auth_methods.dart';
import '/responsive/responsive_screen_layout.dart';
import '/utils/utils.dart';
import '/widgets/text_feild_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/web_screen_layout.dart';
import '../services/alert_service.dart';
import '../services/navigation_service.dart';
import '../utils/colors.dart';
import 'Screen_Signup.dart';
import 'Update_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  static final globalusername = _LoginScreenState._usernamecontroller.text;
}

class _LoginScreenState extends State<LoginScreen> {
  static final TextEditingController _usernamecontroller =
      TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  late String Email = "";
  bool _isLoading = false;
  late Navigationservice _navigationservice;
  late AlertService _alertService;
  final GetIt _getIt = GetIt.instance;
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   _usernamecontroller.dispose();
  //   _passwordcontroller.dispose();
  // }

  @override
  void initState() {
    super.initState();
    _navigationservice = _getIt.get<Navigationservice>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mobileBackgroundColor,
        body: Container(
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
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                  Image.asset(
                    'assets/applogo.jpeg',
                    height: 80,
                  ),
                  const SizedBox(height: 64),
                  TextFeildInput(
                    textInputType: TextInputType.text,
                    textEditingController: _usernamecontroller,
                    hinttext: "Enter your username/email",
                  ),
                  const SizedBox(height: 24),
                  TextFeildInput(
                    textInputType: TextInputType.text,
                    textEditingController: _passwordcontroller,
                    ispass: true,
                    hinttext: "Enter your password",
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          if (_usernamecontroller.text.contains('@')) {
                            resetPassword(_usernamecontroller.text);
                          } else {
                            showSnackBar("Please enter your email", context);
                          }
                        },
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () {
                      if (_usernamecontroller.text.contains('@')) {
                        Email = _usernamecontroller.text;
                        LoginUserwithEmail();
                      } else {
                        LoginUserwithUsername();
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
                      child: _isLoading
                          ? const Center(
                              child: ParticleBurstLoaderr(),
                            )
                          : const Text(
                              "Log in",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          " Sign up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }

  void LoginUserwithUsername() async {
    if (_usernamecontroller.text.isNotEmpty ||
        _passwordcontroller.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      String username = _usernamecontroller.text.trim();
      String password = _passwordcontroller.text.trim();
      String ress = await Authmethods()
          .LoginUserwithUsername(usernamee: username, passwordd: password);
      print("Username found demo $ress");
      if (ress == "Logged in Successfully") {
        _alertService.showToast(text: "logged in", icon: Icons.check);
        print(ress);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ResponsiveLayout(
                MobileScreenLayout: MobileScreenLayout(),
                WebScreenLayout: WebScreenLayout())));
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
      if (ress == "Wrong password") {
        showSnackBar(ress, context);
        setState(() {
          _isLoading = false;
        });
      }
      if (ress == "No user Found") {
        showSnackBar(ress, context);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showSnackBar("some error Occurred", context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void LoginUserwithEmail() async {
    setState(() {
      _isLoading = true;
    });
    String res = await Authmethods().LoginUserwithemailandpassword(
        email: Email, password: _passwordcontroller.text);
    print(Email);
    if (res == "Logged in Succsesfully") {
      showSnackBar(res, context);

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
              MobileScreenLayout: MobileScreenLayout(),
              WebScreenLayout: WebScreenLayout())));
    } else {
      showSnackBar(res, context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UpadtePassword(email: email)));
    } catch (e) {
      print(e.toString());
    }
  }
}
