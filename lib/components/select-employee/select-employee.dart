import 'dart:async';

import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:flutter/material.dart';

/// Menanyakan kode karyawan sebelum sebuah tindakan dicatat atas namanya.
///
/// APA YANG SEBENARNYA DIKONFIRMASI DI SINI.
///
/// Kode ini bukan kata sandi: pemeriksaannya hanya pencocokan di basis data
/// setempat, tanpa jaringan dan tanpa rahasia. Gunanya menandai SIAPA yang
/// mencatat — dan begitu itu jelas, satu hal ikut jelas juga: yang harus
/// ditampilkan adalah NAMA orangnya.
///
/// Bentuk lama hanya memunculkan tanda centang kecil. Centang berarti "kode itu
/// ada", bukan "kode itu milik orang yang kamu maksud" — padahal salah ketik
/// satu huruf bisa menghasilkan kode karyawan lain yang juga sah, dan notanya
/// tercatat atas nama orang yang salah tanpa satu pun tanda. Sekarang namanya
/// yang muncul, dan itulah yang dibaca sebelum menekan lanjut.
///
/// Kode yang tidak ditemukan juga dulu tidak berkata apa-apa: centangnya tidak
/// muncul, tombolnya tetap mati, dan tidak ada yang menjelaskan kenapa.
class SelectEmployee extends StatefulWidget {
  const SelectEmployee({super.key});

  @override
  State<SelectEmployee> createState() => _SelectEmployeeState();
}

class _SelectEmployeeState extends State<SelectEmployee> {
  final TextEditingController _kodeController = TextEditingController();

  bool _sedangMemeriksa = false;
  bool _pernahDiperiksa = false;
  UserModel? _karyawan;

  Timer? _tunda;

  @override
  void dispose() {
    /*
      Keduanya dulu dibiarkan. Timer yang tidak dibatalkan tetap menyala
      sesudah dialognya ditutup, lalu memanggil setState pada State yang sudah
      dilepas.
    */
    _tunda?.cancel();
    _kodeController.dispose();
    super.dispose();
  }

  void _periksaKode(String kode) {
    _tunda?.cancel();

    final bersih = kode.trim();

    setState(() {
      _karyawan = null;
      _pernahDiperiksa = false;
    });

    if (bersih.length < 3) {
      setState(() => _sedangMemeriksa = false);
      return;
    }

    setState(() => _sedangMemeriksa = true);

    _tunda = Timer(const Duration(milliseconds: 400), () async {
      try {
        final hasil = await UserModel.fetchByCode(bersih.toUpperCase());
        if (!mounted) return;
        setState(() {
          _karyawan = hasil;
          _pernahDiperiksa = true;
        });
      } catch (error, jejak) {
        LoggerUtils().log(
          "Gagal memeriksa kode karyawan",
          LogType.error,
          error: error,
          stackTrace: jejak,
        );
        if (!mounted) return;
        setState(() => _pernahDiperiksa = true);
      } finally {
        if (mounted) {
          setState(() => _sedangMemeriksa = false);
        }
      }
    });
  }

  void _lanjut() {
    if (_karyawan == null) return;
    Navigator.of(context).pop(_karyawan);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    final ketemu = _karyawan != null;
    final tidakKetemu = _pernahDiperiksa && !_sedangMemeriksa && !ketemu;

    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: tema.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*
            Bilah judul ungu setinggi 80 piksel dibuang — sepertiga tinggi
            dialog dipakai satu baris judul, dan warnanya penuh, sehingga bagian
            paling mencolok adalah bagian yang tidak perlu dikerjakan siapa pun.
          */
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Who is recording this?",
                    style: tema.textTheme.headlineSmall,
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
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter your employee code so the bill is filed under your "
                  "name.",
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  autofocus: true,
                  controller: _kodeController,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: _periksaKode,
                  /*
                    Enter melanjutkan. Kode karyawan diketik puluhan kali sehari
                    dan tangannya sudah di papan ketik; memaksa pindah ke tetikus
                    untuk satu tombol adalah gerakan yang tidak perlu.
                  */
                  onFieldSubmitted: (_) => _lanjut(),
                  style: tema.textTheme.bodyLarge?.copyWith(
                    color: warna.onSurface,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: "AB12",
                    hintStyle: TextStyle(
                      color: warna.onSurface.withValues(alpha: 0.35),
                      letterSpacing: 2,
                    ),
                    filled: true,
                    fillColor: warna.onSurface.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    suffixIcon: _sedangMemeriksa
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: BorderSide(color: warna.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: BorderSide(
                        color: tidakKetemu ? warna.error : warna.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: BorderSide(
                        color: tidakKetemu ? warna.error : warna.primary,
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
                /*
                  Namanya, bukan centang. Inilah yang membuat kode yang salah
                  ketik tetapi kebetulan sah menjadi terlihat sebelum notanya
                  tercatat atas nama orang lain.
                */
                AnimatedSize(
                  duration: Gerak.cepat,
                  curve: Gerak.masuk,
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ketemu
                        ? Row(
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                size: 18,
                                color: warna.primary,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  _karyawan!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tema.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : tidakKetemu
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 18,
                                    color: warna.error,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      "No employee has that code",
                                      style: tema.textTheme.bodySmall?.copyWith(
                                        color: warna.error,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(width: double.infinity),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: ketemu ? _lanjut : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  /*
                    Dulu "Continue" dengan warna tulisan dipatok putih — di tema
                    gelap aksennya ungu muda, dan putih di atasnya hanya 3,4:1.
                    Sekarang temanya yang menentukan.
                  */
                  child: Text(
                      ketemu ? "Continue as ${_karyawan!.name}" : "Continue"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
