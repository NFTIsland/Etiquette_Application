import 'package:Etiquette/Screens/Login.dart';
import 'package:flutter/material.dart';

void displayDialog(context, title, text) => showDialog(
  context: context,
  builder: (context) =>
      AlertDialog(title: Text(title), content: Text(text)),
);

void displayDialog_register(context, title, text) => showDialog(
  context: context,
  builder: (context) =>
      AlertDialog(title: Text(title), content: Text(text), actions: <Widget>[TextButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login())), child: const Text('OK'),),],),
);

void displayDialog_checkonly(context, title, text) => showDialog(
  context: context,
  builder: (context) =>
      AlertDialog(title: Text(title), content: Text(text), actions: <Widget>[TextButton(
        onPressed: () => Navigator.of(context).pop(), child: const Text('OK'),),],),
);

Future<bool> displayDialog_YesOrNo(context, title, text) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
}
