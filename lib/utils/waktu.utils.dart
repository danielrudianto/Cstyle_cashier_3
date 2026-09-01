import 'package:intl/intl.dart';

/// Waktu yang ditulis seperti orang menyebutnya.
///
/// DULU "01/09/2026".
///
/// Nota kasir hampir selalu dibuat hari ini, jadi tanggal lengkap dalam angka
/// mengulang hal yang sudah diketahui semua orang di ruangan itu — sambil
/// menyembunyikan satu-satunya bagian yang benar-benar membedakan satu nota
/// tertahan dari yang lain: JAMNYA.
///
/// Kasir menahan nota ketika pembeli pergi mengambil barang lain. Untuk
/// menemukannya kembali di antara enam nota tertahan, yang ditanyakan bukan
/// tanggalnya — semuanya hari ini — melainkan "yang tadi, sekitar setengah jam
/// lalu". Jadi jam yang ditonjolkan, dan tanggalnya baru muncul ketika ia
/// memang bukan hari ini.
String waktuManusiawi(DateTime waktu) {
  final sekarang = DateTime.now();
  final jam = DateFormat("HH:mm").format(waktu);

  if (_hariYangSama(waktu, sekarang)) {
    return "Today, $jam";
  }

  if (_hariYangSama(waktu, sekarang.subtract(const Duration(days: 1)))) {
    return "Yesterday, $jam";
  }

  /*
    Tahun disebut hanya bila berbeda. Menuliskan "2026" pada nota yang dibuat
    tahun ini menambah empat angka yang tidak pernah membedakan apa pun.
  */
  if (waktu.year == sekarang.year) {
    return "${DateFormat("d MMM").format(waktu)}, $jam";
  }

  return "${DateFormat("d MMM yyyy").format(waktu)}, $jam";
}

bool _hariYangSama(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
