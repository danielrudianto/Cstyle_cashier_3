import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 10,
        top: 10,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "#",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "Reference",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              "Description",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Price",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "In stock",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ),
          const SizedBox(
            width: 40,
          )
        ],
      ),
    );
  }
}
