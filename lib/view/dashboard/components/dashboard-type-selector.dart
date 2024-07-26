import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardTypeSelector extends StatefulWidget {
  final List<String> productTypes;
  final List<String> selectedTypes;
  final Function onUpdateSelectedTypes;
  final Function onSearch;
  const DashboardTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.productTypes,
    required this.onUpdateSelectedTypes,
    required this.onSearch,
  });

  @override
  State<DashboardTypeSelector> createState() => DashboardTypeSelectorState();
}

class DashboardTypeSelectorState extends State<DashboardTypeSelector> {
  late FocusNode searchFocusNode;

  @override
  void initState() {
    searchFocusNode = FocusNode();
    super.initState();
  }

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
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          TextFormField(
            focusNode: searchFocusNode,
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
            style: const TextStyle(
              color: Color.fromARGB(255, 122, 122, 122),
              fontFamily: "Lato",
            ),
            onChanged: (value) {
              widget.onSearch(value);
            },
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
                      if (value != null && value == true) {
                        // Remove all
                        widget.selectedTypes.clear();
                        widget.onUpdateSelectedTypes(widget.selectedTypes);
                      } else if (value != null && value == false) {
                        return;
                      }
                    },
                  ),
                  title: Text(
                    "All",
                    style: Theme.of(context).textTheme.bodyLarge,
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
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                })
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          Row(
            children: [
              Consumer<CompareNotifier>(builder: (_, value, __) {
                return IconButton(
                  // size
                  iconSize: 25,
                  onPressed: value.selectedComparisson.length >= 2
                      ? () {
                          router.push("/compare");
                        }
                      : null,
                  icon: Icon(Icons.compare_arrows_rounded,
                      color: value.selectedComparisson.length >= 2
                          ? Theme.of(context).iconTheme.color
                          : Theme.of(context).disabledColor),
                );
              }),
              IconButton(
                onPressed: () {
                  router.push("/upload");
                },
                icon: Icon(
                  Icons.cloud_upload,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  focus() {
    print("called");
    searchFocusNode.requestFocus();
  }
}
