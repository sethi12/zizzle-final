
import 'package:flutter/material.dart';
import '../utils/dimension.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget WebScreenLayout;
  final Widget MobileScreenLayout;
  const ResponsiveLayout({super.key,required this.MobileScreenLayout,required this.WebScreenLayout});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webscreensize) {
        //web screen layout
        return WebScreenLayout;
      }
      return MobileScreenLayout;
    },

    );
  }
}
