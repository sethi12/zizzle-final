import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '/Screens/add_reel_details.dart';
import '/Screens/edit_video_screen.dart';
import '/utils/colors.dart';

class AddReelScreen extends StatelessWidget {
  const AddReelScreen({super.key});

  Future<void> _pickVideo(ImageSource src, BuildContext context) async {
    final video = await ImagePicker().pickVideo(source: src);
    if (video != null) {
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddReelDetails(
            videofile: File(video.path),
            videopath: video.path,
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Create Reel",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient with subtle pattern or effect
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(101, 131, 237, 1.0),
                  Color.fromRGBO(10, 19, 41, 1.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Adding a subtle, animated background element could enhance the feel
          // For simplicity, we'll stick to a static design here.
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Hero Icon
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.videocam_outlined,
                        color: Colors.white.withOpacity(0.9),
                        size: 100,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Lights, Camera, Action!",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    "Share your story, one captivating video at a time.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),
                // Primary action button with a modern shimmer effect or glow
                _buildActionButton(
                  context: context,
                  label: "Upload from Gallery",
                  icon: Icons.photo_library_outlined,
                  onPressed: () => _pickVideo(ImageSource.gallery, context),
                  isPrimary: true,
                ),
                const SizedBox(height: 20),
                // Secondary action button with a subtle outline
                _buildActionButton(
                  context: context,
                  label: "Record a New Reel",
                  icon: Icons.videocam_outlined,
                  onPressed: () => _pickVideo(ImageSource.camera, context),
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: mobileBackgroundColor,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 10,
              ),
              icon: Icon(icon, color: mobileBackgroundColor),
              label: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: mobileBackgroundColor,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: Icon(icon),
              label: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
