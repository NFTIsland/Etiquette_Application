import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Account.dart';
import 'Bid.dart';
import 'Hold.dart';
import 'Interest.dart';
import 'Search.dart';
import 'Selling.dart';
import 'Setting.dart';
import 'Used.dart';
import 'Wallet.dart';

class More extends StatefulWidget {
  //More에서 구현할 화면
  State createState() => _More();
}

class _More extends State<More> {
  List<String> Option = [
    'Application Guide',
    'Notice',
    '1:1 Customer Service',
    'FAQ',
    'Setting'
  ];
  bool ala = true;
  late bool theme;
  var img = Icon(Icons.notifications);

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

  void initState() {
    super.initState();
    _loadData();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTheme(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("More"),
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
                          setState(() {
                            img = Icon(Icons.notifications_none);
                          });
                          _setData(ala);
                        } else {
                          ala = true;
                          setState(() {
                            img = Icon(Icons.notifications);
                          });
                          _setData(ala);
                        }
                      },
                    )),
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Search()));
                        })
                  ],
                ),
                // 왼쪽 위 부가 메뉴버튼을 단순 ListView에서 Drawer 사용하여 슬라이드로
                drawer: SafeArea(
                  child: Drawer(
                    child: ListView(children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Account()));
                        },
                        child: UserAccountsDrawerHeader(
                          currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.white24,
                            backgroundImage:
                                AssetImage('assets/image/mainlogo.png'),
                          ),
                          accountName: Text(
                            'guest1',
                            style: TextStyle(color: Colors.black),
                          ),
                          accountEmail: Text(
                            'a1234@naver.com',
                            style: TextStyle(color: Colors.black),
                          ),
                          decoration: BoxDecoration(
                              color: (theme
                                  ? const Color(0xffe8e8e8)
                                  : const Color(0xff7b9acc)),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              )),
                        ),
                      ),
                      ListTile(
                        title: Text('Wallet'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Wallet())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('List of holding tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Hold())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('Interest Tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Interest())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('Bid Tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Bid())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('Selling Tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Selling())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('List of used tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Used())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                    ]),
                  ),
                ),
                body: ListView(padding: EdgeInsets.only(left: 10), children: <
                    Widget>[
                  ListTile(
                      title: Text("Application Guide",
                          style: TextStyle(fontSize: 20)),
                      onTap: () {}),
                  ListTile(
                      title: Text("Notice", style: TextStyle(fontSize: 20)),
                      onTap: () {}),
                  ListTile(
                      title: Text("1:1 Customer Service",
                          style: TextStyle(fontSize: 20)),
                      onTap: () {}),
                  ListTile(
                      title: Text("FAQ", style: TextStyle(fontSize: 20)),
                      onTap: () {}),
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
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
