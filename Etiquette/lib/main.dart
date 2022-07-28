import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  State createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  ThemeData mode = ThemeData.light();
  bool theme = false;
  var img;
  late bool ala;
  void _loadMode() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    if (theme == false) {
      mode = ThemeData.light();
    } else {
      mode = ThemeData.dark();
    }
  }
  void _loadData() async {
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      var value = pref.getBool(key);
      if (value != null) {
        ala = value;
        if (ala == true) {
          img = const Icon(Icons.notifications);
        } else {
          img = const Icon(Icons.notifications_none);
        }
      }
    });
  }

  void initState() {
    super.initState();
    _loadMode();
    _loadData();
    getTheme();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          _initFirebaseMessaging(context);
          print("ala는 : $ala");
          if(ala == true) {
            _getToken();
            print("실행완료");
          }
          else if(ala == false){
            _delToken();
          }
          return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Etiquette', //앱 이름 etiquette으로 설정
              theme: (theme ? ThemeData.dark() : ThemeData.light()),
              //darkTheme: ThemeData.dark(),
              home: Login() // 최초 페이지로 Login()실행
              );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
  }
}

void _initFirebaseMessaging(BuildContext context) {
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    print(event.notification!.title);
    print(event.notification!.body);
    Get.dialog(AlertDialog(
        title: Text("알림"),
        content: Text(event.notification!.body!),
        actions: [
          TextButton(
              child: Text("OK"),
              onPressed: () {
                Get.back();
              })
        ]));
    /*
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("알림"),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });*/
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
}

_getToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  print("messaging.getToken(), ${await messaging.getToken()}");
}

_delToken() async{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.deleteToken();
  print("deleting token");
}