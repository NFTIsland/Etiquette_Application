import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show json, base64, ascii;
import 'Login.dart';
import 'Home.dart';
import 'package:Etiquette/Models/serverset.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Etiquette',
      home: FutureBuilder(
          future: jwtOrEmpty,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data != "") {
              var str = snapshot.data;
              var jwt = str.toString().split(".");

              if (jwt.length != 3) {
                return Login();
              } else {
                var payload = json.decode(
                    ascii.decode(base64.decode(base64.normalize(jwt[1]))));
                if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                    .isAfter(DateTime.now())) {
                  return Home();
                } else {
                  return Login();
                }
              }
            } else {
              return Login();
            }
          }),
    );
  }
}
