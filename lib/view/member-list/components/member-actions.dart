import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Apa yang bisa dikerjakan terhadap satu anggota.
///
/// DULU 172 BARIS ListTile YANG DISALIN-TEMPEL DI DALAM member-list.page.dart.
///
/// Empat tindakan, masing-masing menuliskan sendiri warna ikonnya, gaya
/// tulisannya, dan pemeriksaan kosongnya — dan salinannya sudah menyimpang:
/// "Copy code" diredupkan berdasarkan `e.email == ""`, bidang yang salah, jadi
/// anggota tanpa surel membuat tombol salin KODE terlihat mati padahal kodenya
/// selalu ada.
///
/// KATA-KATANYA JUGA DIPERBAIKI.
///
/// Yang paling penting: lembarannya dulu terbuka TANPA MENYEBUT SIAPA. Sesudah
/// menekan satu baris di antara dua puluh nama yang mirip, hal pertama yang
/// perlu dipastikan adalah bahwa yang terbuka memang orang yang dimaksud —
/// dan tidak ada satu pun yang menyebutkannya.
///
/// Lalu label tindakannya. "Copy email" tidak mengatakan surel yang mana, jadi
/// yang menekannya baru tahu apa yang disalin sesudah menempelkannya. Sekarang
/// nilainya ikut tertulis di bawah labelnya, dan tindakan yang tidak mungkin
/// dikerjakan menyebutkan sebabnya — "No email on file" — alih-alih sekadar
/// tampil redup tanpa keterangan.
///
/// Dan pesan setelahnya. "Successfully copied email." dibuka dengan kata yang
/// tidak menambah apa-apa; yang ingin dibaca sekilas adalah "Email copied".
class MemberActions extends StatelessWidget {
  final MemberModel anggota;

  const MemberActions({super.key, required this.anggota});

  static const String bukaDetail = "detail";

  void _salin(BuildContext context, String nilai, String apa) {
    Clipboard.setData(ClipboardData(text: nilai));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("$apa copied"),
          duration: const Duration(seconds: 1),
        ),
      );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final adaSurel = anggota.email.trim().isNotEmpty;
    final adaTelepon = anggota.phoneNumber.trim().isNotEmpty;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
            Kepala lembaran menyebut siapa yang sedang dikerjakan. Tanpa ini,
            menekan baris yang salah baru ketahuan sesudah menyalin nomor orang
            lain.
          */
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              anggota.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.headlineSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(anggota.code, style: gayaLabelKolom(context)),
          ),
          Divider(height: 1, color: tema.dividerColor),
          _Tindakan(
            ikon: Icons.alternate_email,
            label: "Copy email",
            nilai: adaSurel ? anggota.email : "No email on file",
            aktif: adaSurel,
            onTekan: () => _salin(context, anggota.email, "Email"),
          ),
          _Tindakan(
            ikon: Icons.phone_outlined,
            label: "Copy phone number",
            nilai: adaTelepon ? anggota.phoneNumber : "No phone number on file",
            aktif: adaTelepon,
            onTekan: () => _salin(context, anggota.phoneNumber, "Phone number"),
          ),
          _Tindakan(
            /*
              Selalu tersedia. Dulu ia ikut diredupkan ketika surel kosong —
              pemeriksaan yang tersalin dari tindakan di atasnya.
            */
            ikon: Icons.badge_outlined,
            label: "Copy member code",
            nilai: anggota.code,
            aktif: true,
            onTekan: () => _salin(context, anggota.code, "Member code"),
          ),
          Divider(height: 1, color: tema.dividerColor),
          _Tindakan(
            ikon: Icons.open_in_new,
            label: "Open member details",
            nilai: "Points, birthday and contact",
            aktif: true,
            onTekan: () => Navigator.of(context).pop(bukaDetail),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Satu baris tindakan pada lembaran anggota.
class _Tindakan extends StatefulWidget {
  final IconData ikon;
  final String label;
  final String nilai;
  final bool aktif;
  final VoidCallback onTekan;

  const _Tindakan({
    required this.ikon,
    required this.label,
    required this.nilai,
    required this.aktif,
    required this.onTekan,
  });

  @override
  State<_Tindakan> createState() => _TindakanState();
}

class _TindakanState extends State<_Tindakan> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    final Color depan = widget.aktif
        ? warna.onSurface.withValues(alpha: _disorot ? 1 : 0.88)
        : warna.onSurface.withValues(alpha: 0.35);

    return MouseRegion(
      cursor:
          widget.aktif ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.aktif ? widget.onTekan : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          color: _disorot && widget.aktif
              ? warna.onSurface.withValues(alpha: 0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Row(
            children: [
              Icon(widget.ikon, size: 19, color: depan),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: depan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    /*
                      Nilainya ikut tertulis. "Copy email" tidak mengatakan
                      surel yang mana, jadi yang menekannya baru tahu apa yang
                      disalin sesudah menempelkannya.
                    */
                    Text(
                      widget.nilai,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
