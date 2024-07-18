import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ActionCard extends StatelessWidget {
  final String imageString;
  final String title;
  final String description;
  final Function onPressed;
  const ActionCard({
    super.key,
    required this.imageString,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color.fromARGB(255, 109, 41, 187),
            child: Image.asset(
              imageString,
              width: 25,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 75,
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () {
              onPressed();
            },
            child: Container(
              // border
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 35,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: const Border(
                  // all border
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 109, 41, 187),
                  ),
                  top: BorderSide(
                    color: Color.fromARGB(255, 109, 41, 187),
                  ),
                  left: BorderSide(
                    color: Color.fromARGB(255, 109, 41, 187),
                  ),
                  right: BorderSide(
                    color: Color.fromARGB(255, 109, 41, 187),
                  ),
                ),
                color: Colors.transparent,
              ),
              child: const Text(
                "Learn More",
                style: TextStyle(
                  color: Color.fromARGB(255, 109, 41, 187),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
