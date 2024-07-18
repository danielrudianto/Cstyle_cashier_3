import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/clip-path/trapezoid.clip-path.dart';
import 'package:cstyle_cashier_3/view/compare/components/product-image.component.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  TextEditingController noteController1 = TextEditingController();
  TextEditingController noteController2 = TextEditingController();
  TextEditingController noteController3 = TextEditingController();

  int? prefered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.share),
      ),
      body: Consumer<CompareNotifier>(builder: (_, value, __) {
        return SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ClipPath(
                clipper: TrapezoidClipPath(),
                child: Container(
                  width: double.infinity,
                  color: Color.fromARGB(255, 211, 212, 253),
                  height: 500,
                ),
              ),
              ClipPath(
                clipper: InversedTrapezoidClipPath(),
                child: Container(
                  width: double.infinity,
                  color: Color.fromARGB(180, 124, 136, 248),
                  height: 500,
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getContainerSize(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              router.pop();
                            }),
                        Text(
                          "Compare products",
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 30, 73),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // Radius 10
                        borderRadius: BorderRadius.circular(10),
                        // elevation
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi! Here are your products to compare. Please note that this feature is only available for 2 - 3 products at a time. You can also share this table via Whatsapp application using the share button on the top right corner.",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width:
                                    ResponsiveUtils.getContainerSize(context) -
                                        40,
                                child: value.selectedComparisson.length == 3
                                    ? Table(
                                        // Border horizontal only black12
                                        border: const TableBorder(
                                          horizontalInside: BorderSide(
                                            color: Colors.black12,
                                            width: 1,
                                          ),
                                          verticalInside: BorderSide(
                                            color: Colors.transparent,
                                            width: 1,
                                          ),
                                          top: BorderSide(
                                            color: Colors.transparent,
                                            width: 1,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                        columnWidths: const <int,
                                            TableColumnWidth>{
                                          0: FlexColumnWidth(1),
                                          1: FlexColumnWidth(1),
                                          2: FlexColumnWidth(1),
                                          3: FlexColumnWidth(1),
                                        },
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: <TableRow>[
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Product name",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              0]
                                                          .reference,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              0]
                                                          .description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              1]
                                                          .reference,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              1]
                                                          .description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              2]
                                                          .reference,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              1]
                                                          .description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Images",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: ProductImageComponent(
                                                      autoPlay: false,
                                                      id: value
                                                          .selectedComparisson[
                                                              0]
                                                          .id),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: ProductImageComponent(
                                                      autoPlay: false,
                                                      id: value
                                                          .selectedComparisson[
                                                              1]
                                                          .id),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: ProductImageComponent(
                                                      autoPlay: false,
                                                      id: value
                                                          .selectedComparisson[
                                                              2]
                                                          .id),
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Brand",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[0]
                                                      .brand,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[1]
                                                      .brand,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[2]
                                                      .brand,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Type",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[0]
                                                      .type,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[1]
                                                      .type,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[2]
                                                      .type,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Price",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  NumberFormat.decimalPattern()
                                                      .format(value
                                                          .selectedComparisson[
                                                              0]
                                                          .price),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  NumberFormat.decimalPattern()
                                                      .format(value
                                                          .selectedComparisson[
                                                              1]
                                                          .price),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  NumberFormat.decimalPattern()
                                                      .format(value
                                                          .selectedComparisson[
                                                              2]
                                                          .price),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("Notes"),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: noteController1,
                                                  // Decoration
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    // hint note
                                                    hintText: "Notes",
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: noteController2,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    // hint note
                                                    hintText: "Notes",
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: noteController3,
                                                  // Decoration
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    // hint note
                                                    hintText: "Notes",
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("Status"),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: prefered == 0
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            prefered = null;
                                                          });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/recommended.png",
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            Text(
                                                                "Recommended by CSTYLE INDONESIA",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ],
                                                        ),
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            setState(() {
                                                              prefered = 0;
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "-",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: prefered == 1
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            prefered = null;
                                                          });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/recommended.png",
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            const Text(
                                                                "Recommended by CSTYLE INDONESIA",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ],
                                                        ),
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            prefered = 1;
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "-",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: prefered == 2
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            prefered = null;
                                                          });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/recommended.png",
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            const Text(
                                                              "Recommended by CSTYLE INDONESIA",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            setState(() {
                                                              prefered = 2;
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "-",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Table(
                                        border: const TableBorder(
                                          horizontalInside: BorderSide(
                                            color: Colors.black12,
                                            width: 1,
                                          ),
                                          verticalInside: BorderSide(
                                            color: Colors.transparent,
                                            width: 1,
                                          ),
                                          top: BorderSide(
                                            color: Colors.transparent,
                                            width: 1,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                        columnWidths: const <int,
                                            TableColumnWidth>{
                                          0: FlexColumnWidth(1),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(2),
                                        },
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: <TableRow>[
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Product name",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              0]
                                                          .reference,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              0]
                                                          .description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              1]
                                                          .reference,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    Text(
                                                      value
                                                          .selectedComparisson[
                                                              1]
                                                          .description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Images",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: ProductImageComponent(
                                                      autoPlay: false,
                                                      id: value
                                                          .selectedComparisson[
                                                              0]
                                                          .id),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: ProductImageComponent(
                                                      autoPlay: false,
                                                      id: value
                                                          .selectedComparisson[
                                                              1]
                                                          .id),
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Brand",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[0]
                                                      .brand,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[1]
                                                      .brand,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Type",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[0]
                                                      .type,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value.selectedComparisson[1]
                                                      .type,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Price",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  NumberFormat.decimalPattern()
                                                      .format(value
                                                          .selectedComparisson[
                                                              0]
                                                          .price),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  NumberFormat.decimalPattern()
                                                      .format(value
                                                          .selectedComparisson[
                                                              1]
                                                          .price),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("Notes"),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: noteController1,
                                                  // Decoration
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    // hint note
                                                    hintText: "Notes",
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: noteController2,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    // hint note
                                                    hintText: "Notes",
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("Status"),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: prefered == 0
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            prefered = null;
                                                          });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/recommended.png",
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            Text(
                                                                "Recommended by CSTYLE INDONESIA"),
                                                          ],
                                                        ),
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            setState(() {
                                                              prefered = 0;
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "-",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: prefered == 1
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            prefered = null;
                                                          });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/recommended.png",
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            Text(
                                                                "Recommended by CSTYLE INDONESIA"),
                                                          ],
                                                        ),
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            prefered = 1;
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "-",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
