import 'package:flutter/material.dart';

class AppButton {
  static Widget btnRegular({
    required VoidCallback onPressed,
    required Text txtLabel,
  }) =>
      MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minWidth: double.infinity,
        color: Colors.white,
        child: txtLabel,
      );
}
