import 'package:cstyle_cashier_3/model/model.cart.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/view/dashboard/dashboard.page.dart';
import 'package:cstyle_cashier_3/view/store/store.page.dart';
import 'package:cstyle_cashier_3/view/page-view/components/appbar-pageview.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/utils/waktu.utils.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class PageViewPage extends StatefulWidget {
  const PageViewPage({super.key});

  @override
  State<PageViewPage> createState() => _PageViewPageState();
}

class _PageViewPageState extends State<PageViewPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);

    Widget? buildCartUpdateSection(int index) {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      var cartNotifier = Provider.of<CartNotifier>(context, listen: false);

      TextEditingController discountController = TextEditingController();
      TextEditingController quantityController = TextEditingController();

      discountController.text =
          cartNotifier.selectedCart!.products[index].discount.toString();

      quantityController.text =
          cartNotifier.selectedCart!.products[index].quantity.toString();

      updateCartItem() async {
        // Validate discount & quantity first
        if (discountController.text.isEmpty ||
            quantityController.text.isEmpty) {
          return;
        }

        var discount = double.parse(discountController.text);
        var quantity = int.parse(quantityController.text);

        if (discount < 0 || discount > 100) {
          return;
        }

        if (quantity < 0) {
          return;
        }

        await cartNotifier.updateQuantityDiscount(index, quantity, discount);
      }

      if (cartNotifier.selectedCart != null) {
        return Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  controller: discountController,
                  decoration: InputDecoration(
                    hintText: "Discount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.percent,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  controller: quantityController,
                  decoration: InputDecoration(
                    prefix: SizedBox(
                      width: 25,
                      height: 25,
                      child: IconButton(
                        tooltip: "Decrease quantity",
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          if (quantityController.text.isNotEmpty) {
                            var quantity = int.parse(quantityController.text);
                            if (quantity > 0) {
                              quantityController.text =
                                  (quantity - 1).toString();
                            } else {
                              return;
                            }
                          } else {
                            quantityController.text = "0";
                          }
                        },
                        icon: Icon(
                          Icons.remove,
                          color: Colors.grey.shade700,
                          size: 8,
                        ),
                      ),
                    ),
                    suffix: SizedBox(
                      width: 25,
                      height: 25,
                      child: IconButton(
                        tooltip: "Increase quantity",
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          if (quantityController.text.isNotEmpty) {
                            var quantity = int.parse(quantityController.text);
                            quantityController.text = (quantity + 1).toString();
                          } else {
                            quantityController.text = "1";
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.grey.shade700,
                          size: 10,
                        ),
                      ),
                    ),
                    hintText: "Quantity",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              // Save button
              TextButton(
                onPressed: updateCartItem,
                child: const Text(
                  "Save",
                ),
              ),
            ],
          ),
        );
      } else {
        LoggerUtils().log(
            "Cart is not selected, cannot create cart update section",
            LogType.error);
        return null;
      }
    }

    Future<void> openProductCart() async {
      final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
      var selectedCart = cartNotifier.selectedCart;
      if (selectedCart != null) {
        LoggerUtils().log("Cart found", LogType.info);
        showDialog(
          barrierColor: const Color.fromARGB(103, 148, 148, 148),
          context: context,
          builder: (context) {
            int? openedIndex;

            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 90,
                          right: 15,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            return;
                          },
                          child:
                              Consumer<CartNotifier>(builder: (_, value, __) {
                            return Container(
                              height:
                                  (MediaQuery.of(context).size.height - 90) *
                                      0.9,
                              width: 450,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).cardColor,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Order ${value.selectedCart!.name}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop("archive");
                                        },
                                        child: const Text(
                                          "Archive",
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop("clear");
                                        },
                                        child: const Text(
                                          "Clear cart",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey.shade400,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: value.selectedCart!.products
                                            .mapIndexed((index, e) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            e.reference,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          tooltip:
                                                              "Remove from cart",
                                                          onPressed: () {
                                                            if (openedIndex !=
                                                                null) {
                                                              setState(() {
                                                                openedIndex =
                                                                    null;
                                                              });
                                                            }

                                                            if (value
                                                                    .selectedCart!
                                                                    .products
                                                                    .length ==
                                                                1) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }

                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                                () {
                                                              cartNotifier
                                                                  .deleteProductFromCart(
                                                                      index);
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors
                                                                .grey.shade400,
                                                            size: 18,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      e.description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              if (index ==
                                                                  openedIndex) {
                                                                setState(() {
                                                                  openedIndex =
                                                                      null;
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  openedIndex =
                                                                      index;
                                                                });
                                                              }
                                                            },
                                                            child: e.discount ==
                                                                    0
                                                                ? Text(
                                                                    "${NumberFormat.decimalPattern("en_US").format(e.quantity)} x ${NumberFormat.decimalPattern("en_US").format(e.price)}",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium)
                                                                : RichText(
                                                                    text: TextSpan(
                                                                        text: NumberFormat.decimalPattern("en_US").format(e
                                                                            .quantity),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                        children: <TextSpan>[
                                                                          const TextSpan(
                                                                            text:
                                                                                " x ",
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                NumberFormat.decimalPattern("en_US").format((e.price * (100 - e.discount)) / 100),
                                                                          ),
                                                                          const TextSpan(
                                                                            text:
                                                                                "  ",
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                NumberFormat.decimalPattern("en_US").format(e.price),
                                                                            style:
                                                                                const TextStyle(
                                                                              decoration: TextDecoration.lineThrough,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                          ),
                                                        ),
                                                        Text(
                                                          NumberFormat
                                                                  .decimalPattern(
                                                                      "en_US")
                                                              .format(e
                                                                      .quantity *
                                                                  (e.price *
                                                                      (100 -
                                                                          e.discount)) /
                                                                  100),
                                                        ),
                                                      ],
                                                    ),
                                                    AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 5,
                                                        bottom: 5,
                                                      ),
                                                      width: double.infinity,
                                                      height:
                                                          openedIndex == index
                                                              ? 50
                                                              : 0,
                                                      child: AnimatedOpacity(
                                                        opacity:
                                                            openedIndex == index
                                                                ? 1
                                                                : 0,
                                                        duration:
                                                            const Duration(
                                                          milliseconds: 300,
                                                        ),
                                                        child:
                                                            buildCartUpdateSection(
                                                                index),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Total",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          NumberFormat.decimalPattern("en_US")
                                              .format(
                                            value.totalPrice,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Checkout button
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop("checkout");
                                      },
                                      child: const Text(
                                        "Checkout",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          },
        ).then((value) async {
          if (value == "checkout") {
            // Check stock first
            var validation = await cartNotifier.checkStock();
            if (!validation) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Insufficient stock")));
            } else {}
          } else if (value == "clear") {
            Future.delayed(
                const Duration(
                  milliseconds: 300,
                ), () async {
              try {
                await cartNotifier.deleteCurrentCart();
              } catch (error) {
                LoggerUtils().log("Error", LogType.error,
                    error: error, stackTrace: StackTrace.current);
              }
            });
          } else if (value == "archive") {
            Future.delayed(
                const Duration(
                  milliseconds: 300,
                ), () async {
              try {
                cartNotifier.deselectCart();
              } catch (error) {
                LoggerUtils().log("Error", LogType.error,
                    error: error, stackTrace: StackTrace.current);
              }
            });
          }
        });
      } else {
        LoggerUtils().log("Cart not found", LogType.info);
      }
    }

    Future<void> openProductCartList() async {
      final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
      var carts = await cartNotifier.getCarts();
      showDialog(
        barrierColor: const Color.fromARGB(103, 148, 148, 148),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 90,
                        right: 15,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          return;
                        },
                        child: Container(
                          /*
                            Tingginya MENGIKUTI ISI, dengan batas atas. Dulu
                            dipatok 90% tinggi layar apa pun isinya, jadi dua
                            nota tertahan menghasilkan panel setinggi satu layar
                            dengan ruang kosong di bawahnya — dan ruang kosong
                            sebesar itu terbaca sebagai daftar yang gagal
                            memuat, bukan sebagai daftar yang memang pendek.
                          */
                          constraints: BoxConstraints(
                            maxHeight:
                                (MediaQuery.of(context).size.height - 90) * 0.9,
                          ),
                          width: 420,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /*
                                Panel ini dulu muncul tanpa judul sama sekali —
                                sederet nomor dan tanggal melayang di atas layar,
                                tanpa apa pun yang menyebutkan itu daftar apa.
                              */
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 16, 10, 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        carts.isEmpty
                                            ? "Held bills"
                                            : "Held bills (${carts.length})",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: "Close",
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: const Icon(Icons.close, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                              if (carts.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(18, 34, 18, 40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 30,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Nothing on hold",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Bills you set aside show up here.",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Flexible(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8,
                                    ),
                                    itemCount: carts.length,
                                    itemBuilder: (context, index) {
                                      final nota = carts[index];
                                      final terbuka =
                                          cartNotifier.selectedCart?.id ==
                                              nota.id;

                                      return _BarisNotaTertahan(
                                        waktu: waktuManusiawi(nota.date),
                                        nomor: nota.name,
                                        jumlahUnit: nota.itemCount,
                                        total: nota.totalPrice,
                                        terbuka: terbuka,
                                        onPilih: terbuka
                                            ? null
                                            : () async {
                                                var cart =
                                                    await CartModel.fetchByID(
                                                        nota.id!);
                                                if (!context.mounted) return;
                                                Provider.of<CartNotifier>(
                                                  context,
                                                  listen: false,
                                                ).selectCart(cart);
                                                Navigator.of(context).pop();
                                              },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        },
      );
    }

    /*
      Gradien permukaan kerja dipasang di akar halaman ini, dan Scaffold di
      dalamnya dibuat transparan supaya tembus.

      Ditaruh di sini, bukan di tiap Scaffold, karena halaman utama memuat dua
      halaman berdampingan di dalam PageView. Kalau masing-masing melukis
      gradiennya sendiri, keduanya akan mulai dari nol lagi di tepi masing-
      masing — dan saat digeser, sambungannya terlihat sebagai garis.
    */
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradienKerja(context)),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            AppbarPageView(
              page: currentPage,
              changePage: (page) {
                setState(() {
                  currentPage = page;
                });

                pageController.animateToPage(
                  currentPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onOpenCart: () {
                openProductCart();
              },
              onOpenCartList: () {
                openProductCartList();
              },
            ),
            Expanded(
              child: PageView(
                pageSnapping: true,
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                children: const [
                  DashboardPage(),
                  StorePage(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Satu nota tertahan di dalam panel.
///
/// APA YANG DIBUTUHKAN UNTUK MENEMUKANNYA KEMBALI.
///
/// Panel ini dipakai ketika pembeli pergi mengambil barang lain dan kasir
/// melayani orang berikutnya. Untuk kembali ke nota yang benar, yang ditanyakan
/// bukan nomornya — dua belas angka acak yang tidak pernah dibaca siapa pun —
/// melainkan "yang tadi, tiga barang, dua ratus ribuan".
///
/// Karena itu barisnya membawa jam, jumlah barang, dan totalnya. Ketiganya dulu
/// tidak ada: daftarnya hanya berisi nomor dan tanggal, dan enam nota pada hari
/// yang sama benar-benar tidak bisa dibedakan satu sama lain.
class _BarisNotaTertahan extends StatefulWidget {
  final String waktu;
  final String nomor;
  final int jumlahUnit;
  final double total;
  final bool terbuka;
  final VoidCallback? onPilih;

  const _BarisNotaTertahan({
    required this.waktu,
    required this.nomor,
    required this.jumlahUnit,
    required this.total,
    required this.terbuka,
    required this.onPilih,
  });

  @override
  State<_BarisNotaTertahan> createState() => _BarisNotaTertahanState();
}

class _BarisNotaTertahanState extends State<_BarisNotaTertahan> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final aksen = tema.secondaryHeaderColor;

    final Color latar = widget.terbuka
        ? aksen.withValues(alpha: 0.12)
        : (_disorot
            ? warna.onSurface.withValues(alpha: 0.05)
            : Colors.transparent);

    return MouseRegion(
      cursor: widget.terbuka ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.onPilih,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
          decoration: BoxDecoration(
            color: latar,
            borderRadius: BorderRadius.circular(9),
            border: Border(
              left: BorderSide(
                color: widget.terbuka ? aksen : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.waktu,
                      style: tema.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.terbuka ? aksen : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(widget.nomor, style: gayaLabelKolom(context)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Rp ${NumberFormat("#,##0").format(widget.total)}",
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.jumlahUnit == 1
                        ? "1 pc"
                        : "${widget.jumlahUnit} pcs",
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
