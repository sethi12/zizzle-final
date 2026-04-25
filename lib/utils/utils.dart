import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import '/services/alert_service.dart';
import '/services/auth_message_service.dart';
import '/services/database_service.dart';
import '/services/media_service.dart';
import '/services/storage_service.dart';

import '../services/navigation_service.dart';

PickImage(ImageSource source) async {
  final ImagePicker _imagepicker = ImagePicker();

  XFile? _file = await _imagepicker.pickImage(source: source);
  if (_file != null) {
    return _file.readAsBytes();
  }
  print("no image Selected");
}

void showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor:
          Colors.black.withOpacity(0.8), // A semi-transparent dark background
      behavior: SnackBarBehavior
          .floating, // Makes the SnackBar float above the bottom edge
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10), // Rounded corners for a modern look
      ),
      margin: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 15), // Adds margin for a floating effect
      elevation: 6, // Adds a subtle shadow for depth
      duration: const Duration(milliseconds: 2500), // Adjust duration as needed
    ),
  );
}

Future<void> registerservices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<Navigationservice>(Navigationservice());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
}

String generatechatid({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatid = uids.fold("", (id, uid) => "$id$uid");
  return chatid;
}
