import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zizzle/Screens/Archive_screen.dart';
import 'package:zizzle/Screens/Chat_Passwords_Screen.dart';
import 'package:zizzle/Screens/LoaderCustomizationscreen.dart';
import 'package:zizzle/Screens/VerifyBadgeScreen.dart';
import 'package:zizzle/Screens/close_friends_screen.dart';
import 'package:zizzle/Screens/collabuserpostscreen.dart';
import 'package:zizzle/Screens/profileimagecheckprivatescreen.dart';
import 'package:zizzle/Screens/savedpostandreel_screen.dart';
import 'package:zizzle/widgets/blueTick.dart';
import 'package:zizzle/widgets/pulseloader.dart';

import '/Screens/followersScreen.dart';
import '/Screens/followingScreen.dart';
import '/model/user.dart' as u;
import 'package:rxdart/rxdart.dart' as rx;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import '/Controllers/profile_video_controller.dart';
import '/Screens/CollabReelScreen.dart';
import '/Screens/CollabRequst.dart';
import '/Screens/Edit_profile_Screen.dart';
import '/Screens/MonitizationScreen.dart';
import '/Screens/MonthlyTransaction.dart';
import '/Screens/Profile_reel_screen.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/WalletScreen.dart';
import '/Screens/add_post_screen.dart';
import '/Screens/add_reel_screen.dart';
import '/Screens/chat_screen.dart';
import '/Screens/pending_Screen.dart';
import '/Screens/profileimagecheckScreen.dart';
import '/Screens/reel_screen.dart';
import '/resources/firestoremethods.dart';
import '/utils/colors.dart';
import '/utils/utils.dart';
import '/widgets/CircleTickIcon.dart';
import '/widgets/CircleTickIconSearch.dart';
import '/widgets/CollabedReel.dart';
import '/widgets/followerscard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/alert_service.dart';
import '../services/auth_message_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../widgets/WalletScreenUi.dart';
import '../widgets/follow_button.dart';
import 'Update_password_screen.dart';
import 'login_screen.dart';

enum ProfileViewOption { Public, Reels, Private, collabs }

class ProfileScreen extends StatefulWidget {
  static final GlobalKey<_ProfileScreenState> globalKey =
      GlobalKey<_ProfileScreenState>();
  final String? uid;
  final String? username;
  u.User? user;
  ProfileScreen({super.key, this.uid, this.username, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userdata = {};
  int postLen = 0;
  int reelLen = 0;
  int totallen = 0;
  int followers = 0;
  int following = 0;
  bool isfollowing = false;
  bool myfollowing = false;
  bool _isLoading = false;
  String? myusername;
  var storeduid;
  var useruid;
  var usersnap;
  bool existance = false;
  var getstatus;
  late DateTime getexpirydate;
  ProfileViewOption selectedOption = ProfileViewOption.Public;
  final GetIt _getIt = GetIt.instance;
  late Navigationservice _navigationservice;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late AuthService _authService;
  Set<String> closeFriends = {};
  bool isclose = false;
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isauthenticaed = false;
  Widget _buildTabItem(String title, ProfileViewOption option) {
    final isSelected = selectedOption == option;
    const double selectedUnderlineHeight = 2.5;
    const double selectedUnderlineActiveWidth = 40.0;
    const double selectedUnderlineInactiveWidth = 0.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white54,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(top: 8),
            height: selectedUnderlineHeight,
            width: isSelected
                ? selectedUnderlineActiveWidth
                : selectedUnderlineInactiveWidth,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabItem("Posts", ProfileViewOption.Public),
        _buildTabItem("Reels", ProfileViewOption.Reels),
        _buildTabItem("Private", ProfileViewOption.Private),
        _buildTabItem("Collabs", ProfileViewOption.collabs),
      ],
    );
  }

