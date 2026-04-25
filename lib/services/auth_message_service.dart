import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService();

  // Method to get the current user
  User? getCurrentUser() {
    User? currentUser = _auth.currentUser;
    return currentUser;
  }
}
// class AuthService{
//   AuthService(){}
//   User? _user;
//
//   User? get user{
//     return _user;
//   }
//
// }