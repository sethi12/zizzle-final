import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  StorageService() {}
  // Future<String?> uploaduserpfp({
  //   required File file,
  //   required String uid,
  // }) async {
  //   Reference fileref =
  //       _storage.ref('users/pfps').child('$uid${p.extension(file.path)}');
  //   UploadTask task = fileref.putFile(file);
  //   return task.then((m) {
  //     if (m.state == TaskState.success) {
  //       return fileref.getDownloadURL();
  //     }
  //   });
  // }

  Future<String?> uploadimagetochat(
      {required File file, required String chatid}) async {
    Reference fileref =_storage.ref('chats/$chatid').child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task  = fileref .putFile(file);
    return task.then((m){
      if (m.state == TaskState.success) {
        return fileref.getDownloadURL();
      }
    });
  }
}
