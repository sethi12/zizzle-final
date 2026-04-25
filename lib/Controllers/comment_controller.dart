import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/model/Comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentController extends GetxController {
  final Rx<List<Comments>> _comments = Rx<List<Comments>>([]);
  List<Comments> get comments => _comments.value;
  final _firestore = FirebaseFirestore.instance;
  String _postid = "";
  updatepostid(String id) {
    _postid = id;
    getcomments();
  }

  getcomments() async {
    _comments.bindStream(
      _firestore
          .collection('reels')
          .doc(_postid)
          .collection('Comments')
          .snapshots()
          .map(
        (QuerySnapshot querry) {
          List<Comments> retval = [];
          for (var element in querry.docs) {
            retval.add(Comments.fromsnap(element));
          }
          return retval;
        },
      ),
    );
  }

  postcomment(String commenttext) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    try {
      print(commenttext);
      print(username);
      if (commenttext.isNotEmpty && username != null) {
        DocumentSnapshot userdoc =
            await _firestore.collection("users").doc(username).get();
        var alldocs = await _firestore
            .collection("reels")
            .doc(_postid)
            .collection('Comments')
            .get();
        int len = alldocs.docs.length;
        Comments comment = Comments(
            username: (userdoc.data()! as dynamic)['username'],
            comment: commenttext.trim(),
            datepublished: DateTime.now(),
            likes: [],
            id: 'Comment$len',
            uid: (userdoc.data()! as dynamic)['uid'],
            profilephoto: (userdoc.data()! as dynamic)['photourl']);
        await _firestore
            .collection("reels")
            .doc(_postid)
            .collection('Comments')
            .doc('Comment$len')
            .set(comment.toJson());
        DocumentSnapshot snapshot =
            await _firestore.collection("reels").doc(_postid).get();
        await _firestore.collection('reels').doc(_postid).update({
          'commentcount': (snapshot.data() as dynamic)['commentcount'] + 1,
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  likecomment(String id, String username) async {
    DocumentSnapshot focs = await _firestore
        .collection('reels')
        .doc(_postid)
        .collection('Comments')
        .doc(id)
        .get();
    if ((focs.data()! as dynamic)['likes'].contains(username)) {
      await _firestore
          .collection('reels')
          .doc(_postid)
          .collection('Comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayRemove([username]),
      });
    } else {
      await _firestore
          .collection('reels')
          .doc(_postid)
          .collection('Comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayUnion([username]),
      });
    }
  }
}
