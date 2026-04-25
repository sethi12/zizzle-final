import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_location_search/flutter_location_search.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zizzle/songs/Orginal_Audio.dart';
import 'package:zizzle/songs/SpotifyService.dart';
import 'package:zizzle/songs/spotifyapp.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Controllers/upload_video_controller.dart';
import '/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../utils/colors.dart';
import 'Collaborators_Screen.dart';

class AddReelDetails extends StatefulWidget {
  final File videofile;
  final String videopath;

  const AddReelDetails(
      {Key? key, required this.videofile, required this.videopath})
      : super(key: key);

  @override
  State<AddReelDetails> createState() => _AddReelDetailsState();
}

class _AddReelDetailsState extends State<AddReelDetails> {
  late VideoPlayerController _videoPlayerController;
  static String _locationText = '';
  bool _useCurrentLocation = false;
  final TextEditingController _captioncontroller = TextEditingController();
  String public = "Public";
  var collabuser = "";
  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());
  String _trackId = '';
  String _previewUrl = '';
  String _name = '';
  String _track = '';
  var username;
  String _orignalsongname = '';
  String _orinalsongurl = '';
  String _renamedAudio = '';
  int start = 0;
  int end = 0;
  final AudioPlayer _previewPlayer = AudioPlayer();
  void getusername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.videofile)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
        _videoPlayerController.setVolume(1);
        getusername();
      });

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.hasError) {
        print("Error: ${_videoPlayerController.value.errorDescription}");
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
    _previewPlayer.dispose();
    // SpotifyService().stopPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
        title: const Text(
          "New Reel",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              postreel();
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
              // Video Preview Card
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: VideoPlayer(_videoPlayerController),
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
                            print(collabuser);
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
                        _videoPlayerController.setVolume(0);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrginalAudio(
                              Audioname: "$username __OrignalAudio",
                              caller: "Reels",
                              videoDuration: _videoPlayerController
                                  .value.duration.inSeconds,
                            ),
                          ),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _orignalsongname =
                                result['songname']?.toString() ?? '';
                            _orinalsongurl = result['url']?.toString() ?? '';
                            start = result['start'] ?? 0;
                            end = result['end'] ?? 0;
                          });
                          playPreview(_orinalsongurl, start: start, end: end);
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
                              "Add Music",
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
              const SizedBox(height: 15),
              // Display song info
              if (_orignalsongname.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _orignalsongname,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
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
  //
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

  void postreel() async {
    stopPreview();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: ParticleBurstLoaderr());
      },
      barrierDismissible: false,
    );

    String res = await uploadVideoController.uploadvideo(
        _captioncontroller.text,
        public,
        _locationText,
        widget.videopath,
        collabuser,
        _name,
        _previewUrl,
        _track,
        _trackId,
        "$username __OrignalAudio",
        _orignalsongname,
        _orinalsongurl,
        start,
        end);
    stopPreview();
    Navigator.pop(context); // Close the progress indicator dialog

    if (res == "Success") {
      showSnackBar("Posted", context);
    }
  }

  @override
  void didUpdateWidget(covariant AddReelDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videopath != oldWidget.videopath) {
      _videoPlayerController = VideoPlayerController.file(widget.videofile)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController.play();
        });
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
