import 'dart:async';

import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/material.dart';

class SelectEmployee extends StatefulWidget {
  const SelectEmployee({super.key});

  @override
  State<SelectEmployee> createState() => _SelectEmployeeState();
}

class _SelectEmployeeState extends State<SelectEmployee> {
  TextEditingController membershipCodeController = TextEditingController();
  bool isLoading = false;
  bool isChecking = false;
  bool isChecked = false;
  UserModel? user;

  Timer? _debounce;

  _checkEmployeeCode(String code) {
    // Debounce time in 500ms
    if (isChecking) return;
    if (code.isEmpty) return;
    if (code.length < 3) return;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        user = null;
        isChecked = false;
        isChecking = true;
      });

      UserModel.fetchByCode(code.toUpperCase()).then((value) {
        if (value != null) {
          LoggerUtils().log("Found a user!", LogType.info);
          user = value;
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
      height: 220,
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
                    "Insert your employee code",
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
              autofocus: true,
              readOnly: isChecking,
              onChanged: (value) {
                _checkEmployeeCode(value);
              },
              obscureText: false,
              controller: membershipCodeController,
              decoration: InputDecoration(
                hintText: "Enter your employee code",
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
                  ),
                  onPressed: isChecking || !isChecked || user == null
                      ? null
                      : () {
                          Navigator.of(context).pop(user);
                        },
                  child: const Text(
                    "Continue",
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
