import 'package:flutter/material.dart';

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Determine the slide direction based on text direction
            final bool isRTL = Directionality.of(context) == TextDirection.rtl;
            
            // Create slide transition
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(isRTL ? -1.0 : 1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
}
