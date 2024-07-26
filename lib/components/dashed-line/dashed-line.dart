import 'package:flutter/cupertino.dart';

class DashedLineHelper extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 5;
    double startX = 0;
    final paint = Paint()
      ..color = Color.fromARGB(255, 170, 170, 170)
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashHeight, 0), paint);
      startX += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
