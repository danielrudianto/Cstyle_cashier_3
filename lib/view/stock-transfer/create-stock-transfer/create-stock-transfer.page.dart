import 'package:cstyle_cashier_3/utils/motion.utils.dart';
 import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/components/store-selector/store-selector.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/view/product-selector/product-selector.page.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateStockTransferPage extends StatefulWidget {
  const CreateStockTransferPage({super.key});

  @override
  State<CreateStockTransferPage> createState() =>
      _CreateStockTransferPageState();
}

class _CreateStockTransferPageState extends State<CreateStockTransferPage> {
  bool isSubmitting = false;
  bool isFetchingStores = false;
  List<StoreModel> stores = [];
  StoreModel? store;
  List<ProductModelStockTransfer> products = [];
  TextEditingController noteController = TextEditingController();

  get isValid {
    return store != null && products.isNotEmpty;
  }

  _openStoreSelector() {
    bukaDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            child: StoreSelector(),
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          store = value as StoreModel;
        });
      }
    });
  }

  _openProductSelector() {
    var isDialogOpened = true;
    bukaDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ProductSelectorPage(
              storeID: store?.id,
              selectedItems: products.map((e) {
                return {
                  "id": e.id,
                  "reference": e.reference,
                  "description": e.description,
                };
              }).toList(),
              closeDialog: (p0) {
                if (p0 is List<dynamic>) {
                  // set the state
                  var selectedProducts =
                      List<ProductModelStockTransfer>.from(p0.map((e) {
                    var index = products.indexWhere(
                        (element) => element.id == e['id'].toString());

                    return ProductModelStockTransfer(
                      id: e['id'].toString(),
                      reference: e['reference'],
                      description: e['description'],
                      brand: "",
                      type: "",
                      price: 0,
                      stock: 0,
                      quantity: index == -1 ? 1 : products[index].quantity,
                    );
                  }).toList());

                  // set the state
                  setState(() {
                    products = selectedProducts;
                  });
                }

                if (isDialogOpened) {
                  Navigator.of(context).pop();
                }
              },
            ),
          );
        }).then((value) {}).whenComplete(() {
      isDialogOpened = false;
    });
  }

  _createStockTransfer() {
    setState(() {
      isSubmitting = true;
    });

    if (store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a store",
          ),
        ),
      );
      return;
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please add at least one product",
          ),
        ),
      );
      return;
    }

    // No products can be 0
    if (products.any((element) => element.quantity == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Quantity of products cannot be 0",
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<UserModel?>(
        // ignore: use_build_context_synchronously
        context: context,
        showDragHandle: false,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return const SelectEmployee();
        }).then((value) {
      if (value != null) {
        StockTransferModel(
          storeID: store!.id,
          items: products.map((x) {
            return StockTransferItemModel(itemID: x.id, quantity: x.quantity);
          }).toList(),
          createdBy: value.id,
          createdAt: DateTime.now(),
          note: noteController.text,
        ).create().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Stock transfer request successfully created."),
            ),
          );

          setState(() {
            products.clear();
            store = null;
            noteController.text = "";
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString(),
              ),
            ),
          );

          setState(() {
            isSubmitting = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        /*
          Judulnya dipendekkan. "Create stock transfer request" mengulang
          kata yang sudah disebut penandanya di atas, dan tiga kata benda
          beruntun membuat judul yang seharusnya dibaca sekilas jadi harus
          diurai dulu.
        */
        const KepalaHalaman(
          penanda: "INVENTORY",
          judul: "New transfer",
          keterangan: "Ask another store, or the office, to send stock to "
              "this one.",
        ),
        const SizedBox(height: 22),
        BarisMeta(
          isi: [
            Meta("DATE", DateFormat("d MMM yyyy").format(DateTime.now())),
          ],
        ),
        /*
          Jarak di atas panel dipegang DI SINI, bukan oleh masing-masing judul.
          Selama keduanya menyisipkan jaraknya sendiri-sendiri, keduanya harus
          disetel ke angka yang sama supaya sejajar — dan angka yang sama di dua
          tempat adalah dua tempat yang bisa berbeda.
        */
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              /*
                Kotak bergaris DIBUANG. Warnanya Colors.grey.shade300 —
                nilai untuk latar terang — sehingga di tema gelap dua
                panel inilah bidang paling terang di halaman. Yang
                memisahkan bagiannya sekarang garis rambut di bawah
                labelnya, sama seperti halaman lain.
              */
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*
                    Bilah judul hitam pekat DIBUANG. Ia memenuhi lebar
                    panel dengan warna solid untuk memuat dua kata, dan
                    penomorannya menjanjikan urutan langkah yang tidak
                    pernah ada — tidak ada langkah 2 di halaman ini.
                  */
                  const JudulBagian("DESTINATION", atas: 0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*
                          Tanggalnya DIBUANG dari sini. Ia sudah tertulis
                          di baris keterangan di kepala halaman, dan dua
                          tempat yang menampilkan hal yang sama berarti dua
                          tempat yang harus ikut berubah.
                        */
                        /*
                          Dulu label kecil dengan ikon TAMBAH di ujung
                          kanan. Tanda tambah berarti menambahkan sesuatu
                          ke sebuah daftar; yang dikerjakan di sini memilih
                          satu tujuan, dan memilih lagi menggantikan yang
                          sebelumnya. Sekarang tombolnya menyebut itu.
                        */
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store == null
                                    ? "No destination chosen"
                                    : "Sending to",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TombolBagian(
                              label: store == null
                                  ? "Choose store"
                                  : "Change store",
                              ikon: Icons.storefront_outlined,
                              onTekan: _openStoreSelector,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        store == null
                            ? const SizedBox.shrink()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store!.name,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    store!.address,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                        /*
                          Catatannya dulu muncul begitu saja: satu kotak
                          bergaris di bawah tujuan, tanpa judul, sementara
                          semua yang lain di halaman ini diperkenalkan oleh
                          label bergaris rambut. Judulnya sekarang ada, dan
                          karena judul itu sudah menyebut namanya, nama yang
                          mengambang di dalam kolomnya dibuang — diganti
                          petunjuk yang menyebutkan apa yang layak ditulis.
                        */
                        const JudulBagian("NOTE", atas: 26),
                        TextField(
                          controller: noteController,
                          decoration: dekorasiIsian(
                            context,
                            petunjuk:
                                "Anything the sending store should know",
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*
                    Bilah ungu 80% DIBUANG, sama alasannya dengan
                    bilah hitam di panel sebelah. Tombol tambahnya
                    pindah ke kanan barisan label — tempat yang sama
                    dengan tindakan di seluruh aplikasi.
                  */
                  JudulBagian(
                    "PRODUCTS",
                    atas: 0,
                    aksi: TombolBagian(
                      label: "Add product",
                      ikon: Icons.add_rounded,
                      onTekan: _openProductSelector,
                    ),
                  ),
                  products.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(
                            20,
                          ),
                          child: Center(
                            child: Text(
                              "You have not selected any products",
                              style:
                                  Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        )
                      : ListView.separated(
                          /*
                            Pemisah samar antarbarang. Tanpa itu, dua
                            barang dengan nama panjang menyatu menjadi
                            satu blok tulisan.
                          */
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Theme.of(context).dividerColor,
                          ),
                          shrinkWrap: true,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final produk = products[index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                8,
                                12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produk.reference,
                                          style: gayaKode(context),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          produk.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  KendaliJumlah(
                                    jumlah: produk.quantity,
                                    onUbah: (n) {
                                      setState(() {
                                        produk.quantity = n;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 2),
                                  IconButton(
                                    tooltip: "Remove from request",
                                    onPressed: () {
                                      setState(() {
                                        products.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 17,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: isValid ? _createStockTransfer : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: isValid
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Submit",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: isValid
                                ? Colors.white
                                : Theme.of(context).disabledColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
