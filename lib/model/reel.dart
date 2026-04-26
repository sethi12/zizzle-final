// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:video_player/video_player.dart';

// class Video {
//   String username;
//   String uid;
//   String id;
//   List likes;
//   int commentcount;
//   int sharecount;
//   String Audience;
//   String caption;
//   String Location;
//   String videourl;
//   String profilephoto;
//   String thumbnail;
//   int views;
//   String Paid;
//   String Monetized;
//   bool isGlobalOptionEnabled;
//   bool collabreqacc;
//   String collabusername;
//   String? trackId;
//   String? previewUrl;
//   String? songname;
//   String? track;
//   final bool Archive;
//   final saved;
//   String? videoAudioName;
//   String? videoAudiourl;
//   String? orignalsongname;
//   String? orignalsongurl;
//   final int? startAudioDuration;
//   final int? endAudioDuration;

//   // ✅ NEW optional fields
//   final bool? GlobalPaymentActivation;
//   final DateTime? GlobalPlanactivatedAt;
//   final DateTime? GlobalPlanexpiresAt;
//   final bool? Verified;
//   Video(
//       {required this.username,
//       required this.uid,
//       required this.id,
//       required this.likes,
//       required this.commentcount,
//       required this.sharecount,
//       required this.Audience,
//       required this.caption,
//       required this.Location,
//       required this.videourl,
//       required this.profilephoto,
//       required this.thumbnail,
//       required this.views,
//       required this.Paid,
//       required this.Monetized,
//       required this.isGlobalOptionEnabled,
//       required this.collabreqacc,
//       required this.collabusername,
//       this.previewUrl,
//       this.songname,
//       this.trackId,
//       this.track,
//       required this.saved,
//       required this.Archive,
//       required this.orignalsongname,
//       required this.orignalsongurl,
//       required this.videoAudioName,
//       required this.videoAudiourl,
//       this.startAudioDuration,
//       this.endAudioDuration,
//       // ✅ include in constructor
//       this.GlobalPaymentActivation,
//       this.GlobalPlanactivatedAt,
//       this.GlobalPlanexpiresAt,
//       this.Verified});

//   Map<String, dynamic> toJson() => {
//         "username": username,
//         "uid": uid,
//         "id": id,
//         "likes": likes,
//         "commentcount": commentcount,
//         "sharecount": sharecount,
//         "Audience": Audience,
//         "caption": caption,
//         "Location": Location,
//         "videourl": videourl,
//         "profilephoto": profilephoto,
//         "thumbnail": thumbnail,
//         "views": views,
//         "Paid": Paid,
//         "Monetized": Monetized,
//         "isGlobalOptionEnabled": isGlobalOptionEnabled,
//         "collabreqacc": collabreqacc,
//         "collabusername": collabusername,
//         "previewUrl": previewUrl,
//         "songname": songname,
//         "trackId": trackId,
//         "track": track,
//         "saved": saved,
//         "Archive": Archive,
//         "orignalsongname": orignalsongname,
//         "orignalsongurl": orignalsongurl,
//         "videoAudioName": videoAudioName,
//         "videoAudiourl": videoAudiourl,
//         "startAudioDuration": startAudioDuration,
//         "endAudioDuration": endAudioDuration,
//         // ✅ include in toJson
//         "GlobalPaymentActivation": GlobalPaymentActivation,
//         "GlobalPlanactivatedAt": GlobalPlanactivatedAt,
//         "GlobalPlanexpiresAt": GlobalPlanexpiresAt,
//         "Verified": Verified,
//       };

//   static Video fromSnap(DocumentSnapshot snap) {
//     var snapshot = snap.data() as Map<String, dynamic>;
//     return Video(
//       username: snapshot['username'],
//       uid: snapshot['uid'],
//       id: snapshot['id'],
//       likes: snapshot['likes'],
//       commentcount: snapshot['commentcount'],
//       sharecount: snapshot['sharecount'],
//       Audience: snapshot['Audience'],
//       caption: snapshot['caption'],
//       Location: snapshot['Location'],
//       videourl: snapshot['videourl'],
//       profilephoto: snapshot['profilephoto'],
//       thumbnail: snapshot['thumbnail'],
//       views: snapshot['views'],
//       Paid: snapshot['Paid'],
//       Monetized: snapshot['Monetized'],
//       isGlobalOptionEnabled: snapshot['isGlobalOptionEnabled'],
//       collabreqacc: snapshot['collabreqacc'],
//       collabusername: snapshot['collabusername'],
//       previewUrl: snapshot['previewUrl'],
//       songname: snapshot['songname'],
//       track: snapshot['track'],
//       trackId: snapshot['trackId'],
//       saved: snapshot['saved'],
//       Archive: snapshot['Archive'],
//       orignalsongname: snapshot['orignalsongname'],
//       orignalsongurl: snapshot['orignalsongurl'],
//       videoAudioName: snapshot['videoAudioName'],
//       videoAudiourl: snapshot['videoAudiourl'],
//       startAudioDuration: snapshot['startAudioDuration'],
//       endAudioDuration: snapshot['endAudioDuration'],
//       // ✅ Safe fallback for missing fields
//       GlobalPaymentActivation: snapshot['GlobalPaymentActivation'] ?? false,
//       GlobalPlanactivatedAt: snapshot['GlobalPlanactivatedAt'] != null
//           ? (snapshot['GlobalPlanactivatedAt'] as Timestamp).toDate()
//           : null,
//       GlobalPlanexpiresAt: snapshot['GlobalPlanexpiresAt'] != null
//           ? (snapshot['GlobalPlanexpiresAt'] as Timestamp).toDate()
//           : null,
//       Verified: snapshot['Verified'],
//     );
//   }

