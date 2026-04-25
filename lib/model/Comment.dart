import 'package:cloud_firestore/cloud_firestore.dart';

class Comments {
  String username;
  String comment;
  final datepublished;
  List likes;
  String uid;
  String id;
  String profilephoto;
  Comments(
      {required this.username,
      required this.comment,
      required this.datepublished,
      required this.likes,
      required this.id,
      required this.uid,
      required this.profilephoto});

  Map<String, dynamic> toJson() => {
        "username": username,
        "comment": comment,
        "datepublished": datepublished,
        "likes": likes,
        "id": id,
        "uid": uid,
        "profilephoto": profilephoto
      };
  static Comments fromsnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return Comments(
        username: snap["username"],
        comment: snap["comment"],
        datepublished: snap["datepublished"],
        likes: snap["likes"],
        id: snap["id"],
        uid: snap["uid"],
        profilephoto: snap["profilephoto"]);
  }
}
