import 'package:Etiquette/Login.dart';
import 'package:flutter/material.dart';
import '../Login.dart';

void displayDialog(context, title, text) => showDialog(
  context: context,
  builder: (context) =>
      AlertDialog(title: Text(title), content: Text(text)),
);

void displayDialog_checkonly(context, title, text) => showDialog(
  context: context,
  builder: (context) =>
      AlertDialog(title: Text(title), content: Text(text), actions: <Widget>[TextButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login())), child: const Text('OK'),),],),
);