import 'dart:math';

import 'package:flutter/material.dart';

class PaginationComponent extends StatelessWidget {
  final int pageIndex;
  final int dataCount;
  final int pageSize;
  final Function(int) onPageChange;

  const PaginationComponent({
    super.key,
    required this.pageIndex,
    required this.dataCount,
    required this.pageSize,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = max((dataCount / pageSize).ceil(), 1);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 25,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Page number display
          Text(
            'Page ${pageIndex + 1} of $totalPages',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          IconButton(
            tooltip: "Previous page",
            icon: Icon(
              size: 24,
              Icons.chevron_left_rounded,
              color: pageIndex == 0
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).iconTheme.color,
            ),
            onPressed: pageIndex > 0 ? () => onPageChange(pageIndex - 1) : null,
          ),
          IconButton(
            tooltip: "Next page",
            icon: Icon(
              size: 24,
              Icons.chevron_right_rounded,
              color: pageIndex + 1 == totalPages
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).iconTheme.color,
            ),
            onPressed: pageIndex + 1 < totalPages
                ? () => onPageChange(pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
