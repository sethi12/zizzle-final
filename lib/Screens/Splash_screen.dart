import 'package:flutter_svg/flutter_svg.dart';
import 'package:zizzle/resources/firestore_reels_updation.dart';
import 'package:zizzle/resources/loaderconfig.dart';
import 'package:zizzle/resources/updation_firestore.dart';
import '/Screens/login_screen.dart';
import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_screen_layout.dart';
import '../responsive/web_screen_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
  static String? username = _SplashScreenState.username;
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static String? username;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      checkLoginState();
    });
    _initLoader();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initLoader() async {
    await FirestoreUpdater().initLoader();
    print("Loader called in splashscreen");
    // after this, everywhere ParticleBurstLoader() will use Firestore values
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/applogo.jpeg',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 16),
              const Text(
                "create, post, earn",
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 150),
              const Text(
                "from",
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "InbredTechno",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/companylogo.jpeg',
                    height: 30,
                    width: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');

    if (username != null && username!.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            MobileScreenLayout: MobileScreenLayout(),
            WebScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
    await FirestoreUpdater().updateGlobalOptionStatusForUser();
    await FirestoreReelUpdater().updateGlobalOptionStatusForUser();
    await FirestoreUpdater().checkAndUpdateVerificationStatus();
  }
}
