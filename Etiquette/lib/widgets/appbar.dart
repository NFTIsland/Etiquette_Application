import 'package:flutter/material.dart';

@override
AppBar defaultAppbar(String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.white24,
    foregroundColor: Colors.black,
    elevation: 0,
  );
}