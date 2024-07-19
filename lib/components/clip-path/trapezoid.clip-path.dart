import 'dart:ui';

import 'package:flutter/material.dart';

class TrapezoidClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Create a trapezoid where the left is full height and the right is full height - 200
    Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 200);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class InversedTrapezoidClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Create a trapezoid where the left is full height - 200 and the right is full height
    Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height - 200);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
