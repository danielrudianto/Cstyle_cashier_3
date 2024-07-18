import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TopStockTransfer extends StatelessWidget {
  const TopStockTransfer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        // Border bottom
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 80,
        child: Center(
          child: Image.asset(
            "assets/images/icon.webp",
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }
}
