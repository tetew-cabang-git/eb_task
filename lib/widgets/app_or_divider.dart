import 'package:flutter/material.dart';

class AppDivider {
  static Widget divider = SizedBox(
    width: 200,
    child: Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: Divider(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          'OR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          fit: FlexFit.tight,
          child: Divider(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    ),
  );
}
