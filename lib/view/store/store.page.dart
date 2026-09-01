import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/model/model.countries.dart';
import 'package:cstyle_cashier_3/model/model.daily-report.model.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/view/check-stock/check-stock.page.dart';
import 'package:cstyle_cashier_3/view/history/history.page.dart';
import 'package:cstyle_cashier_3/view/member-list/member-list.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/create-stock-transfer/create-stock-transfer.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/list-stock-transfer/list-stock-transfer.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/receive-stock-transfer/receive-stock-transfer.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/send-stock-transfer/send-stock.transfer.page.dart';
import 'package:cstyle_cashier_3/view/store/components/store-dashboard.dart';
import 'package:flag/flag.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

// ignore: camel_case_types
enum language {
  // ignore: constant_identifier_names
  EN,
  // ignore: constant_identifier_names
  ID,
}

class _StorePageState extends State<StorePage> {
  int selectedMenu = 0;
  bool isLoading = false;

  Future<void> fetchByCode(String code) async {
    setState(() {
      isLoading = true;
    });
    try {
      var member = await MemberModel.fetchByCode(code);
      if (member != null) {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Code",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.code,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Name",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Nationality",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.nationality ?? "N/A",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Email",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Text(
                              member.email == "" ? "N/A" : member.email,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Copy",
                            onPressed: () {},
                            icon: const Icon(
                              Icons.copy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Phone",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Text(
                              member.phoneNumber == ""
                                  ? "N/A"
                                  : member.phoneNumber,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Copy",
                            onPressed: () {},
                            icon: const Icon(
                              Icons.copy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Birthday",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.birthday == null
                            ? "N/A"
                            : DateFormat("dd/MM/yyyy").format(member.birthday!),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      } else {}
    } catch (error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  preOpenAddMember() {
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
        openAddMember(value.id);
      }
    });
  }

  openAddMember(String userID) {
    TextEditingController codeEditingController = TextEditingController();
    TextEditingController nameEditingController = TextEditingController();
    TextEditingController memberNationalityController = TextEditingController();
    TextEditingController memberEmailController = TextEditingController();
    TextEditingController memberPhoneNumberController = TextEditingController();
    TextEditingController memberBirthdayController = TextEditingController();
    CountryModel? nationality;
    language? selectedLanguage = language.ID;
    bool isSubmitting = false;

    addMember() async {
      setState(() {
        isSubmitting = true;
      });

      try {
        if (codeEditingController.text.isEmpty) {
          throw Exception("Code cannot be empty");
        }

        if (nameEditingController.text.isEmpty) {
          throw Exception("Name cannot be empty");
        }

        if (memberEmailController.text.isEmpty &&
            memberPhoneNumberController.text.isEmpty) {
          throw Exception(
              "Please insert either phone number or email, or both.");
        }

        var member = MemberModel(
          code: codeEditingController.text,
          name: nameEditingController.text,
          nationality: nationality?.code,
          email: memberEmailController.text,
          phoneNumber: memberPhoneNumberController.text,
          birthday: DateTime.now(),
          lang: selectedLanguage!,
          points: 0,
          createdBy: userID,
        );

        await member.create();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully created member"),
            duration: Duration(seconds: 1),
            showCloseIcon: true,
          ),
        );
        Navigator.pop(context);
      } catch (error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    }

    showDialog(
        /*
          DULU false, JADI ESCAPE TIDAK MELAKUKAN APA-APA.

          barrierDismissible mengatur dua hal sekaligus: klik di luar dialog
          DAN tombol Escape — ModalRoute hanya melayani DismissIntent kalau
          nilainya benar. Dengan false, satu-satunya jalan keluar adalah
          tanda silang di pojok, dan tidak ada apa pun di layar yang
          memberitahukan itu.

          Pengikatan Escape di bawah dipasang juga, bukan karena yang ini
          kurang, melainkan supaya tetap bekerja bila dialognya kelak dibuka
          lewat jalur lain yang tidak melewati barrier.
        */
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () =>
                    Navigator.of(context).pop(),
              },
              child: Focus(
                autofocus: true,
                child: Dialog(
                  surfaceTintColor: Theme.of(context).cardColor,
                  backgroundColor: Theme.of(context).cardColor,
                  child: SizedBox(
                    width: 400,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /*
                        BILAH JUDUL UNGU SETINGGI 100 PIKSEL DIBUANG.

                        Seperempat tinggi dialog dipakai satu baris judul, dan
                        warnanya penuh — jadi hal paling mencolok pada formulir
                        pendaftaran anggota adalah kata "Create new member",
                        yang justru satu-satunya bagian yang tidak perlu
                        dikerjakan siapa pun.

                        Kepala dialog sekarang duduk di permukaan yang sama
                        dengan isinya, dan satu-satunya warna di sini tinggal
                        tombol kirimnya.
                      */
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 12, 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "New member",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
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
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*
                              DELAPAN MEDAN BERDERET RATA MENJADI TIGA BAGIAN.

                              Sebelumnya kode, nama, kebangsaan, telepon,
                              surel, ulang tahun, dan bahasa struk berdiri
                              berurutan dengan jarak yang sama persis — jadi
                              yang wajib diisi terlihat sama pentingnya dengan
                              yang boleh dilewati, dan tidak ada yang
                              menyatakan bahwa telepon dan surel saling
                              menggantikan.

                              Judul bagiannya memakai perlakuan yang sama
                              dengan kepala kolom tabel dan menu kelola.
                            */
                                /* Judul bagian; lihat catatan di bawah. */
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    "MEMBER",
                                    style: gayaLabelKolom(context),
                                  ),
                                ),
                                TextFormField(
                                  controller: codeEditingController,
                                  decoration: InputDecoration(
                                    label: Text(
                                      "Code",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    /*
                                  Dulu keduanya dividerColor. Sejak pemisah
                                  diturunkan menjadi 7% supaya garis antarbaris
                                  tidak berteriak, nilai itu terlalu samar untuk
                                  menandai TEPI kolom isian — dan garis fokusnya
                                  sama persis dengan yang tidak fokus, jadi tidak
                                  ada tanda kolom mana yang sedang diketik.
                                */
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: nameEditingController,
                                  decoration: InputDecoration(
                                    label: Text(
                                      "Name",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    /*
                                  Dulu keduanya dividerColor. Sejak pemisah
                                  diturunkan menjadi 7% supaya garis antarbaris
                                  tidak berteriak, nilai itu terlalu samar untuk
                                  menandai TEPI kolom isian — dan garis fokusnya
                                  sama persis dengan yang tidak fokus, jadi tidak
                                  ada tanda kolom mana yang sedang diketik.
                                */
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Autocomplete<CountryModel>(
                                  displayStringForOption:
                                      (CountryModel option) =>
                                          "${option.name} (${option.code})",
                                  initialValue: TextEditingValue(
                                      text: (nationality != null)
                                          ? "${nationality!.name} (${nationality!.code})"
                                          : ""),
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          fieldTextEditingController,
                                      FocusNode fieldFocusNode,
                                      VoidCallback onFieldSubmitted) {
                                    memberNationalityController =
                                        fieldTextEditingController;
                                    return TextField(
                                      controller: fieldTextEditingController,
                                      focusNode: fieldFocusNode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      enabled: (nationality == null),
                                      decoration: InputDecoration(
                                        label: Text(
                                          "Nationality",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text == '') {
                                      return const Iterable<
                                          CountryModel>.empty();
                                    }

                                    return availableCountries
                                        .where((CountryModel option) {
                                      return option.name.toLowerCase().contains(
                                              textEditingValue.text
                                                  .toLowerCase()) ||
                                          option.name.toLowerCase().startsWith(
                                              textEditingValue.text
                                                  .toLowerCase());
                                    });
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      AutocompleteOnSelected<CountryModel>
                                          onSelected,
                                      Iterable<CountryModel> options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        child: Container(
                                          width: 370,
                                          color: Theme.of(context).canvasColor,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.all(10.0),
                                            itemCount: options.length >= 5
                                                ? 5
                                                : options.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final CountryModel option =
                                                  options.elementAt(index);
                                              return GestureDetector(
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: ListTile(
                                                    title: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "${option.name} (${option.code})",
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Flag.fromString(
                                                          option.code,
                                                          height: 20,
                                                          width: 30,
                                                          fit: BoxFit.fill,
                                                          replacement:
                                                              const SizedBox(
                                                            height: 0,
                                                            width: 0,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onSelected: (value) {
                                    setState(() {
                                      nationality = value;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                /*
                              Hanya muncul ketika ada yang bisa dihapus. Dulu
                              ia selalu ada — tombol mati seukuran tulisan biasa
                              menggantung di bawah kolom kebangsaan, yang lebih
                              sering terbaca sebagai bagian dari formulir
                              daripada sebagai tindakan.
                            */
                                if (nationality != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          nationality = null;
                                          memberNationalityController.text = "";
                                        });
                                      },
                                      icon: const Icon(Icons.close, size: 15),
                                      label: const Text("Clear nationality"),
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 5,
                                ),
                                /* Judul bagian; lihat catatan di bawah. */
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 22,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    "CONTACT",
                                    style: gayaLabelKolom(context),
                                  ),
                                ),
                                TextFormField(
                                  controller: memberPhoneNumberController,
                                  decoration: InputDecoration(
                                    label: Text(
                                      "Phone number",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    /*
                                  Dulu keduanya dividerColor. Sejak pemisah
                                  diturunkan menjadi 7% supaya garis antarbaris
                                  tidak berteriak, nilai itu terlalu samar untuk
                                  menandai TEPI kolom isian — dan garis fokusnya
                                  sama persis dengan yang tidak fokus, jadi tidak
                                  ada tanda kolom mana yang sedang diketik.
                                */
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: memberEmailController,
                                  decoration: InputDecoration(
                                    label: Text(
                                      "Email",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    /*
                                  Dulu keduanya dividerColor. Sejak pemisah
                                  diturunkan menjadi 7% supaya garis antarbaris
                                  tidak berteriak, nilai itu terlalu samar untuk
                                  menandai TEPI kolom isian — dan garis fokusnya
                                  sama persis dengan yang tidak fokus, jadi tidak
                                  ada tanda kolom mana yang sedang diketik.
                                */
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                /*
                              Ini keterangan pendamping dua kolom di atasnya,
                              bukan kalimat tersendiri — dulu ditulis sebesar
                              isian yang dijelaskannya.
                            */
                                Text(
                                  "Fill in a phone number or an email — either one "
                                  "is enough.",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                /* Judul bagian ketiga; semuanya boleh dilewati. */
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 22,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    "DETAILS",
                                    style: gayaLabelKolom(context),
                                  ),
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    label: Text(
                                      "Birthday",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    /*
                                  Dulu keduanya dividerColor. Sejak pemisah
                                  diturunkan menjadi 7% supaya garis antarbaris
                                  tidak berteriak, nilai itu terlalu samar untuk
                                  menandai TEPI kolom isian — dan garis fokusnya
                                  sama persis dengan yang tidak fokus, jadi tidak
                                  ada tanda kolom mana yang sedang diketik.
                                */
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    var firstDate = DateTime.now();
                                    var lastDate = DateTime.now();

                                    firstDate = DateTime(firstDate.year - 100);
                                    lastDate = DateTime(lastDate.year - 18);
                                    showDatePicker(
                                            // container color
                                            builder: (context, child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? ColorScheme.dark(
                                                          surface:
                                                              Theme.of(context)
                                                                  .canvasColor,
                                                        )
                                                      : ColorScheme.light(
                                                          surface:
                                                              Theme.of(context)
                                                                  .canvasColor,
                                                        ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Theme.of(
                                                              context)
                                                          .secondaryHeaderColor,
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                            context: context,
                                            firstDate: firstDate,
                                            lastDate: lastDate)
                                        .then((value) {
                                      if (value == null) {
                                        return;
                                      } else {
                                        memberBirthdayController.text =
                                            DateFormat("dd/MM/yyyy")
                                                .format(value);
                                      }
                                    }).catchError((error) {
                                      LoggerUtils()
                                          .log(error.toString(), LogType.error);
                                    });
                                  },
                                  controller: memberBirthdayController,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                /*
                              DUA RadioListTile MENJADI SATU BARIS BERLABEL.

                              Keduanya dulu berdiri tanpa judul apa pun, jadi
                              "English" dan "Bahasa" muncul di ujung formulir
                              tanpa menyebutkan bahasa APA yang sedang dipilih —
                              bahasa aplikasinya, atau bahasa struknya. Yang
                              benar yang kedua, dan sekarang tertulis.

                              Bentuknya disamakan dengan pemilih tema di halaman
                              setelan: dua pilihan tetap, muat dalam satu baris.
                            */
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    "RECEIPT LANGUAGE",
                                    style: gayaLabelKolom(context),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _SegmenBahasa(
                                          label: "English",
                                          aktif:
                                              selectedLanguage == language.EN,
                                          onTekan: () => setState(
                                            () =>
                                                selectedLanguage = language.EN,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        _SegmenBahasa(
                                          label: "Bahasa",
                                          aktif:
                                              selectedLanguage == language.ID,
                                          onTekan: () => setState(
                                            () =>
                                                selectedLanguage = language.ID,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                RadioListTile<language>(
                                    title: Text(
                                      "Bahasa",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    groupValue: selectedLanguage,
                                    value: language.ID,
                                    activeColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLanguage = value;
                                      });
                                    }),
                                const SizedBox(
                                  height: 15,
                                ),
                                InkWell(
                                  onTap: isSubmitting
                                      ? null
                                      : () {
                                          addMember();
                                        },
                                  child: Container(
                                    padding: EdgeInsets.zero,
                                    width: double.infinity,
                                    /*
                                  Dulu Container berwarna aksen yang menyerupai
                                  tombol: tanpa sorot, tanpa umpan balik tekan,
                                  tanpa kursor tangan — dan saat sedang mengirim
                                  ia hanya berubah abu-abu tanpa memberi tahu
                                  bahwa sesuatu sedang berjalan.

                                  "Submit" juga tidak menyebutkan apa pun.
                                  Tombol sebaiknya menamai hasilnya.
                                */
                                    child: IgnorePointer(
                                      child: FilledButton(
                                        onPressed: isSubmitting ? null : () {},
                                        style: FilledButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(46),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                        ),
                                        child: isSubmitting
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.2,
                                                ),
                                              )
                                            : const Text("Create member"),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  /// Nama toko untuk kepala laporan yang disalin.
  ///
  /// Diambil sekali saat laporan dibuka, bukan disimpan sebagai keadaan: ia
  /// hanya dipakai di satu tempat, dan mengambilnya di sini membuat jelas dari
  /// mana asalnya.
  String _namaToko = "";

  openDailyReport() async {
    final toko = await StoreModel.getCurrentProfile();
    _namaToko = toko?.name ?? "";

    if (!mounted) return;

    DailyReportModel.downloadDailyReport().then((value) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                height: 620,
                width: 480,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        // border width 0
                        border: Border.all(
                          width: 0,
                          color: Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Daily Report",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Close",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Date",
                                style: Theme.of(context).textTheme.labelSmall,
                                textScaler: const TextScaler.linear(1.1),
                              ),
                              Text(
                                DateFormat("dd/MM/yyyy").format(DateTime.now()),
                                style: Theme.of(context).textTheme.bodyLarge,
                                textScaler: const TextScaler.linear(1.1),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Sales : Rp. ${NumberFormat("#,##0.00").format(value['payments'].fold(
                                  0,
                                  (previousValue, element) =>
                                      previousValue + element['value'],
                                ))}",
                                style: Theme.of(context).textTheme.bodyLarge,
                                textScaler: const TextScaler.linear(1.1),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: value['payments'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      value['payments'][index]['type']
                                          .toString()
                                          .toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                      textScaler: const TextScaler.linear(1.1),
                                    ),
                                    subtitle: Text(
                                      NumberFormat("#,##0.00").format(
                                          value['payments'][index]['value']),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textScaler: const TextScaler.linear(1.1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(
                        15,
                      ),
                      child: Row(children: [
                        const Spacer(),
                        /*
                          TEKS YANG DISALIN DITUJUKAN UNTUK WHATSAPP.

                          Bentuk lama hanya memuat jenis pembayaran dan
                          totalnya — tanpa nama toko dan tanpa tanggal. Yang
                          menerimanya di grup melihat deretan angka tanpa tahu
                          itu dari toko mana atau hari apa, dan begitu ada dua
                          toko mengirim pada hari yang sama, keduanya tidak
                          bisa dibedakan lagi.

                          Bintang tunggal di sekitar judul dibaca WhatsApp
                          sebagai tebal, jadi barisnya menonjol di dalam
                          percakapan. Di aplikasi lain ia tetap terbaca sebagai
                          bintang biasa, dan itu tidak merugikan.

                          Rupiah tanpa sen: dua angka nol yang selalu sama
                          hanya memanjangkan pesan yang dibaca di layar telepon.
                        */
                        InkWell(
                          onTap: () {
                            final rupiah = NumberFormat("#,##0");
                            final namaToko = _namaToko;
                            final tanggal = DateFormat("d MMMM yyyy")
                                .format(DateTime.now());

                            final baris = <String>[
                              "*Daily report*",
                              if (namaToko.isNotEmpty) namaToko,
                              tanggal,
                              "",
                            ];

                            num total = 0.0;
                            for (var item in value['payments']) {
                              final jenis =
                                  item['type'].toString().toUpperCase();
                              baris.add(
                                "$jenis : Rp ${rupiah.format(item['value'])}",
                              );
                              total += item['value'];
                            }

                            baris.add("");
                            baris.add("*Total : Rp ${rupiah.format(total)}*");

                            Clipboard.setData(
                              ClipboardData(text: baris.join("\n")),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Report copied — paste it into WhatsApp",
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_all_outlined,
                                  size: 17,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Copy for WhatsApp",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          });
    }).catchError((error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget get currentPage {
    switch (selectedMenu) {
      case 0:
        return StoreDashboard(onLaporanHarian: openDailyReport);
      case 1:
        return const MemberListPage();
      case 2:
        return const CreateStockTransferPage();
      case 3:
        return const SendStockTransferPage();
      case 4:
        return const ReceiveStockTransferPage();
      case 5:
        return const ListStockTransfer();
      case 6:
        return const CheckStockPage();
      case 7:
        return const HistoryPage();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return Scaffold(
      /*
        Transparan: gradien permukaan kerja dilukis di akar halaman utama, dan
        latar Scaffold yang buram akan menutupinya. Lihat pageview.page.dart.
      */
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              10,
            ),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  /* Dulu grey.shade300; garis terang di atas latar gelap. */
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
              ),
              color: Theme.of(context).cardColor,
            ),
            width: 250,
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  /*
                    DULU 250 BARIS ListTile YANG DISALIN-TEMPEL.

                    Sebelas butir, masing-masing menuliskan sendiri gaya
                    tulisannya, warna ikonnya, dan pemeriksaan terpilihnya —
                    jadi setiap penyesuaian kecil harus dikerjakan sebelas
                    kali, dan yang terlewat menyimpang diam-diam. Judul
                    bagiannya pun berupa ListTile, sehingga "Memberships"
                    punya tinggi dan jarak yang sama persis dengan butir yang
                    bisa ditekan: dari bentuknya tidak ada yang membedakan
                    judul dari isinya.
                  */
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: [
                      _ButirMenu(
                        ikon: Icons.dashboard_outlined,
                        label: "Home",
                        aktif: selectedMenu == 0,
                        onTekan: () => setState(() => selectedMenu = 0),
                      ),
                      const _LabelBagian("MEMBERSHIPS"),
                      _ButirMenu(
                        ikon: Icons.person_add_alt,
                        label: "Add member",
                        aktif: false,
                        onTekan: () => preOpenAddMember(),
                      ),
                      _ButirMenu(
                        ikon: Icons.groups_outlined,
                        label: "View members",
                        aktif: selectedMenu == 1,
                        onTekan: () => setState(() => selectedMenu = 1),
                      ),
                      const _LabelBagian("INVENTORY"),
                      _ButirMenu(
                        ikon: Icons.add_box_outlined,
                        label: "Create transfer",
                        aktif: selectedMenu == 2,
                        onTekan: () => setState(() => selectedMenu = 2),
                      ),
                      _ButirMenu(
                        ikon: Icons.call_made,
                        label: "Send transfer",
                        aktif: selectedMenu == 3,
                        onTekan: () => setState(() => selectedMenu = 3),
                      ),
                      _ButirMenu(
                        ikon: Icons.call_received,
                        label: "Receive transfer",
                        aktif: selectedMenu == 4,
                        onTekan: () => setState(() => selectedMenu = 4),
                      ),
                      _ButirMenu(
                        /* Dulu berjudul "List", yang tidak menyebut daftar apa. */
                        ikon: Icons.list_alt_outlined,
                        label: "Transfer list",
                        aktif: selectedMenu == 5,
                        onTekan: () => setState(() => selectedMenu = 5),
                      ),
                      const _LabelBagian("UTILITIES"),
                      /*
                        "Daily report" DIPINDAH KE HALAMAN HOME.

                        Ia satu-satunya butir di menu ini yang tidak membuka
                        halaman melainkan memunculkan dialog, jadi ia tidak
                        pernah bisa tampil terpilih seperti tetangganya —
                        setengah menu, setengah tombol. Tempatnya di Home,
                        bersama tindakan lain yang dijalankan lalu selesai.
                      */
                      _ButirMenu(
                        ikon: Icons.inventory_2_outlined,
                        label: "Stock list",
                        aktif: selectedMenu == 6,
                        onTekan: () => setState(() => selectedMenu = 6),
                      ),
                      _ButirMenu(
                        ikon: Icons.history,
                        label: "History",
                        aktif: selectedMenu == 7,
                        onTekan: () => setState(() => selectedMenu = 7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RawScrollbar(
              controller: scrollController,
              thumbColor: Theme.of(context).secondaryHeaderColor,
              radius: const Radius.circular(8.0),
              thickness: 8.0,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: ResponsiveUtils.getContainerSize(context),
                      maxWidth: ResponsiveUtils.getContainerSize(context),
                      minHeight: MediaQuery.of(context).size.height - 100,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        child: currentPage,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul bagian pada menu kelola.
///
/// Sekeluarga dengan kepala kolom tabel barang dan label penyaring di layar
/// jual: kecil, jarak antarhuruf dilebarkan, diredupkan. Ketiganya memberi nama
/// pada sekumpulan hal, bukan menjadi salah satunya.
///
/// Sebelumnya judul di sini berupa ListTile ber-headlineSmall — dua puluh
/// piksel, tebal, dengan tinggi dan jarak yang sama persis dengan butir yang
/// dijudulinya. Judul yang lebih besar daripada isinya membalik urutan baca:
/// mata jatuh ke "MEMBERSHIPS" lebih dulu, bukan ke pilihan yang dicari.
class _LabelBagian extends StatelessWidget {
  final String teks;

  const _LabelBagian(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(teks, style: gayaLabelKolom(context)),
    );
  }
}

/// Satu butir pada menu kelola.
///
/// Yang terpilih ditandai TIGA hal sekaligus: latar beraksen, batang aksen di
/// tepi kiri, dan tulisan tebal. Sebelumnya hanya warna tulisannya yang berubah,
/// dan warna sendirian adalah penanda paling lemah yang ada — ia hilang bagi
/// mata yang sulit membedakan warna, dan pada ungu di atas latar gelap bedanya
/// dengan tulisan biasa memang tipis.
///
/// Butir yang menjalankan tindakan sekali jalan — "Add member", "Daily report" —
/// tidak pernah bertanda aktif, karena ia memang tidak menjadi halaman.
class _ButirMenu extends StatefulWidget {
  final IconData ikon;
  final String label;
  final bool aktif;
  final VoidCallback onTekan;

  const _ButirMenu({
    required this.ikon,
    required this.label,
    required this.aktif,
    required this.onTekan,
  });

  @override
  State<_ButirMenu> createState() => _ButirMenuState();
}

class _ButirMenuState extends State<_ButirMenu> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final aksen = tema.secondaryHeaderColor;

    final Color latar = widget.aktif
        ? aksen.withValues(alpha: 0.14)
        : (_disorot
            ? warna.onSurface.withValues(alpha: 0.06)
            : Colors.transparent);

    final Color depan = widget.aktif
        ? aksen
        : warna.onSurface.withValues(alpha: _disorot ? 0.95 : 0.72);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.aktif ? null : widget.onTekan,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
          decoration: BoxDecoration(
            color: latar,
            borderRadius: BorderRadius.circular(7),
            border: Border(
              left: BorderSide(
                color: widget.aktif ? aksen : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(widget.ikon, size: 18, color: depan),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: depan,
                    fontSize: 14,
                    fontWeight:
                        widget.aktif ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu pilihan bahasa struk pada formulir anggota.
///
/// Bentuknya sengaja sama dengan pemilih tema di halaman setelan: dua atau tiga
/// pilihan tetap yang saling meniadakan, muat dalam satu baris. Radio selebar
/// dialog untuk dua pilihan menghabiskan seratus piksel dan menyatakan bahwa
/// daftarnya bisa bertambah panjang, padahal tidak.
class _SegmenBahasa extends StatefulWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTekan;

  const _SegmenBahasa({
    required this.label,
    required this.aktif,
    required this.onTekan,
  });

  @override
  State<_SegmenBahasa> createState() => _SegmenBahasaState();
}

class _SegmenBahasaState extends State<_SegmenBahasa> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    final Color latar = widget.aktif
        ? warna.primary
        : (_disorot
            ? warna.onSurface.withValues(alpha: 0.07)
            : Colors.transparent);

    final Color depan = widget.aktif
        ? warna.onPrimary
        : warna.onSurface.withValues(alpha: _disorot ? 0.92 : 0.62);

    return MouseRegion(
      cursor: widget.aktif ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.aktif ? null : widget.onTekan,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: latar,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            widget.label,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: depan,
              fontSize: 13,
              fontWeight: widget.aktif ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
