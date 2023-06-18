import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Screens/Notice.dart';
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
                body: ListView(
                    padding: EdgeInsets.only(left: 10),
                    children: <Widget>[
                      ListTile(
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget> [
                                const Text(
                                    "Contacts",
                                    style: TextStyle(fontSize: 20)
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const <Widget> [
                                    Text(
                                        "Email: nftisland@naver.com",
                                        style: TextStyle(fontSize: 15)
                                    ),
                                    Text(
                                        "카카오톡: nftisland",
                                        style: TextStyle(fontSize: 15)
                                    ),
                                  ],
                                )
                              ]
                          )
                      ),
                      ListTile(
                          title: const Text(
                              "Application Guide",
                              style: TextStyle(fontSize: 20)
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Guide(),
                              ),
                            );
                          }
                      ),
                      ListTile(
                          title: const Text(
                              "Notice",
                              style: TextStyle(fontSize: 20)
                          ),
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
                          title: const Text(
                              "FAQ",
                              style: TextStyle(fontSize: 20)
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FAQ(),
                              ),
                            );
                          }
                      ),
                    ]
                )
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );
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