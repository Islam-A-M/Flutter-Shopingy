import 'package:flutter/material.dart';

Widget CustomSnackBar(String body, Icon icon, Widget action) {
  return SnackBar(
    duration: Duration(seconds: 3),
    content: Row(
      children: [
        icon,
        SizedBox(
          width: 2,
        ),
        Text(
          body,
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    ),
    action: action,
    backgroundColor: Colors.blue,
    // padding: EdgeInsets.only(bottom: 10),
    elevation: 40,
    shape:
        RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
    behavior: SnackBarBehavior.floating,
  );
}
