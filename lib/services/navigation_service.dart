import 'package:flutter/material.dart';
import 'package:zizzle/Screens/add_post_screen.dart';
import 'package:zizzle/Screens/profile_screen.dart';
import '/Screens/Home_screen.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/feed_screen.dart';
import 'package:path/path.dart';

class Navigationservice {
  late GlobalKey<NavigatorState> _navigatorkey;
  final Map<String, Widget Function(BuildContext)> _routes = {
    "/feed": (context) => FeedScreen(),
    "/home": (context) => Homepage(),
    "/settings": (context) => ProfileScreen(),
    "/splash": (context) => SplashScreen(),
    "/postphoto": (context) => AddPostScreen()
  };
  GlobalKey<NavigatorState>? get navigatorkey {
    return _navigatorkey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  Navigationservice() {
    _navigatorkey = GlobalKey<NavigatorState>();
  }
  void push(MaterialPageRoute route) {
    _navigatorkey.currentState?.push(route);
  }

  void pushnamed(String routename) {
    _navigatorkey.currentState?.pushNamed(routename);
  }

  void pushReplacementname(String routename) {
    _navigatorkey.currentState?.pushReplacementNamed(routename);
  }

  void goback() {
    _navigatorkey.currentState?.pop();
  }
}
