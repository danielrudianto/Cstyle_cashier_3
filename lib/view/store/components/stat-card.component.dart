import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Function onPressed;
  const StatCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        // Border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Color.fromARGB(255, 0, 32, 92),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 46, 46, 46),
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      onPressed();
                    },
                    icon: Icon(
                      Icons.help_outline,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Color.fromARGB(255, 46, 46, 46),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Color.fromARGB(255, 112, 112, 112),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
