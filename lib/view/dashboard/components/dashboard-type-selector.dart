import 'package:flutter/material.dart';

class DashboardTypeSelector extends StatefulWidget {
  final List<String> productTypes;
  final List<String> selectedTypes;
  final Function onUpdateSelectedTypes;
  const DashboardTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.productTypes,
    required this.onUpdateSelectedTypes,
  });

  @override
  State<DashboardTypeSelector> createState() => _DashboardTypeSelectorState();
}

class _DashboardTypeSelectorState extends State<DashboardTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        10,
      ),
      width: 250,
      height: double.infinity,
      // Create horizontal line border on the right side of #ccc
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            "Filters",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 15,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelStyle: TextStyle(
                color: Color.fromARGB(255, 122, 122, 122),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 209, 209, 209),
                ),
              ),
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 209, 209, 209),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 179, 179, 179),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 1,
                horizontal: 3,
              ),
              prefixIconColor: Color.fromARGB(255, 209, 209, 209),
            ),
            style: TextStyle(
              color: Color.fromARGB(255, 122, 122, 122),
              fontFamily: "Lato",
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "Product Types",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: Checkbox(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    checkColor: Colors.white,
                    activeColor: const Color.fromARGB(255, 109, 78, 137),
                    value: widget.selectedTypes.isEmpty,
                    onChanged: (value) {
                      widget.onUpdateSelectedTypes([]);
                    },
                  ),
                  title: Text(
                    "All",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                ...widget.productTypes.map((e) {
                  return ListTile(
                    leading: Checkbox(
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      checkColor: Colors.white,
                      activeColor: const Color.fromARGB(255, 109, 78, 137),
                      value: widget.selectedTypes.contains(e),
                      onChanged: (checkBoxValue) {
                        if (checkBoxValue != null && checkBoxValue == false) {
                          widget.selectedTypes
                              .removeWhere((element) => element == e);
                        } else if (checkBoxValue != null &&
                            checkBoxValue == true) {
                          widget.selectedTypes.add(e);
                        }

                        widget.onUpdateSelectedTypes(widget.selectedTypes);
                      },
                    ),
                    title: Text(
                      e,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