//   late VideoPlayerController _controller;

//   Future<void> initializeController() async {
//     _controller = VideoPlayerController.network(videourl);
//     await _controller.initialize();
//   }

//   VideoPlayerController get controller => _controller;
// }





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class Video {
  // ── Original fields (unchanged) ──────────────────────────────────
  String username;
  String uid;
  String id;
  List likes;
  int commentcount;
  int sharecount;
  String Audience;
  String caption;
  String Location;
  String videourl;
  String profilephoto;
  String thumbnail;
  int views;
  String Paid;
  String Monetized;
  bool isGlobalOptionEnabled;
  bool collabreqacc;
  String collabusername;
  String? trackId;
  String? previewUrl;
  String? songname;
  String? track;
  final bool Archive;
  final dynamic saved;
  String? videoAudioName;
  String? videoAudiourl;
  String? orignalsongname;
  String? orignalsongurl;
  final int? startAudioDuration;
  final int? endAudioDuration;
  final bool? GlobalPaymentActivation;
  final DateTime? GlobalPlanactivatedAt;
  final DateTime? GlobalPlanexpiresAt;
  final bool? Verified;

  // ── NEW fields — written by Cloud Run after transcoding ──────────
  // All nullable — old reels don't have them and app falls back safely
  final String? hlsUrl;
  final String? videoUrl_720p;
  final String? thumbnailUrl;
  final String? transcodingStatus;

  Video({
    required this.username,
    required this.uid,
    required this.id,
    required this.likes,
    required this.commentcount,
    required this.sharecount,
    required this.Audience,
    required this.caption,
    required this.Location,
    required this.videourl,
    required this.profilephoto,
    required this.thumbnail,
    required this.views,
    required this.Paid,
    required this.Monetized,
    required this.isGlobalOptionEnabled,
    required this.collabreqacc,
    required this.collabusername,
    required this.saved,
    required this.Archive,
    required this.orignalsongname,
    required this.orignalsongurl,
    required this.videoAudioName,
    required this.videoAudiourl,
    this.previewUrl,
    this.songname,
    this.trackId,
    this.track,
    this.startAudioDuration,
    this.endAudioDuration,
    this.GlobalPaymentActivation,
    this.GlobalPlanactivatedAt,
    this.GlobalPlanexpiresAt,
    this.Verified,
    this.hlsUrl,
    this.videoUrl_720p,
    this.thumbnailUrl,
    this.transcodingStatus,
  });

  // ── Smart URL getters ─────────────────────────────────────────────

  /// Feed playback priority: hlsUrl → videoUrl_720p → original videourl
  /// Old reels without hlsUrl automatically fall back to videourl — no crash
  String get feedPlaybackUrl {
    if (hlsUrl != null && hlsUrl!.isNotEmpty) return hlsUrl!;
    if (videoUrl_720p != null && videoUrl_720p!.isNotEmpty) {
      return videoUrl_720p!;
    }
    return videourl;
  }

  /// Best thumbnail: Cloud Run generated one → original thumbnail field
  String get bestThumbnail {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) return thumbnailUrl!;
    return thumbnail;
  }

  /// True only when Cloud Run finished transcoding successfully
  bool get isTranscoded =>
      transcodingStatus == 'done' && (hlsUrl?.isNotEmpty ?? false);

  // ── fromSnap — used when reading a single DocumentSnapshot ───────
  static Video fromSnap(DocumentSnapshot snap) {
    final s = snap.data() as Map<String, dynamic>;
    return Video(
      username: s['username'] ?? '',
      uid: s['uid'] ?? '',
      id: s['id'] ?? snap.id,
      likes: s['likes'] ?? [],
      commentcount: s['commentcount'] ?? 0,
      sharecount: s['sharecount'] ?? 0,
      Audience: s['Audience'] ?? 'Public',
      caption: s['caption'] ?? '',
      Location: s['Location'] ?? '',
      videourl: s['videourl'] ?? '',
      profilephoto: s['profilephoto'] ?? '',
      thumbnail: s['thumbnail'] ?? '',
      views: s['views'] ?? 0,
      Paid: s['Paid'] ?? '',
      Monetized: s['Monetized'] ?? '',
      isGlobalOptionEnabled: s['isGlobalOptionEnabled'] ?? false,
      collabreqacc: s['collabreqacc'] ?? false,
      collabusername: s['collabusername'] ?? '',
      previewUrl: s['previewUrl'],
      songname: s['songname'],
      track: s['track'],
      trackId: s['trackId'],
      saved: s['saved'],
      Archive: s['Archive'] ?? false,
      orignalsongname: s['orignalsongname'],
      orignalsongurl: s['orignalsongurl'],
      videoAudioName: s['videoAudioName'],
      videoAudiourl: s['videoAudiourl'],
      startAudioDuration: s['startAudioDuration'],
      endAudioDuration: s['endAudioDuration'],
      GlobalPaymentActivation: s['GlobalPaymentActivation'] ?? false,
      GlobalPlanactivatedAt: s['GlobalPlanactivatedAt'] != null
          ? (s['GlobalPlanactivatedAt'] as Timestamp).toDate()
          : null,
      GlobalPlanexpiresAt: s['GlobalPlanexpiresAt'] != null
          ? (s['GlobalPlanexpiresAt'] as Timestamp).toDate()
          : null,
      Verified: s['Verified'],
      hlsUrl: s['hlsUrl'],
      videoUrl_720p: s['videoUrl_720p'],
      thumbnailUrl: s['thumbnailUrl'],
      transcodingStatus: s['transcodingStatus'],
    );
  }

  // ── fromMap — used by ReelsController when building from raw map ──
  static Video fromMap(Map<String, dynamic> s) {
    return Video(
      username: s['username'] ?? '',
      uid: s['uid'] ?? '',
      id: s['id'] ?? '',
      likes: s['likes'] ?? [],
      commentcount: s['commentcount'] ?? 0,
      sharecount: s['sharecount'] ?? 0,
      Audience: s['Audience'] ?? 'Public',
      caption: s['caption'] ?? '',
      Location: s['Location'] ?? '',
      videourl: s['videourl'] ?? '',
      profilephoto: s['profilephoto'] ?? '',
      thumbnail: s['thumbnail'] ?? '',
      views: s['views'] ?? 0,
      Paid: s['Paid'] ?? '',
      Monetized: s['Monetized'] ?? '',
      isGlobalOptionEnabled: s['isGlobalOptionEnabled'] ?? false,
      collabreqacc: s['collabreqacc'] ?? false,
      collabusername: s['collabusername'] ?? '',
      previewUrl: s['previewUrl'],
      songname: s['songname'],
      track: s['track'],
      trackId: s['trackId'],
      saved: s['saved'],
      Archive: s['Archive'] ?? false,
      orignalsongname: s['orignalsongname'],
      orignalsongurl: s['orignalsongurl'],
      videoAudioName: s['videoAudioName'],
      videoAudiourl: s['videoAudiourl'],
      startAudioDuration: s['startAudioDuration'],
      endAudioDuration: s['endAudioDuration'],
      GlobalPaymentActivation: s['GlobalPaymentActivation'] ?? false,
      GlobalPlanactivatedAt: _toDateTime(s['GlobalPlanactivatedAt']),
      GlobalPlanexpiresAt: _toDateTime(s['GlobalPlanexpiresAt']),
      Verified: s['Verified'],
      hlsUrl: s['hlsUrl'],
      videoUrl_720p: s['videoUrl_720p'],
      thumbnailUrl: s['thumbnailUrl'],
      transcodingStatus: s['transcodingStatus'],
    );
  }

  // Safe Timestamp → DateTime conversion for both fromSnap and fromMap
  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  // ── toJson ────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'id': id,
        'likes': likes,
        'commentcount': commentcount,
        'sharecount': sharecount,
        'Audience': Audience,
        'caption': caption,
        'Location': Location,
        'videourl': videourl,
        'profilephoto': profilephoto,
        'thumbnail': thumbnail,
        'views': views,
        'Paid': Paid,
        'Monetized': Monetized,
        'isGlobalOptionEnabled': isGlobalOptionEnabled,
        'collabreqacc': collabreqacc,
        'collabusername': collabusername,
        'previewUrl': previewUrl,
        'songname': songname,
        'trackId': trackId,
        'track': track,
        'saved': saved,
        'Archive': Archive,
        'orignalsongname': orignalsongname,
        'orignalsongurl': orignalsongurl,
        'videoAudioName': videoAudioName,
        'videoAudiourl': videoAudiourl,
        'startAudioDuration': startAudioDuration,
        'endAudioDuration': endAudioDuration,
        'GlobalPaymentActivation': GlobalPaymentActivation,
        'GlobalPlanactivatedAt': GlobalPlanactivatedAt,
        'GlobalPlanexpiresAt': GlobalPlanexpiresAt,
        'Verified': Verified,
        if (hlsUrl != null) 'hlsUrl': hlsUrl,
        if (videoUrl_720p != null) 'videoUrl_720p': videoUrl_720p,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (transcodingStatus != null) 'transcodingStatus': transcodingStatus,
      };

  // ── VideoPlayerController (original preserved, now uses feedPlaybackUrl)
  late VideoPlayerController _controller;

  Future<void> initializeController() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(feedPlaybackUrl),
    );
    await _controller.initialize();
  }

  VideoPlayerController get controller => _controller;
}