import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';
import 'package:zizzle/songs/Orginal_Audio.dart';
// import 'package:flutter_location_search/flutter_location_search.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:zizzle/songs/SpotifyService.dart';
import 'package:zizzle/songs/spotifyapp.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Screens/Collaborators_Screen.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/add_post_screen.dart';
import '/Screens/feed_screen.dart';
import '/responsive/mobile_screen_layout.dart';
import '/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../resources/firestoremethods.dart';
import '../utils/colors.dart';

class AddpostScreenDetails extends StatefulWidget {
  String? collabuser;
  String? trackid;
  String? previewUrl;
  String? songname;
  Uint8List? selectedimage;
  AddpostScreenDetails(
      {super.key,
      this.collabuser,
      this.previewUrl,
      this.trackid,
      this.songname,
      this.selectedimage});

  @override
  State<AddpostScreenDetails> createState() => _AddpostScreenDetailsState();
  static String location = _AddpostScreenDetailsState._locationText;
  static var uid = _AddpostScreenDetailsState.uid;
}

class _AddpostScreenDetailsState extends State<AddpostScreenDetails> {
  static String _locationText = '';
  bool _useCurrentLocation = false;
  final TextEditingController _captioncontroller = TextEditingController();
  String public = "Public";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Uint8List? selectedimage = AddpostScreen.selectedimage;
  static var uid;
  var photourl;
  var Verified;
  var Monetized;
  var collabuser = "";
  Uint8List? _currentImage;
  String _orignalsongname = '';
  String _orignalsongurl = '';
  String _renamedAudio = '';
  int start = 0;
  int end = 0;
  final AudioPlayer _previewPlayer = AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    _currentImage = widget.selectedimage;
    super.initState();
    if (_orignalsongurl != null) {
      // SpotifyService().playPreview(_orignalsongurl);
    }
  }

  Future<void> _editimage() async {
    Uint8List? initialImage = _currentImage;

    if (initialImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.memory(
          initialImage,
          callbacks: ProImageEditorCallbacks(
              // The 'bytes' parameter here IS the edited image data.
              onImageEditingComplete: (Uint8List editedBytes) async {
            // 1. Update the state with the EDITED bytes.
            setState(() {
              _currentImage = editedBytes;
            });

            // 2. Pop the editor screen off the stack.
            // This pop returns nothing, but the image is already updated via setState.
            Navigator.pop(context);
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
        title: const Text(
          "New Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              getdata();
              SpotifyService().stopPreview();
            },
            child: const Text(
              "Post",
              style: TextStyle(
                fontSize: 17,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Card
              Container(
                height: 350,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _currentImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _currentImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Text(
                          "No Image Selected",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 15,
                right: 15,
                child: InkWell(
                  onTap: () {
                    _editimage();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Caption and Options Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Caption Text Field
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: secondaryColor.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _captioncontroller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Write a caption...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Collaborator Row
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollabScreen(),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            collabuser = result;
                          });
                        } else {
                          setState(() {
                            collabuser = "";
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: secondaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: secondaryColor),
                            const SizedBox(width: 15),
                            const Text(
                              "Invite Collaborators",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            const Spacer(),
                            Text(
                              collabuser,
                              style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Audience Row
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Container(
                              height: 250,
                              decoration: const BoxDecoration(
                                color: mobileBackgroundColor,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      "Select your Audience",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Divider(
                                      color: secondaryColor, height: 1),
                                  ListTile(
                                    leading: const Icon(Icons.people,
                                        color: Colors.white),
                                    title: const Text("Public",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                    onTap: () {
                                      setState(() {
                                        public = "Public";
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.person_rounded,
                                        color: Colors.white),
                                    title: const Text("Private",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                    onTap: () {
                                      setState(() {
                                        public = "Private";
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: secondaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, color: secondaryColor),
                            const SizedBox(width: 15),
                            const Text(
                              "Audience",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            const Spacer(),
                            Text(
                              public,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Location Row
                    GestureDetector(
                      onTap: () {
                        // location(); // Your original location function call
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: secondaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: secondaryColor),
                            const SizedBox(width: 15),
                            const Text(
                              "Add Location",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            if (_locationText.isNotEmpty) ...[
                              const Spacer(),
                              Text(
                                _locationText,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Music Row
                    GestureDetector(
                      onTap: () async {
                        final result =
                            await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OrginalAudio(caller: "Post"),
                        ));
                        stopPreview();
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _orignalsongname =
                                result['songname']?.toString() ?? '';
                            _orignalsongurl = result['url']?.toString() ?? '';
                            start = result['start'] ?? 0;
                            end = result['end'] ?? 0;
                          });
                          playPreview(_orignalsongurl, start: start, end: end);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: secondaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.music_note_sharp,
                                color: secondaryColor),
                            const SizedBox(width: 15),
                            const Text(
                              "Import Music",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            const Spacer(),
                            if (_orignalsongname.isNotEmpty)
                              Flexible(
                                child: Text(
                                  _orignalsongname,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> location() async {
  //   LocationData? locationData = await LocationSearch.show(
  //       context: context,
  //       mode: Mode.overlay,
  //       searchBarHintColor: Colors.white,
  //       searchBarTextColor: Colors.white);
  //
  //   if (locationData != null) {
  //     setState(() {
  //       _useCurrentLocation = locationData.address == null;
  //       _locationText = _useCurrentLocation
  //           ? 'Current Location: ${locationData.latitude}, ${locationData.longitude}'
  //           : locationData.address!;
  //     });
  //
  //     if (_useCurrentLocation) {
  //       await getCurrentLocation();
  //     }
  //   }
  // }

  // Future<void> getCurrentLocation() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     setState(() {
  //       _locationText =
  //           'Current Location: ${position.latitude}, ${position.longitude}';
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
  //
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _captioncontroller.dispose();
    stopPreview();
  }

  void getdata() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: ParticleBurstLoaderr());
      },
      barrierDismissible: false,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      String? usernamee = prefs.getString('username');
      var existingUser =
          await _firestore.collection("users").doc(usernamee).get();
      print(existingUser);

      if (existingUser.exists) {
        uid = existingUser.data()?['uid'];
        photourl = existingUser.data()?['photourl'];

        // ✅ Safely check Verified field
        bool verifiedValue = false;
        if (existingUser.data()!.containsKey('Verified')) {
          verifiedValue = existingUser.data()?['Verified'] == true;
        }

        // ✅ Safely check Monetized field
        String monetizedValue = 'Not Monitized';

        final data = existingUser.data();
        if (data != null && data.containsKey('Monetization')) {
          final value = data['Monetization'];
          if (value is String && value.trim() == 'Monitized') {
            monetizedValue = 'Monitized';
          }
        }

        print("🪙 Monetized value for $usernamee is: $monetizedValue");

        if (usernamee != null) {
          stopPreview();
          String res = await Firestoremethods().uploadPost(
            _captioncontroller.text!,
            _currentImage!,
            uid!,
            _locationText!,
            public!,
            usernamee!,
            photourl!,
            collabuser,
            widget.trackid,
            widget.previewUrl,
            widget.songname,
            _orignalsongname,
            _orignalsongurl,
            start,
            end,
            verifiedValue,
            monetizedValue,
          );
          Navigator.pop(context);
          if (res == "Success") {
            showSnackBar("posted", context);

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => FeedScreen()));
          } else {
            showSnackBar("error: $res", context);
          }
        } else {
          showSnackBar("Username is null", context);
        }
      } else {
        showSnackBar("User data not found", context);
      }
    } catch (err) {
      print(err.toString());
    }
  }

  void _startSegmentLooping({required int start, required int end}) {
    _previewPlayer.positionStream.listen((position) {
      if (position.inSeconds >= end) {
        _previewPlayer.seek(Duration(seconds: start));
      }
    });
  }

  Future<void> playPreview(String url, {int start = 0, int? end}) async {
    try {
      await _previewPlayer.setUrl(url);
      await _previewPlayer.seek(Duration(seconds: start));
      await _previewPlayer.play();

      if (end != null && end > start) {
        // Start listening for position to loop between start and end
        _startSegmentLooping(start: start, end: end);
      } else {
        // If no end provided, play normally with LoopMode.one
        await _previewPlayer.setLoopMode(LoopMode.one);
      }
    } catch (e) {
      print("Error playing preview: $e");
    }
  }

  void stopPreview() {
    _previewPlayer.stop();
  }
}
