import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import '/Screens/add_reel_details.dart';
import 'package:video_player/video_player.dart';

class EditVideoScreen extends StatefulWidget {
  final File videofile;
  final String videopath;

  const EditVideoScreen(
      {Key? key, required this.videofile, required this.videopath})
      : super(key: key);

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.videofile)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
        _videoPlayerController.setVolume(1);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : ParticleBurstLoaderr(),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            bottom: 40,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddReelDetails(
                          videofile: File(widget
                              .videofile.path), // Use widget.videofile.path
                          videopath: widget.videopath,
                        )));
              },
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant EditVideoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videopath != oldWidget.videopath) {
      _videoPlayerController = VideoPlayerController.file(widget.videofile)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController.play();
        });
    }
  }
}
