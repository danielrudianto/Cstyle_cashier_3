import 'dart:async';

import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';

class AddMemberCheckout extends StatefulWidget {
  const AddMemberCheckout({super.key});

  @override
  State<AddMemberCheckout> createState() => _AddMemberCheckoutState();
}

class _AddMemberCheckoutState extends State<AddMemberCheckout> {
  TextEditingController membershipCodeController = TextEditingController();
  bool isLoading = false;
  bool isChecking = false;
  bool isChecked = false;

  Timer? _debounce;

  _checkMemberCode(String code) {
    // Debounce time in 500ms
    if (isChecking) return;
    if (code.isEmpty) return;
    if (code.length < 3) return;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isChecked = false;
        isChecking = true;
      });

      MemberModel.fetchByCode(code.toUpperCase()).then((value) {
        if (value != null) {
          isChecked = true;
        } else {
          isChecked = false;
        }
      }).catchError((error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
      }).whenComplete(() {
        setState(() {
          isChecking = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 480,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Select member",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
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
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextFormField(
              readOnly: isChecking,
              onChanged: (value) {
                _checkMemberCode(value);
              },
              controller: membershipCodeController,
              decoration: InputDecoration(
                hintText: "Enter membership code",
                suffix: isChecking
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : isChecked
                        ? const Icon(
                            Icons.check,
                            size: 15,
                          )
                        : null,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "This dialog will help you check the member code given by customer. In offline situation you can still select the member on your own risk.",
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    foregroundColor: diAtasAksen(context),
                  ),
                  onPressed: isChecking
                      ? null
                      : isChecked
                          ? () {
                              Navigator.of(context).pop(
                                  membershipCodeController.text.isEmpty
                                      ? null
                                      : membershipCodeController.text
                                          .toUpperCase());
                            }
                          : null,
                  child: const Text(
                    "Select member",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Lato",
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
