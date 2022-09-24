import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show json, base64, ascii;
import 'package:Etiquette/Screens/Login.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/Screens/TabController.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  State createState() => _MyApp();
}

class _MyApp extends State<MyApp>{
  bool theme = false;
  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return jwt;
  }
  @override
  void initState() {
    super.initState();
    getTheme();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: jwtOrEmpty,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          if (snapshot.data != "") {
            var str = snapshot.data;
            var jwt = str.toString().split(".");

            if (jwt.length != 3) {
              return GetMaterialApp(
                  localizationsDelegates: GlobalMaterialLocalizations.delegates,
                  supportedLocales: [
                    //const Locale('en', 'US'), // American English
                    //const Locale('ru', 'RU'), // Russian
                    //const Locale("pt"), // Portuguese
                    //const Locale('ar'),
                    const Locale('ko',),// Arabic
                  ],
                  debugShowCheckedModeBanner: false,
                  title: 'Etiquette', //앱 이름 etiquette으로 설정
                  theme: (theme ? ThemeData.dark() : ThemeData.light()),
                  home: const Login() // 최초 페이지로 Login()실행
              );
            } else {
              var payload = json.decode(
                  ascii.decode(base64.decode(base64.normalize(jwt[1]))));
              if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                  .isAfter(DateTime.now())) {
                return GetMaterialApp(
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: GlobalMaterialLocalizations.delegates,
                    supportedLocales: [
                      //const Locale('en', 'US'), // American English
                      //const Locale('ru', 'RU'), // Russian
                      //const Locale("pt"), // Portuguese
                      //const Locale('ar'),
                      const Locale('ko',),// Arabic
                    ],
                    title: 'Etiquette', //앱 이름 etiquette으로 설정
                    theme: (theme ? ThemeData.dark() : ThemeData.light()),
                    home: Tabb(idx:0)//Login() // 최초 페이지로 Login()실행
                );
              } else {
                return GetMaterialApp(
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: GlobalMaterialLocalizations.delegates,
                    supportedLocales: [
                      //const Locale('en', 'US'), // American English
                      //const Locale('ru', 'RU'), // Russian
                      //const Locale("pt"), // Portuguese
                      //const Locale('ar'),
                      const Locale('ko',),// Arabic
                    ],
                    title: 'Etiquette', //앱 이름 etiquette으로 설정
                    theme: (theme ? ThemeData.dark() : ThemeData.light()),
                    home: const Login() // 최초 페이지로 Login()실행
                );
              }
            }
          } else {
            return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Etiquette', //앱 이름 etiquette으로 설정
                theme: (theme ? ThemeData.dark() : ThemeData.light()),
                home: const Login() // 최초 페이지로 Login()실행
            );
          }
        });
  }
  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
  }
}
