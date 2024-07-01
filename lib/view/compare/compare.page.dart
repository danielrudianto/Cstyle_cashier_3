import 'package:flutter/material.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compare products"),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text("Images"),
          ),
        ],
      ),
    );
  }
}
