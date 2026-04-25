import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String? username;
  final String Audience;
  final String Location;
  final String caption;
  final String postid;
  final datepublished;
  final String posturl;
  final String profimage;
  final likes;
  final bool isGlobalOptionEnabled;
  final String collabusername;
  final bool collabreqacc;
  final String? preivewUrl;
  final String? trackid;
  final String? songname;
  final saved;
  final bool Archive;
  final String? orignalsongname;
  final String? orignalsongurl;
  final int? startduration;
  final int? endduration;
  final bool Verified;
  final String Monetized;

  const Post({
    required this.Audience,
    required this.uid,
    required this.username,
    required this.caption,
    required this.Location,
    required this.datepublished,
    required this.likes,
    required this.postid,
    required this.posturl,
    required this.profimage,
    required this.isGlobalOptionEnabled,
    required this.collabusername,
    required this.collabreqacc,
    this.preivewUrl,
    this.trackid,
    required this.songname,
    required this.saved,
    required this.Archive,
    this.orignalsongname,
    this.orignalsongurl,
    required this.startduration,
    required this.endduration,
    required this.Verified,
    required this.Monetized,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'Audience': Audience,
        'caption': caption,
        'Location': Location,
        'datepublished': datepublished,
        'likes': likes,
        'postid': postid,
        'posturl': posturl,
        'profimage': profimage,
        'isGlobalOptionEnabled': isGlobalOptionEnabled,
        "collabusername": collabusername,
        "collabreqacc": collabreqacc,
        "trackid": trackid,
        "previewUrl": preivewUrl,
        "songname": songname,
        "saved": saved,
        "Archive": Archive,
        "orignalsongname": orignalsongname,
        "orignalsongurl": orignalsongurl,
        "startduration": startduration,
        "endduration": endduration,
        "Verified": Verified,
        "Monetized": Monetized
      };

  static Post fromsnap(DocumentSnapshot snapshot) {
    var snaoshot = snapshot.data() as Map<String, dynamic>;
    return Post(
        Audience: snaoshot['Audience'],
        uid: snaoshot['uid'],
        username: snaoshot['username'],
        caption: snaoshot['caption'],
        Location: snaoshot['Location'],
        datepublished: snaoshot['datepublished'],
        likes: snaoshot['likes'],
        postid: snaoshot['postid'],
        posturl: snaoshot['posturl'],
        profimage: snaoshot['profimage'],
        isGlobalOptionEnabled: snaoshot['isGlobalOptionEnabled'],
        collabusername: snaoshot["collabusername"],
        collabreqacc: snaoshot["collabreqacc"],
        trackid: snaoshot['trackid'],
        preivewUrl: snaoshot['previewUrl'],
        songname: snaoshot['songname'],
        Archive: snaoshot["Archive"],
        saved: snaoshot['saved'],
        orignalsongname: snaoshot['orignalsongname'],
        orignalsongurl: snaoshot['orignalsongurl'],
        startduration: snaoshot['startduration'],
        endduration: snaoshot['endduration'],
        Verified: snaoshot['Verified'],
        Monetized: snapshot['Monetized']);
  }
}
