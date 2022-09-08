import 'package:flutter/material.dart';
import 'package:get/get.dart';

@override
AppBar defaultAppbar(String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.white24,
    foregroundColor: Colors.black,
    elevation: 0,
  );
}

@override
AppBar appbarWithArrowBackButton(String title, bool theme) {
  return AppBar(
    iconTheme: IconThemeData(color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
    title: Text(
        title,
        style: TextStyle(
          fontSize: 25,
          color: (theme ? const Color(0xffe8e8e8) : Colors.black)
        )
    ),
    backgroundColor: Colors.white24,
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded
      )
    ),
  );
}