import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:cstyle_cashier_3/model/model.product-image.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/view/compare/components/product-image.component.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardGridList extends StatelessWidget {
  final List<ProductModel> products;
  final Function onAddProduct;
  const DashboardGridList({
    super.key,
    required this.products,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildChildren(ProductModel e) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ProductImageComponent(
            id: e.id,
            autoPlay: true,
          ),
          Row(
            children: [
              SizedBox(
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Brand",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      e.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                    ),
                    Text(
                      "Reference",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      e.reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Type",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      e.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                    ),
                    Text(
                      "Description",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      e.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Type",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      e.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                    ),
                    Text(
                      "Barcode",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      e.barcode == null || e.barcode == "" ? "N/A" : e.barcode!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Consumer2<CompareNotifier, CartNotifier>(
          builder: (_, compareNotifier, cartNotifier, child) {
        return ExpansionTileGroup(
          toggleType: ToggleType.expandOnlyCurrent,
          children: products.mapIndexed((index, e) {
            return ExpansionTileItem(
              key: Key(index.toString()),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              isHasTrailing: false,
              tilePadding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 5,
                bottom: 5,
              ),
              title: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Checkbox(
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      checkColor: Colors.white,
                      activeColor: const Color.fromARGB(255, 109, 78, 137),
                      value: compareNotifier.hasProduct(e.id),
                      onChanged: (value) {
                        LoggerUtils().log(
                            "User has change ${e.id} to $value. Prepared to be compared.",
                            LogType.info);

                        if (value != null && value == false) {
                          Provider.of<CompareNotifier>(context, listen: false)
                              .deselectProduct(e.id);
                        } else if (value != null && value == true) {
                          Provider.of<CompareNotifier>(context, listen: false)
                              .selectProduct(e);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Text(
                      e.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      NumberFormat.decimalPattern("en-US").format(e.price),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      NumberFormat.decimalPattern("en-US").format(
                          (e.stock ?? 0) -
                              cartNotifier.checkProductQuantity(e.id)),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      onPressed: ((e.stock ?? 0) -
                                  cartNotifier.checkProductQuantity(e.id)) <=
                              0
                          ? null
                          : () {
                              onAddProduct(e);
                            },
                      icon: const Icon(Icons.add_shopping_cart),
                    ),
                  )
                ],
              ),
              children: [
                buildChildren(e),
              ],
            );
          }).toList(),
        );
      }),
    );
  }
}
