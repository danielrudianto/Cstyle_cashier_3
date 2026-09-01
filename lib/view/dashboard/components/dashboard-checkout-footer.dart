import 'package:cstyle_cashier_3/components/checkout-card/checkout-card.dart';
import 'package:cstyle_cashier_3/components/dashed-line/dashed-line.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardCheckoutFooter extends StatelessWidget {
  final num value;
  final Function checkout;
  const DashboardCheckoutFooter({
    super.key,
    required this.value,
    required this.checkout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 5,
                offset: const Offset(0, -5),
              ),
            ],
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          margin: const EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 25,
          ),
          child: Column(
            children: [
              /*
                DULU "Total", PERSIS SAMA DENGAN YANG DI BAWAH GARIS SOBEK.

                Tata letak ini meniru struk: yang di ATAS garis sobek adalah
                rinciannya, yang di BAWAH adalah jumlah yang dibayar. Baris
                "Subtotal" yang mestinya mengisi bagian atas dikomentari (ia
                membagi dengan 1,11 untuk pajak yang tidak berlaku), dan yang
                tersisa hanyalah Total yang sama diketik dua kali — dua angka
                identik bersusun, yang justru membuat kasir berhenti sejenak
                mencari bedanya.

                Diganti dengan jumlah barang, yang memang termasuk rincian dan
                memang berguna di meja kasir: pemeriksaan cepat bahwa yang
                terpindai sebanyak yang ada di tangan.
              */
              Consumer<CartNotifier>(
                builder: (_, keranjang, __) {
                  final barang = keranjang.selectedCart?.products ?? [];
                  final jumlahBaris = barang.length;
                  final jumlahUnit = barang.fold<int>(
                    0,
                    (jumlah, x) => jumlah + x.quantity,
                  );

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          jumlahBaris == 1
                              ? "1 product"
                              : "$jumlahBaris products",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          jumlahUnit == 1 ? "1 pc" : "$jumlahUnit pcs",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Text(
              //         "Subtotal",
              //         style: Theme.of(context).textTheme.bodyLarge,
              //       ),
              //     ),
              //     Expanded(
              //       child: Text(
              //         NumberFormat("#,##0.##").format(
              //           value / 1.11,
              //         ),
              //         style: Theme.of(context).textTheme.bodyLarge,
              //         textAlign: TextAlign.right,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Text(
              //         "Tax",
              //         style: Theme.of(context).textTheme.bodyLarge,
              //       ),
              //     ),
              //     Expanded(
              //       child: Text(
              //         NumberFormat("#,##0.##").format(
              //           value - value / 1.11,
              //         ),
              //         style: Theme.of(context).textTheme.bodyLarge,
              //         textAlign: TextAlign.right,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 350,
              height: 25,
              decoration: BoxDecoration(color: Colors.transparent, boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ]),
              child: CustomPaint(
                painter: CheckoutCard(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            SizedBox(
              width: 325,
              height: 1,
              child: CustomPaint(
                painter: DashedLineHelper(),
                size: const Size(300, 1),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.all(
            20,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Total",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: AngkaBergerak(
                  nilai: value.toDouble(),
                  gaya: Theme.of(context).textTheme.headlineSmall,
                  rataan: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  // style to have padding
                  onPressed: () {
                    // Check the stock first
                    Provider.of<CartNotifier>(context, listen: false)
                        .checkStock()
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Insufficient stock, please check the cart!"),
                          ),
                        );
                      } else {
                        checkout();
                      }
                    });
                  },
                  /*
                    FilledButton, bukan ElevatedButton berlatar
                    secondaryHeaderColor.

                    Bentuk lama menyebut warna latarnya sendiri tetapi tidak
                    warna tulisannya, jadi labelnya mewarisi bawaan Material —
                    colorScheme.primary — dan sejak aksen dipromosikan ke situ,
                    hasilnya ungu di atas ungu. Tombol terpenting di aplikasi
                    ini labelnya nyaris tidak terbaca.

                    Menyerahkannya ke tema juga memberinya keadaan sorot,
                    elevasi, dan kursor tangan tanpa satu baris tambahan.
                  */
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Checkout"),
                ),
              ),
              IconButton(
                onPressed: () {
                  Provider.of<CartNotifier>(
                    context,
                    listen: false,
                  ).deselectCart();
                },
                icon: Icon(
                  Icons.archive,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              IconButton(
                onPressed: () {
                  Provider.of<CartNotifier>(
                    context,
                    listen: false,
                  ).deleteCurrentCart();
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
