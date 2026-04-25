import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '/model/reel.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  var audioUrl;

  // Future<File?> _compressVideo(String videoPath) async {
  //   final compressedVideo = await VideoCompress.compressVideo(
  //     videoPath,
  //     quality: VideoQuality.Res640x480Quality,
  //     deleteOrigin:
  //         false, // Set to true to delete the original video after compression
  //   );
  //   if (compressedVideo == null) {
  //     print("Video compression failed.");
  //     return null;
  //   }

  //   // Check the file extension and format to ensure compatibility
  //   if (!compressedVideo.file!.path.endsWith('.mp4')) {
  //     print("Warning: Compressed video is not in MP4 format.");
  //   }

  //   return compressedVideo.file;
  // }

  Future<String?> convertAspectRatioTo9by16(String inputPath) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/output_9_16.mp4';

    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      await outputFile.delete();
    }

    // FFmpeg filter:
    // - scale: scales to fit inside 1080x1920 while keeping aspect ratio
    // - pad: adds black bars to exactly fill 1080x1920 resolution
    //
    // This results in a video with 9:16 (0.5625) aspect ratio
    final ffmpegCommand =
        '-y -i "$inputPath" -vf "scale=w=iw*min(1080/iw\\,1920/ih):h=ih*min(1080/iw\\,1920/ih),pad=1080:1920:(1080-iw*min(1080/iw\\,1920/ih))/2:(1920-ih*min(1080/iw\\,1920/ih))/2" -preset ultrafast "$outputPath"';

    final session = await FFmpegKit.execute(ffmpegCommand);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("Aspect ratio corrected to 9:16 successfully.");
      return outputPath;
    } else {
      print("Aspect ratio conversion failed.");
      final logs = await session.getAllLogsAsString();
      print(logs);
      return null;
    }
  }

  Future<File?> _compressVideo(String videoPath) async {
    final convertedPath = await convertAspectRatioTo9by16(videoPath);
    if (convertedPath == null) {
      print("Aspect ratio conversion failed.");
      return null;
    }

    final compressedVideo = await VideoCompress.compressVideo(
      convertedPath,
      quality: VideoQuality.Res640x480Quality,
      deleteOrigin: false,
    );

    if (compressedVideo == null) {
      print("Video compression failed.");
      return null;
    }

    if (!compressedVideo.file!.path.endsWith('.mp4')) {
      print("Warning: Compressed video is not in MP4 format.");
    }

    return compressedVideo.file;
  }

  Future<String> _uploadVideoToStorage(
      String id, String videoPath, String Audioname) async {
    // File videoFile = File(videoPath);  // Create a File object from the video path
    // Reference ref = _storage.ref().child('reels').child(id);

    // UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
    File? videoFile = await _compressVideo(videoPath);
    if (videoFile == null) return "Error: Compression failed.";

    Reference ref = _storage.ref().child('reels').child(id);
    UploadTask uploadTask = ref.putFile(videoFile);
    TaskSnapshot snap = await uploadTask;

    // Enable resumable uploads
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  _getThumbnail(String videopath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videopath);
    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videopath) async {
    // File thumbnailFile = await _getThumbnail(videopath);
    Reference ref = _storage.ref().child('thumbnails').child(id);

    UploadTask uploadTask = ref.putFile(await _getThumbnail(videopath));
    TaskSnapshot snap = await uploadTask;

    // Enable resumable uploads
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _uploadCompressedVideo(String id, File videoFile) async {
    Reference ref = _storage.ref().child('reels').child(id);
    UploadTask uploadTask = ref.putFile(videoFile);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

//upload video
  Future<String> uploadvideo(
      String caption,
      String Audience,
      String Location,
      String videopath,
      String collabuser,
      String songname,
      String previewUrl,
      String track,
      String trackId,
      String videoAudioName,
      String orignalsongname,
      String orignalsongurl,
      int startduration,
      int endduration) async {
    String res = "Some Error Occurred";

    try {
      final prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');

      if (username != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(username).get();
        String reelid = Uuid().v1();

        File? videoFile = await _compressVideo(videopath);
        if (videoFile == null) return "Error: Compression failed.";

        String videourl = await _uploadCompressedVideo(reelid, videoFile);
        await processVideo(
            videoFile, videoAudioName); // ⬅️ Wait for audioUrl to be set

        String thumbnail = await _uploadImageToStorage(reelid, videopath);
        final userData = userDoc.data() as Map<String, dynamic>;

        bool Verified = false;
        if (userData.containsKey('Verified')) {
          Verified = userData['Verified'] == true;
        }

// Now you can use `verified` safely
        print("✅ Verified status of $username is: $Verified");

        if ((userDoc.data() as Map<String, dynamic>)['Monetization'] ==
            "Monitized") {
          Video video = Video(
              username: username,
              uid: (userDoc.data() as Map<String, dynamic>)['uid'],
              // Provide a default value or handle null accordingly
              id: reelid,
              likes: [],
              commentcount: 0,
              sharecount: 0,
              Audience: Audience,
              caption: caption,
              Location: Location,
              videourl: videourl,
              profilephoto:
                  (userDoc.data() as Map<String, dynamic>)['photourl'],
              thumbnail: thumbnail,
              views: 0,
              Paid: 'Not Paid',
              Monetized: 'Monitized',
              isGlobalOptionEnabled: false,
              collabreqacc: false,
              collabusername: collabuser,
              songname: songname,
              previewUrl: previewUrl,
              track: track,
              trackId: trackId,
              saved: [],
              Archive: false,
              orignalsongname: orignalsongname,
              orignalsongurl: orignalsongurl,
              videoAudioName: videoAudioName,
              videoAudiourl: audioUrl,
              startAudioDuration: startduration,
              endAudioDuration: endduration,
              Verified: Verified);
          if (collabuser != "") {
            await _firestore.collection("CollabRequests").doc(reelid).set({
              "reelid": reelid,
              "thumbnail": thumbnail,
              "profimage": (userDoc.data() as Map<String, dynamic>)['photourl'],
              "videourl": videourl,
              "videopath": videopath,
              "collabusername": collabuser,
              "username": username,
              "uid": (userDoc.data() as Map<String, dynamic>)['uid']
            });
          }
          await _firestore.collection('reels').doc(reelid).set(video.toJson());
          res = "Success";
        } else {
          Video video = Video(
              username: username,
              uid: (userDoc.data() as Map<String, dynamic>)['uid'],
              // Provide a default value or handle null accordingly
              id: reelid,
              likes: [],
              commentcount: 0,
              sharecount: 0,
              Audience: Audience,
              caption: caption,
              Location: Location,
              videourl: videourl,
              profilephoto:
                  (userDoc.data() as Map<String, dynamic>)['photourl'],
              thumbnail: thumbnail,
              views: 0,
              Paid: 'Paid',
              Monetized: 'Not Monitized',
              isGlobalOptionEnabled: false,
              collabusername: collabuser,
              collabreqacc: false,
              songname: songname,
              previewUrl: previewUrl,
              track: track,
              trackId: trackId,
              saved: [],
              Archive: false,
              orignalsongname: orignalsongname,
              orignalsongurl: orignalsongurl,
              videoAudioName: videoAudioName,
              videoAudiourl: audioUrl,
              startAudioDuration: startduration,
              endAudioDuration: endduration,
              Verified: Verified);
          if (collabuser != "") {
            await _firestore.collection("CollabRequests").doc(reelid).set({
              "reelid": reelid,
              "thumbnail": thumbnail,
              "profimage": (userDoc.data() as Map<String, dynamic>)['photourl'],
              "videourl": videourl,
              "videopath": videopath,
              "collabusername": collabuser,
              "username": username,
              "uid": (userDoc.data() as Map<String, dynamic>)['uid']
            });
          }
          await _firestore.collection('reels').doc(reelid).set(video.toJson());

          res = "Success";
        }
      } else {
        // Handle the case when username is null
        res = "Error: Username is null";
      }
    } catch (err) {
      print("Error uploading video: $err");
      // Handle errors accordingly
      res = "Error: $err";
    }

    return res;
  }

  Future<File?> extractAudioFromVideo(File videoFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = p.join(tempDir.path,
          'extracted_${DateTime.now().millisecondsSinceEpoch}.mp3');

      final command =
          '-i "${videoFile.path}" -vn -acodec libmp3lame -y "$outputPath"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (returnCode?.isValueSuccess() ?? false) {
        print("✅ Audio extraction successful");
        return File(outputPath);
      } else {
        print("❌ Audio extraction failed with code: $returnCode");
        return null;
      }
    } catch (e) {
      print("❌ Error extracting audio: $e");
      return null;
    }
  }

  /// Upload audio file to Firebase Storage and return download URL
  Future<String?> uploadAudioToStorage(File audioFile) async {
    try {
      String songId = const Uuid().v4();
      final ref = _storage.ref().child('songs').child('$songId.mp3');
      final uploadTask = await ref.putFile(audioFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print("✅ Uploaded audio URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading audio: $e");
      return null;
    }
  }

  /// Save song metadata to Firestore
  Future<void> saveSongToFirestore({
    required String url,
    required String name,
  }) async {
    try {
      String id = const Uuid().v4();
      await _firestore.collection('songs').doc(id).set({
        'id': id,
        'name': name,
        'url': url,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ Song details saved to Firestore");
    } catch (e) {
      print("❌ Error saving song details: $e");
    }
  }

  Future<void> processVideo(File videoFile, String songName) async {
    final extractedAudio = await extractAudioFromVideo(videoFile);
    if (extractedAudio == null) {
      print("❌ Could not extract audio from video.");
      return;
    }

    audioUrl = (await uploadAudioToStorage(extractedAudio));

    if (audioUrl == null) {
      print("❌ Could not upload audio to Firebase Storage.");
      return;
    }

    await saveSongToFirestore(url: audioUrl, name: songName);
  }
}
