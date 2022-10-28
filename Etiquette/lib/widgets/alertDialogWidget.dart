import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Etiquette/Screens/Drawer/ChangeUserInfo.dart';
import 'package:Etiquette/Screens/Drawer/Change_nickname.dart';

Future<void> displayDialog(context, title, text) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text)
    ),
  );
}

Future<void> displayDialog_checkonly(context, title, text) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget> [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> displayDialog_checkonly_directNN(context, title, text) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget> [
        TextButton(
          onPressed: () => {Navigator.popUntil(context, ModalRoute.withName('/ChangeNickname'))},
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> displayDialog_checkonly_changeNickname(context, title, text) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget> [
        TextButton(
          onPressed: () => {
            Get.to(() => ChangeUserInfo())},
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

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

Future<void> displayDialog_changeIndividual(context, title, text) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget> [
        TextButton(
          onPressed: () {Get.to(() => ChangeUserInfo());},
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
