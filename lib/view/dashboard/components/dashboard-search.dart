import 'package:flutter/material.dart';

/// Kolom pencarian barang, diletakkan tepat di atas tabel yang disaringnya.
///
/// DULU BERADA DI KOLOM KIRI.
///
/// Ia tinggal di dalam DashboardTypeSelector — widget yang, sesuai namanya,
/// mengurus penyaring jenis barang. Jadi satu-satunya kendali yang mengubah isi
/// tabel di tengah justru duduk di kolom yang mengurus hal lain, dan widget itu
/// menerima `onSearch` yang tidak ada hubungannya dengan tugasnya sendiri.
///
/// Kendali sebaiknya berada bersama benda yang dikendalikannya. Mengetik di
/// kolom kiri lalu melihat hasilnya muncul di tengah memaksa mata berpindah
/// bolak-balik untuk sesuatu yang seharusnya satu tempat.
///
/// WARNANYA DULU DIPATOK.
///
/// Tulisannya #7A7A7A, garis tepinya #D1D1D1 dan #B3B3B3, ikon pencariannya
/// #D1D1D1 — semuanya nilai yang dipilih untuk latar terang. Sesudah aplikasi
/// mengikuti tema sistem, kolom ini menjadi abu-abu redup di atas permukaan
/// gelap: yang diketik nyaris tidak terbaca. Sekarang seluruhnya dari skema
/// warna.
class DashboardSearch extends StatefulWidget {
  /// Dipanggil setiap kali isinya berubah.
  final ValueChanged<String> onSearch;

  /// Dipanggil saat kolom ini mendapat dan kehilangan fokus.
  ///
  /// Halaman induk memakainya untuk mematikan pendengar barcode: pemindai
  /// mengirimkan tombol angka seperti papan ketik, jadi tanpa ini, mengetik
  /// angka di pencarian terbaca sebagai hasil pindaian.
  final VoidCallback onFocus;
  final VoidCallback onUnfocus;

  const DashboardSearch({
    super.key,
    required this.onSearch,
    required this.onFocus,
    required this.onUnfocus,
  });

  @override
  State<DashboardSearch> createState() => _DashboardSearchState();
}

class _DashboardSearchState extends State<DashboardSearch> {
  late final FocusNode _fokus;
  final TextEditingController _kendali = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fokus = FocusNode();
    _fokus.addListener(_saatFokusBerubah);
  }

  void _saatFokusBerubah() {
    if (_fokus.hasFocus) {
      widget.onFocus();
    } else {
      widget.onUnfocus();
    }
  }

  @override
  void dispose() {
    /*
      FocusNode versi lama tidak pernah dilepas, dan pendengarnya ikut hidup
      terus bersamanya.
    */
    _fokus.removeListener(_saatFokusBerubah);
    _fokus.dispose();
    _kendali.dispose();
    super.dispose();
  }

  void _bersihkan() {
    _kendali.clear();
    widget.onSearch("");
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(35, 14, 35, 10),
      child: ConstrainedBox(
        /*
          Dibatasi lebarnya dan dirapatkan ke kiri. Kolom pencarian selebar
          tabel terlihat seperti bidang yang menunggu kalimat, padahal yang
          diketik di sini biasanya beberapa huruf nama barang.
        */
        constraints: const BoxConstraints(maxWidth: 420),
        child: TextField(
          controller: _kendali,
          focusNode: _fokus,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: warna.onSurface,
              ),
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search products",
            hintStyle: TextStyle(
              color: warna.onSurface.withValues(alpha: 0.45),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: warna.onSurface.withValues(alpha: 0.55),
            ),
            /*
              Tombol bersihkan hanya muncul ketika ada isinya. Tanpa itu, satu-
              satunya cara mengosongkan pencarian adalah menghapus hurufnya satu
              per satu — di meja kasir, itu beberapa detik yang terjadi berkali-
              kali sehari.
            */
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _kendali,
              builder: (_, nilai, __) {
                if (nilai.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _bersihkan,
                  tooltip: "Clear",
                );
              },
            ),
            filled: true,
            fillColor: warna.onSurface.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: warna.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: warna.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: warna.primary, width: 1.6),
            ),
          ),
          onChanged: widget.onSearch,
        ),
      ),
    );
  }
}
