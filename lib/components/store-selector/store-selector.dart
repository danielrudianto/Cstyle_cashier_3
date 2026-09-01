import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/material.dart';

class StoreSelector extends StatefulWidget {
  const StoreSelector({super.key});

  @override
  State<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  bool isLoading = true;
  List<StoreModel> stores = [];

  _fetchStores() {
    StoreModel.fetchStores().then((fetchedStores) {
      setState(() {
        stores = fetchedStores;
      });
    }).catchError((error) {
      LoggerUtils().log(
        error,
        LogType.error,
      );

      // close dialog
      Navigator.pop(context);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  initState() {
    super.initState();
    _fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*
            Bilah ungu setinggi 80 piksel DIBUANG — sama seperti dialog lain di
            aplikasi ini. Pada dialog setinggi 300 piksel, sepertiganya dipakai
            satu baris judul yang diberi warna paling menonjol di layar,
            padahal ia satu-satunya bagian yang tidak perlu dikerjakan siapa
            pun.

            Tingginya juga tidak lagi dipatok. Dulu 300 piksel apa pun isinya:
            empat toko menyisakan ruang kosong, dan kalau tokonya bertambah,
            daftarnya menggulir di dalam kotak yang tidak perlu sempit.
          */
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 10, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Send from",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: "Close",
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
            child: Text(
              "Which store, or the office, should send the stock.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            stores[index].name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          onTap: () {
                            Navigator.pop(context, stores[index]);
                          },
                        );
                      },
                      itemCount: stores.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
