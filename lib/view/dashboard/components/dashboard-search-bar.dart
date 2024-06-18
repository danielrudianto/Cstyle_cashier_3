import 'package:flutter/material.dart';

class DashboardSearchBar extends StatefulWidget {
  final Function(String) onChanged;
  final bool isDisabled;
  const DashboardSearchBar(
      {super.key, required this.onChanged, required this.isDisabled});

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
    );
  }
}