  Widget _buildProfileTabsGuest() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabItem("Posts", ProfileViewOption.Public),
        _buildTabItem("Reels", ProfileViewOption.Reels),
        _buildTabItem("Collabs", ProfileViewOption.collabs),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    useruid = widget.uid;
    print(useruid);
    _navigationservice = _getIt.get<Navigationservice>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
  }

  Future<void> loadCloseFriends() async {
    try {
      // Fetch the user document based on their username or uid (assuming 'userdata['username']' holds the correct identifier)
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userdata[
              'username']) // or use userdata['uid'] if username is not available
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        // Check if the current user ID is in the closeFriends list
        if (data != null &&
            data['closeFriends'] != null &&
            data['closeFriends'].contains(storeduid)) {
          print("yesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyes");
          setState(() {
            isclose = true;
          });
        } else {
          setState(() {
            isclose = false;
          });
        }
      }
    } catch (e) {
      print('Error loading close friends: $e');
    }
  }

  Future<void> _checkBiometricSupport() async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        try {
          final bool canAuthenticateWithBiometrics =
              await _auth.canCheckBiometrics;
          if (canAuthenticateWithBiometrics) {
            final bool didAuthenticate = await _auth.authenticate(
                localizedReason: 'please authenticate to see passwords',
                options: const AuthenticationOptions(
                  biometricOnly: false,
                  stickyAuth: true,
                ));
            setState(() {
              _isauthenticaed = didAuthenticate;
            });
            if (_isauthenticaed == true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPasswordsScreen(
                            uid: storeduid,
                          )));
            }
          }
        } catch (e) {
          print(e.toString());
        }
      } else {
        print("Device does not support biometrics");
      }
    } catch (e) {
      print("Error checking biometric support: $e");
    }
  }

  getdata() async {
    setState(() {
      _isLoading = true;
    });

    print(widget.uid);
    print(widget.username);
    final prefs = await SharedPreferences.getInstance();
    myusername = prefs.getString('username');

    try {
      var existingUser = await FirebaseFirestore.instance
          .collection("users")
          .doc(myusername)
          .get();
      print(existingUser);
      if (existingUser.exists) {
        storeduid = existingUser.data()?['uid'];
        print(storeduid);
      }
      if (widget.uid != null) {
        usersnap = await FirebaseFirestore.instance
            .collection("users")
            .where('uid',
                isEqualTo: widget
                    .uid) // Use widget.uid instead of FirebaseAuth.instance.currentUser!.uid
            .get();
      } else {
        usersnap = await FirebaseFirestore.instance
            .collection("users")
            .where('uid',
                isEqualTo:
                    storeduid) // Use widget.uid instead of FirebaseAuth.instance.currentUser!.uid
            .get();
        // Use widget.uid instead of FirebaseAuth.instance.currentUser!.uid
      }
      if (usersnap.docs.isNotEmpty) {
        userdata = usersnap.docs.first.data() as Map<String, dynamic>;
        isfollowing = (userdata['followers'] as List).contains(myusername);
        myfollowing =
            (userdata['following'] as List).contains(userdata['username']);
        // get the post length
        var postSnap = await FirebaseFirestore.instance
            .collection("Posts")
            .where("uid", isEqualTo: userdata['uid'])
            .get();
        var Reelsnap = await FirebaseFirestore.instance
            .collection("reels")
            .where("uid", isEqualTo: userdata['uid'])
            .get();

        postLen = postSnap.docs.length;
        reelLen = Reelsnap.docs.length;
        totallen = postLen + reelLen;
        followers = (userdata['followers'] as List).length;
        following = (userdata['following'] as List).length;
        var paiduser = await FirebaseFirestore.instance
            .collection("Requests")
            .doc(myusername)
            .get();
        if (paiduser.exists) {
          existance = true;
          print(existance);
          getstatus = paiduser.data()?['status'];
          Timestamp timestamp = paiduser.data()?['Expiry Date'];
          getexpirydate = timestamp.toDate(); // Convert Timestamp to DateTime
          print(getstatus);
          print(getexpirydate);

          if (getexpirydate != null && getexpirydate.isAfter(DateTime.now())) {
            var daysRemaining = getexpirydate.difference(DateTime.now()).inDays;
            print('Days remaining until expiry: $daysRemaining days');
          } else if (getexpirydate != null &&
              getexpirydate.isBefore(DateTime.now())) {
            print('The expiry date has already passed.');
            // Add logic for handling the case when the expiry date has passed (e.g., show a message)
          } else {
            print('Invalid or missing expiry date.');
          }
        }

        setState(() {});
      }
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
    loadCloseFriends();
  }

  String? getCondition() {
    if (widget.uid != null) {
      return widget.uid;
    } else {
      return storeduid ?? userdata['uid'];
    }
  }

  void openSettingsIcon() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(25)),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Settings",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Divider(
                                height: 1, thickness: 1, color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.archive_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Archives",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ArchiveScreen(username: myusername)),
                                );
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(
                                  Icons.monetization_on_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Monetization",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                if (followers >= 500) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MonetizationPolicy()),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: mobileBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Required Followers 500",
                                              style: TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.lock_reset_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Change Password",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () async {
                                Navigator.of(context).pop();
                                await resetPassword(userdata['email']);
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.chat_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Chat Passwords",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                _checkBiometricSupport();
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Wallet",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                if (userdata['Monetization'] == "Monitized") {
                                  if (existance == true &&
                                      getstatus == 'pending') {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PendingScreen()));
                                  } else if (existance == true &&
                                      getstatus == 'Approved' &&
                                      getexpirydate.isAfter(DateTime.now())) {
                                    print(getexpirydate);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MonthlyTransaction()));
                                  } else if (existance == true &&
                                      getstatus == 'Approved' &&
                                      getexpirydate.isBefore(DateTime.now())) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WalletScreen()));
                                  } else if (existance == false) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WalletScreen()));
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: mobileBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Account Not Monetized",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.post_add_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Post Collab Requests",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CollabRequests(username: myusername)),
                                );
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(
                                  Icons.video_collection_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Reel Collab Requests",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => CollabReelScreen(
                                          username: myusername)),
                                );
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.bookmark_outline,
                                  color: Colors.white),
                              title: const Text(
                                "Saved",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SavedScreen(username: myusername)),
                                );
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.people_outline,
                                  color: Colors.white),
                              title: const Text(
                                "Close Friends",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () async {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CloseFriendsScreen(uid: storeduid)),
                                );
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.blur_circular,
                                  color: Colors.white),
                              title: const Text(
                                "Customize loading",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () async {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LoaderCustomizationScreen(
                                            username: myusername,
                                          )),
                                );
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.verified_outlined,
                                  color: Colors.white),
                              title: const Text(
                                "Request Verification",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onTap: () async {
                                if (!userdata.containsKey('Verified') ||
                                    userdata['Verified'] == false) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerifyBadgeScreen(
                                        username: myusername,
                                        email: userdata['email'],
                                        number: userdata['number'],
                                      ),
                                    ),
                                  );
                                } else {
                                  _alertService.showToast(
                                    text: "You Are Verified User",
                                    icon: Icons.check,
                                  );
                                }
                              },
                            ),
                            const Divider(color: secondaryColor),
                            ListTile(
                              leading: const Icon(Icons.logout_outlined,
                                  color: Colors.redAccent),
                              title: const Text(
                                "Log Out",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors
                                      .redAccent, // Using a distinct color for this action
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                Navigator.of(context)
                                    .pop(); // Close the bottom sheet first
                                await _logout(context);
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ))));
        });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: ParticleBurstLoaderr())
        : Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              elevation: 0,
              title: Row(
                children: [
                  Text(
                    userdata['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (userdata['Verified'] == true)
                    const BlueTick()
                  else if (userdata['Monetization'] == "Monitized")
                    CircleTickIconSearch()
                  else
                    const SizedBox.shrink()
                ],
              ),
              centerTitle: false,
              actions: [
                (storeduid == widget.uid) ||
                        (widget.uid == null && storeduid == userdata['uid'])
                    ? Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(25)),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(25)),
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20),
                                              child: Text(
                                                "Create",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: secondaryColor),
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.add_a_photo_outlined,
                                                  color: Colors.white),
                                              title: const Text(
                                                "Post",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddPostScreen()),
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.video_call_outlined,
                                                  color: Colors.white),
                                              title: const Text(
                                                "Reel",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddReelScreen()),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.add_box_outlined,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              openSettingsIcon();
                            },
                            icon: const Icon(
                              Icons.settings_outlined,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink()
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: secondaryColor.withOpacity(0.2),
                            backgroundImage: NetworkImage(userdata['photourl']),
                            radius: 45,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn(totallen, "posts"),
                                    GestureDetector(
                                        onTap: () {
                                          print(
                                              (userdata['followers'] as List));
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowersScreen(
                                                        uid: widget.uid,
                                                      )));
                                        },
                                        child: _buildStatColumn(
                                            followers, "followers")),
                                    GestureDetector(
                                        onTap: () {
                                          print(
                                              (userdata['following'] as List));
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Followingscreen(
                                                        uid: widget.uid,
                                                      )));
                                        },
                                        child: _buildStatColumn(
                                            following, "following")),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    (storeduid == widget.uid) ||
                                            (widget.uid == null &&
                                                storeduid == userdata['uid'])
                                        ? FollowButton(
                                            text: "Edit Profile",
                                            bordercolor:
                                                Colors.white.withOpacity(0.5),
                                            backgroundcolor:
                                                mobileBackgroundColor,
                                            textcolor: Colors.white,
                                            function: () =>
                                                Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfileScreen()),
                                            ),
                                          )
                                        : isfollowing
                                            ? FollowButton(
                                                text: "Unfollow",
                                                bordercolor: Colors.blue
                                                    .withOpacity(0.5),
                                                backgroundcolor:
                                                    mobileBackgroundColor,
                                                textcolor: Colors.white,
                                                function: () async {
                                                  await Firestoremethods()
                                                      .followuser(myusername!,
                                                          userdata['username']);
                                                  setState(() {
                                                    isfollowing = false;
                                                    followers--;
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                text: "Follow",
                                                bordercolor: Colors.transparent,
                                                backgroundcolor: Colors.blue,
                                                textcolor: Colors.white,
                                                function: () async {
                                                  await Firestoremethods()
                                                      .followuser(myusername!,
                                                          userdata['username']);
                                                  setState(() {
                                                    isfollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              ),
                                  ],
                                ),
                                (storeduid == widget.uid) ||
                                        (widget.uid == null &&
                                            storeduid == userdata['uid'])
                                    ? const SizedBox()
                                    : FollowButton(
                                        text: "Message",
                                        bordercolor:
                                            Colors.white.withOpacity(0.5),
                                        backgroundcolor: mobileBackgroundColor,
                                        textcolor: Colors.white,
                                        function: () async {
                                          final chatexists =
                                              await _databaseService
                                                  .checkchatexists(
                                            _authService.getCurrentUser()!.uid,
                                            widget.user!.uid,
                                          );
                                          print("Chat exists: $chatexists");
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  chatuser: widget.user),
                                            ),
                                          );
                                          if (!chatexists) {
                                            await _databaseService.createchats(
                                                _authService
                                                    .getCurrentUser()!
                                                    .uid,
                                                widget.user!.uid);
                                            print("Chat created between users");
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                    chatuser: widget.user),
                                              ),
                                            );
                                          }
                                        },
                                      )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  userdata['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                if (userdata['Verified'] == true)
                                  const BlueTick()
                                else if (userdata['Monetization'] ==
                                    "Monitized")
                                  CircleTickIconSearch()
                                else
                                  const SizedBox.shrink()
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userdata['Category'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userdata['Bio'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 30),
                (storeduid == widget.uid) ||
                        (widget.uid == null && storeduid == userdata['uid']) ||
                        (isclose == true)
                    ? _buildProfileTabs()
                    : _buildProfileTabsGuest(),
                const Divider(color: Colors.white24, height: 30),
                StreamBuilder(
                  stream: getPostsByOptionStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: ParticleBurstLoaderr(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData ||
                        (snapshot.data! as dynamic).docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No content to display.',
                          style: TextStyle(color: secondaryColor),
                        ),
                      );
                    }
                    return GridView.builder(
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: secondaryColor.withOpacity(0.1),
                          ),
                          child: selectedOption == ProfileViewOption.Reels ||
                                  selectedOption == ProfileViewOption.collabs
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (useruid != null) {
                                          if (snap['collabusername'] !=
                                              userdata['username']) {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileVideoScreen(
                                                            uid: useruid,
                                                            videoid:
                                                                snap['id'])));
                                          } else if (snap['collabusername'] ==
                                              userdata['username']) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Collabuserpostscreen(
                                                            collabusername:
                                                                userdata[
                                                                    'username'],
                                                            videoid:
                                                                snap['id'])));
                                          }
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileVideoScreen(
                                                          uid: storeduid,
                                                          videoid:
                                                              snap['id'])));
                                        }
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image(
                                          image:
                                              NetworkImage((snap['thumbnail'])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  bottom: Radius.circular(10)),
                                        ),
                                        child: Text(
                                          (snap['views'] >= 1000)
                                              ? "${(snap['views'] / 1000).toStringAsFixed(snap['views'] % 1000 == 0 ? 0 : 1)}k views"
                                              : "${snap['views']} views",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (snap['Audience'] == "Private")
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : InkWell(
                                  onTap: () {
                                    if (useruid != null) {
                                      if (snap['Audience'] == "Public" &&
                                          snap['collabusername'] !=
                                              userdata['username']) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfiileImageCheckScreen(
                                                        uid: useruid)));
                                      } else if (snap['Audience'] ==
                                          "Private") {
                                        print(useruid);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Profileimagecheckprivatescreen(
                                                        uid: useruid)));
                                      }
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image(
                                      image: NetworkImage((snap['posturl'])),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
  }

  Stream<QuerySnapshot> getPostsByOptionStream() {
    if (selectedOption == ProfileViewOption.Reels) {
      if ((storeduid == widget.uid) ||
          (widget.uid == null && storeduid == userdata['uid']) ||
          (isclose == true)) {
        return FirebaseFirestore.instance
            .collection("reels")
            .where('uid', isEqualTo: getCondition())
            .where("Archive", isEqualTo: false)
            .snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection("reels")
            .where('uid', isEqualTo: getCondition())
            .where('Audience', isEqualTo: 'Public')
            .snapshots();
      }
    } else if (selectedOption == ProfileViewOption.Private) {
      return FirebaseFirestore.instance
          .collection("Posts")
          .where('uid', isEqualTo: getCondition())
          .where('Audience', isEqualTo: 'Private')
          .snapshots();
    } else if (selectedOption == ProfileViewOption.collabs) {
      return FirebaseFirestore.instance
          .collection("reels")
          .where('collabreqacc', isEqualTo: true)
          .where("collabusername", isEqualTo: userdata['username'])
          .snapshots();
    }
    // Retrieve all posts (Public and Private)
    return FirebaseFirestore.instance
        .collection("Posts")
        .where('uid', isEqualTo: getCondition())
        .where('Audience', isEqualTo: 'Public')
        .where("Archive", isEqualTo: false)
        .snapshots();
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UpadtePassword(
                    email: userdata['email'],
                  )));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear shared preferences data
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen and remove previous screens from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
    _alertService.showToast(text: "logged out ", icon: Icons.check);
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 1),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

Widget _buildStatColumn(int num, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        num.toString(),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ),
    ],
  );
}
