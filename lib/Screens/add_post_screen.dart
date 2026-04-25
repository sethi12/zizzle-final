import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart'; // No longer needed for cropping logic

import '/Screens/Add_post_screen_details.dart';
import '/utils/colors.dart';
import '/utils/utils.dart'; // Assuming PickImage and colors are defined here

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _selectedImage;

  Future<void> _pickImage() async {
    // 1. Pick the image data (Uint8List)
    Uint8List? file = await PickImage(ImageSource.gallery);
    if (file != null) {
      // 2. Set the state with the picked image immediately
      setState(() {
        _selectedImage = file;
      });
      // The _cropImage function call is removed
    }
  }

  // 🗑️ The entire _cropImage function is removed from here.

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
          "Create Post",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _selectedImage != null
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddpostScreenDetails(
                          selectedimage: _selectedImage!,
                        ),
                      ),
                    );
                  }
                : null,
            child: Text(
              "Next",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedImage != null ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Image Preview Section
                  AspectRatio(
                    aspectRatio: 1, // A square ratio for a modern look
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _selectedImage != null
                              ? Image.memory(
                                  _selectedImage!,
                                  key: ValueKey(_selectedImage),
                                  fit: BoxFit.cover,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined,
                                        size: 80, color: Colors.grey[600]),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Select an image to start posting",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons for selecting image source
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSourceButton(
                        context: context,
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: () => _pickImage(),
                      ),
                      _buildSourceButton(
                        context: context,
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: () async {
                          final pickedFile = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          if (pickedFile != null) {
                            setState(() {
                              // Read bytes and update state directly
                              _selectedImage =
                                  pickedFile.readAsBytes() as Uint8List;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
