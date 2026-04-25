import 'package:flutter/material.dart';

class FollowButtonState extends ChangeNotifier {
  bool _isFollowing = false;

  bool get isFollowing => _isFollowing;

  void setFollowing(bool value) {
    _isFollowing = value;
    notifyListeners();
  }

// You can add more methods if needed
}
