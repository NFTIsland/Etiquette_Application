import 'package:flutter/material.dart';

Future<void> displayDialog(context, title, text) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text)
    ),
  );
}

// Future<void> displayDialog_register(context, title, text) async {
//   return await showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text(title),
//       content: Text(text),
//       actions: <Widget> [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('OK'),
//         ),
//       ],
//     ),
//   );
// }

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
