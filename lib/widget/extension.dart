import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

extension PaddingExtension on Widget {
  Widget toPadSymmetric(
      {required double horizontal, required double vertical}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: this,
    );
  }

  Widget toPadAll({required double all}) {
    return Padding(
      padding: EdgeInsets.all(all),
      child: this,
    );
  }
}

extension StringOperation on String {
  toUpperLowerCase() {
    return isNotEmpty ? (this[0].toUpperCase() + substring(1)) : "";
  }
}

extension IconExtension on IconData {
  Widget toImage({required IconData icons}) {
    return FaIcon(
      icons,
      size: 20,
    );
  }
}
