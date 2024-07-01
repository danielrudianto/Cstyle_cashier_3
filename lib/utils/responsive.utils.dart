import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getContainerSize(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200
        ? 1140
        : MediaQuery.of(context).size.width > 992
            ? 960
            : MediaQuery.of(context).size.width > 768
                ? 720
                : double.infinity;
  }

  static double getContainerSizeMultiplier(
      BuildContext context, List<double> multipliers) {
    if (multipliers.length != 4) {
      throw Exception("Multipliers list must have 4 elements");
    } else {
      return MediaQuery.of(context).size.width > 1200
          ? multipliers[0] * 1140
          : MediaQuery.of(context).size.width > 992
              ? multipliers[1] * 960
              : MediaQuery.of(context).size.width > 768
                  ? multipliers[2] * 720
                  : multipliers[3] * double.infinity;
    }
  }
}
