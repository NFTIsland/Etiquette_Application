import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/Setting.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Screens/Notice.dart';
import 'package:Etiquette/Screens/CustomerService.dart';
import 'package:Etiquette/Screens/Guide.dart';
import 'package:Etiquette/Screens/FAQ.dart';

class More extends StatefulWidget {
  const More({Key? key}) : super(key: key);

  @override
  State createState() => _More();
}

class _More extends State<More> {
  bool ala = true;
  late bool theme;
  var img = Icon(Icons.notifications);
  String? nickname = "";

  List<String> Option = [
    'Application Guide',
    'Notice',
    '1:1 Customer Service',
    'FAQ',
    'Setting'
  ];

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  void _setData(bool value) async {
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  void _loadData() async {
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      var value = pref.getBool(key);
      if (value != null) {
        ala = value;
        if (ala == true) {
          img = Icon(Icons.notifications);
        } else {
          img = Icon(Icons.notifications_none);
        }
      }
    });
  }

  Future<void> getNickname() async {
    nickname = await storage.read(key: "nickname");
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getNickname(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("Home", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                    iconTheme: IconThemeData(color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
                    title: Text("Etiquette", style : TextStyle(color: (theme ? const Color(0xffe8e8e8) : Colors.black))),
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    actions: <Widget>[
                      Container(
                          child: IconButton(
                            icon: img,
                            onPressed: () {
                              if (ala == true) {
                                ala = false;
                                _delToken();
                                setState(() {
                                  img = Icon(Icons.notifications_none);
                                });
                                _setData(ala);
                              } else {
                                ala = true;
                                _getToken();
                                setState(() {
                                  img = Icon(Icons.notifications);
                                });
                                _setData(ala);
                              }
                            },
                          )
                      ),
                    ]
                ),
                drawer: drawer(context, theme, nickname),
                body: ListView(padding: EdgeInsets.only(left: 10), children: <
                    Widget>[
                  ListTile(
                      title: Text("Application Guide",
                          style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Guide(),
                          ),
                        );
                      }),
                  ListTile(
                      title: Text("Notice", style: TextStyle(fontSize: 20)),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Notice(),
                          ),
                        );
                      }
                  ),
                  ListTile(
                      title: Text("1:1 Customer Service",
                          style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Customer(),
                          ),
                        );
                      }),
                  ListTile(
                      title: Text("FAQ", style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FAQ(),
                          ),
                        );
                      }),
                  ListTile(
                      title: Text("Setting", style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Setting()));
                        setState(() {
                          _loadData();
                        });
                      }),
                ]));
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
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