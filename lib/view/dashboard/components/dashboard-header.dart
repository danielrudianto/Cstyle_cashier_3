import 'package:cstyle_cashier_3/utils/theme.utils.dart';
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
            /* Dulu grey.shade300; garis terang di atas latar gelap. */
            color: Theme.of(context).dividerColor,
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
          /*
            Dulu berjudul "#", yang tidak berarti apa-apa: kolom ini berisi
            kotak centang pembanding, bukan nomor urut. Kolom pemilihan lazimnya
            memang tanpa judul; keterangannya dipindah ke tooltip kotaknya.
          */
          const Expanded(flex: 2, child: SizedBox.shrink()),
          Expanded(
            flex: 12,
            child: Text("PRODUCT",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: gayaLabelKolom(context)),
          ),
          Expanded(
            flex: 5,
            /*
              Rata KANAN, mengikuti nilainya. Sebelumnya judulnya rata tengah
              sementara angkanya rata kanan, jadi kolomnya terlihat goyah —
              judul dan isinya tidak pernah berdiri di sumbu yang sama.
            */
            child: Text("PRICE",
                textAlign: TextAlign.right, style: gayaLabelKolom(context)),
          ),
          Expanded(
            flex: 5,
            child: Text("IN STOCK",
                textAlign: TextAlign.right, style: gayaLabelKolom(context)),
          ),
          const SizedBox(
            width: 40,
          )
        ],
      ),
    );
  }
}
