import 'package:collection/collection.dart';
import 'package:cstyle_cashier_3/model/model.product-image.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/components/product-image.component.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
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
    showProductDialog(
        ProductModel e, List<ProductImageModel> images, int stock) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                width: images.isEmpty ? 350 : 565,
                height: 250,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    images.isEmpty
                        ? const SizedBox()
                        : Expanded(
                            child: ProductImageComponent(
                              id: e.id,
                              autoPlay: true,
                              bordered: false,
                              static: false,
                            ),
                          ),
                    SizedBox(
                      width: images.isEmpty ? 0 : 15,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  e.reference,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Text(e.description,
                                style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(e.brand,
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Rp. ${NumberFormat("#,##0.00").format(e.price)}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SorotMembesar(
                              child: InkWell(
                                onTap: () {
                                  router.pop("add");
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: stock == 0
                                        ? Theme.of(context).disabledColor
                                        : Theme.of(context)
                                            .secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 7.5,
                                    horizontal: 25,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        stock == 0
                                            ? "Not Available"
                                            : "Available",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "100% Original Products",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Pay on delivery",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).then((value) {
        if (value == 'add') {
          onAddProduct(e);
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Consumer2<CompareNotifier, CartNotifier>(
          builder: (_, compareNotifier, cartNotifier, child) {
        return Column(
          children: products.mapIndexed((index, e) {
            return SorotBerlatar(
              child: InkWell(
                onTap: ((e.stock ?? 0) -
                            cartNotifier.checkProductQuantity(e.id)) <=
                        0
                    ? () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Insufficient stock. If you have reported this issue and adjustment has been made, please go to setting and override manually.",
                            ),
                            action: SnackBarAction(
                              label: "OK",
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      }
                    : () {
                        onAddProduct(e);
                      },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Checkbox(
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                          checkColor: Colors.white,
                          activeColor: const Color.fromARGB(255, 109, 78, 137),
                          value: compareNotifier.hasProduct(e.id),
                          onChanged: (value) {
                            LoggerUtils().log(
                                "User has change ${e.id} to $value. Prepared to be compared.",
                                LogType.info);

                            if (value != null && value == false) {
                              Provider.of<CompareNotifier>(context,
                                      listen: false)
                                  .deselectProduct(e.id);
                            } else if (value != null && value == true) {
                              Provider.of<CompareNotifier>(context,
                                      listen: false)
                                  .selectProduct(e);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        flex: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              e.reference,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              e.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          NumberFormat.decimalPattern("en-US").format(e.price),
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          NumberFormat.decimalPattern("en-US").format(
                              (e.stock ?? 0) -
                                  cartNotifier.checkProductQuantity(e.id)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          onPressed: () async {
                            List<ProductImageModel> images =
                                await ProductImageModel.fetchByItemID(e.id);
                            showProductDialog(
                                e,
                                images,
                                (e.stock ?? 0) -
                                    cartNotifier.checkProductQuantity(e.id));
                          },
                          icon: const Icon(Icons.view_array),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
