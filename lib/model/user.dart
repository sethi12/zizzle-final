import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photourl;
  final String username;
  final List followers;
  final List following;
  final String password;
  final String name;
  final String Category;
  final String Bio;
  final String Monetization;
  final String? number;

  const User(
      {required this.email,
      required this.uid,
      required this.photourl,
      required this.username,
      required this.followers,
      required this.following,
      required this.password,
      required this.name,
      required this.Category,
      required this.Bio,
      required this.Monetization,
      this.number});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'password': password,
        'followers': [],
        'following': [],
        'photourl': photourl,
        'name': name,
        'Category': Category,
        'Bio': Bio,
        'Monetization': Monetization,
        "number": number
      };

  static User fromsnap(DocumentSnapshot snapshot) {
    var snaoshot = snapshot.data() as Map<String, dynamic>;
    return User(
        email: snaoshot['email'],
        uid: snaoshot['uid'],
        photourl: snaoshot['photourl'],
        username: snaoshot['username'],
        followers: snaoshot['followers'],
        following: snaoshot['following'],
        password: snaoshot['password'],
        name: snaoshot['name'],
        Category: snaoshot['Category'],
        Bio: snaoshot['Bio'],
        Monetization: snaoshot['Monetization'],
        number: snaoshot['number']);
  }
}
