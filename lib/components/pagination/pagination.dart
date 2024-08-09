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
    final totalPages = (dataCount / pageSize).ceil();
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
            icon: Icon(
              size: 24,
              Icons.chevron_left_rounded,
              color: pageIndex == 0 ? Colors.black45 : Colors.black87,
            ),
            onPressed: pageIndex > 0 ? () => onPageChange(pageIndex - 1) : null,
          ),
          IconButton(
            icon: Icon(
              size: 24,
              Icons.chevron_right_rounded,
              color:
                  pageIndex + 1 == totalPages ? Colors.black45 : Colors.black87,
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
