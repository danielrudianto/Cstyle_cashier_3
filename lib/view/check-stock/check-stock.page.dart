import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:flutter/material.dart';

class CheckStockPage extends StatefulWidget {
  const CheckStockPage({super.key});

  @override
  State<CheckStockPage> createState() => _CheckStockPageState();
}

class _CheckStockPageState extends State<CheckStockPage> {
  int page = 1;
  TextEditingController controller = TextEditingController();

  _fetchStock(int selectedPage) {
    setState(() {
      page = selectedPage;
    });

    ProductStockFetchModel.checkServerStock(selectedPage, controller.text)
        .then((value) {});
  }

  @override
  void initState() {
    _fetchStock(page);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Form field
          TextField(),
          Expanded(
            child: SingleChildScrollView(),
          ),
        ],
      ),
    );
  }
}
