import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilihan tema pengguna, disimpan di SharedPreferences.
///
/// PILIHAN "IKUT SISTEM" DULU MUSTAHIL BERTAHAN.
///
/// Bentuk lama memuat baris ini:
///
///     if (ThemeMode.system == ThemeMode.dark) { ... } else { setLightScheme(); }
///
/// Yang dibandingkan dua tetapan enum, bukan kecerahan perangkat — nilainya
/// SELALU false. Jadi cabang yang dijalankan selalu `setLightScheme()`, dan
/// `setLightScheme()` bukan hanya menyetel, ia juga MENYIMPAN "ThemeMode.light"
/// ke SharedPreferences.
///
/// Akibatnya: pada peluncuran pertama, pengguna yang belum pernah memilih apa
/// pun langsung terkunci ke tema terang secara permanen. Windows bertema gelap
/// pun tidak berpengaruh, dan tidak ada cara kembali ke "ikut sistem" karena
/// tidak ada yang pernah menulis nilai itu.
///
/// Sekarang: pemuatan hanya MEMBACA, penyimpanan hanya terjadi saat pengguna
/// benar-benar memilih. Membaca preferensi tidak boleh mengubahnya — itu yang
/// membuat cacat di atas berubah dari sesaat menjadi permanen.
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// Sudah dimuat dari penyimpanan, supaya tidak diulang tiap build.
  bool _sudahDimuat = false;

  /// Menyimpan pilihan pengguna. Hanya dipanggil dari tindakan pengguna.
  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value.toString());
  }

  Future<void> setDarkScheme() => setThemeMode(ThemeMode.dark);

  Future<void> setLightScheme() => setThemeMode(ThemeMode.light);

  /// Mengikuti kecerahan sistem operasi.
  ///
  /// Ini yang dikembalikan; sebelumnya tidak ada jalan menuju keadaan ini.
  Future<void> setSystemScheme() => setThemeMode(ThemeMode.system);

  /// Membaca pilihan yang tersimpan.
  ///
  /// TIDAK menulis apa pun. Bila belum pernah ada pilihan, hasilnya
  /// ThemeMode.system dan MaterialApp yang menentukan terang atau gelap dari
  /// kecerahan perangkat — memang itu gunanya ThemeMode.system, dan tidak
  /// perlu ditebak sendiri di sini.
  Future<void> loadThemeMode() async {
    /*
      Dipanggil dari build(), yang bisa berjalan berkali-kali. Tanpa penjaga
      ini tiap build memicu satu pembacaan SharedPreferences dan satu
      notifyListeners() lagi.
    */
    if (_sudahDimuat) return;
    _sudahDimuat = true;

    final prefs = await SharedPreferences.getInstance();
    final tersimpan = prefs.getString('theme');

    if (tersimpan == ThemeMode.dark.toString()) {
      _themeMode = ThemeMode.dark;
    } else if (tersimpan == ThemeMode.light.toString()) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }
}
