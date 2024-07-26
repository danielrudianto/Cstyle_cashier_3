import 'package:flutter/material.dart';

class CheckoutCard extends CustomPainter {
  final Color color;
  CheckoutCard({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;

    var path = Path();

    // need to make a rectangle, let's say height of 25, width of infinity
    // Then cut a circle with the diameter of 25 positioned at the center left and right corner of the rectangle

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.arcToPoint(Offset(size.width - 12.5, size.height / 2),
        radius: Radius.circular(size.height / 2), clockwise: false);

    path.arcToPoint(Offset(size.width, size.height),
        radius: Radius.circular(size.height / 2), clockwise: false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.arcToPoint(Offset(12.5, size.height / 2),
        radius: Radius.circular(size.height / 2), clockwise: false);

    path.arcToPoint(Offset(0, 0),
        radius: Radius.circular(size.height / 2), clockwise: false);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
