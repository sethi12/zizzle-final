import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:zizzle/Controllers/reelsfeed.dart';
import '/Screens/Search_screen.dart';
import '/Screens/add_screen.dart';
import '/Screens/feed_screen.dart';
import '/Screens/profile_screen.dart';
import '/Screens/reelfeedui.dart';
import '/Screens/login_screen.dart';
import '/utils/colors.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _navigationTapped(int page) {
    if (_page == 3 && page != 3) {
      final reelsController = Get.find<ReelsController>();
      reelsController.pauseAllVideos();
    }
    pageController.jumpToPage(page);
  }

  void _onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: PageView(
        controller: pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const AddScreen(),
          ReelFeedUI(),
          FirebaseAuth.instance.currentUser?.uid != null
              ? ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid)
              : ProfileScreen(username: LoginScreen.globalusername),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: mobileBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: mobileBackgroundColor,
          type: BottomNavigationBarType.fixed,
          onTap: _navigationTapped,
          currentIndex: _page,
          selectedItemColor: primaryColor,
          unselectedItemColor: secondaryColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_sharp),
              activeIcon: Icon(Icons.video_collection_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
