import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/Ticketing/ticketing_list.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';

class Ticketing extends StatefulWidget {
  const Ticketing({Key? key}) : super(key: key);

  @override
  State createState() => _Ticketing();
}

class _Ticketing extends State<Ticketing> {
  bool ala = true;
  late bool theme;
  var img = const Icon(Icons.notifications);
  List? high;
  List list = [];

  late final Future future;

  Map<String, dynamic> ex1 = {
    'name': '티켓1',
    'category': '영화',
    'price': 16000,
    'img':
    'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex2 = {
    'name': '티켓2',
    'category': '콘서트',
    'price': 150000,
    'img':
    'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex3 = {
    'name': '티켓3',
    'category': '스포츠',
    'price': 66000,
    'img':
    'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex4 = {
    'name': '티켓4',
    'category': '뮤지컬',
    'price': 130000,
    'img':
    'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex5 = {
    'name': '티켓5',
    'category': '공연',
    'price': 100000,
    'img':
    'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };

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
          img = const Icon(Icons.notifications);
        } else {
          img = const Icon(Icons.notifications_none);
        }
      }
    });
  }

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getMarketTicketsFromDB() async {
    list = List.empty(growable: true);
    const url = "$SERVER_IP/ticketInfo";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        List tickets = data["data"];
        for (Map<String, dynamic> ticket in tickets) {
          Map<String, dynamic> ex = {
            'product_name': ticket['product_name'],
            'place': ticket['place'],
          };
          list.add(ex);
        }
      } else {
        int statusCode = res.statusCode;
        String msg = data['msg'];
        displayDialog_checkonly(context, "티켓팅", "statusCode: $statusCode\n\nmessage: $msg");
      }
    } catch (ex) {
      int statusCode = 404;
      String msg = ex.toString();
      displayDialog_checkonly(context, "티켓팅", "statusCode: $statusCode\n\nmessage: $msg");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    getTheme();
    future = getMarketTicketsFromDB();
    high = List.empty(growable: true);
    high!.add(ex1);
    high!.add(ex2);
    high!.add(ex3);
    high!.add(ex4);
    high!.add(ex5);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                  title: const Text("Ticketing"),
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.black,
                  elevation: 0, // elevation은 떠보이는 느낌 설정하는 것, 0이면 뜨는 느낌 없음, foreground는 글자 색 변경
                  actions: <Widget>[
                    IconButton(
                      icon: img,
                      onPressed: () {
                        if (ala == true) {
                          ala = false;
                          _delToken();
                          setState(() {
                            img = const Icon(Icons.notifications_none);
                          });
                          _setData(ala);
                        } else {
                          ala = true;
                          _getToken();
                          setState(() {
                            img = const Icon(Icons.notifications);
                          });
                          _setData(ala);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Get.to(Search());
                      },
                    )
                  ]
              ),
              drawer: drawer(context, theme),
              body: Column(
                  children: <Widget>[
                    Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(left: 18, right: 18),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽에 딱 붙도록 설정
                                    children: <Widget> [
                                      Column(
                                          children: <Widget> [
                                            const SizedBox(height: 20),
                                            const Text(
                                                "Hot Pick",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                )
                                            ),
                                            const SizedBox(height: 20),
                                            ListView.builder(
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: high!.length,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                      child: SizedBox(
                                                          width: double.infinity,
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Expanded(
                                                                  child: Image.network(
                                                                      high![index]['img'],
                                                                      width: 50,
                                                                      height: 50
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child: Column(
                                                                        children: <Widget>[
                                                                          Text(high![index]['name']),
                                                                          Text(high![index]['category']),
                                                                          Text(high![index]['price'].toString()),
                                                                        ]
                                                                    )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  );
                                                }
                                            ),
                                          ]
                                      ),
                                      Column(
                                          children: <Widget> [
                                            const SizedBox(height: 20),
                                            const Text(
                                                "Deadline Imminent",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                )
                                            ),
                                            const SizedBox(height: 20),
                                            ListView.builder(
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: high!.length,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                      child: SizedBox(
                                                          width: double.infinity,
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget> [
                                                                Expanded(
                                                                  child: Image.network(
                                                                      high![index]['img'],
                                                                      width: 50,
                                                                      height: 50
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child: Column(
                                                                        children: <Widget>[
                                                                          Text(high![index]['name']),
                                                                          Text(high![index]['category']),
                                                                          Text(high![index]['price'].toString()),
                                                                        ]
                                                                    )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  );
                                                }
                                            ),
                                          ]
                                      ),
                                      Column(
                                          children: <Widget>[
                                            const SizedBox(height: 20),
                                            const Text(
                                                "Ranking",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                )
                                            ),
                                            const SizedBox(height: 20),
                                            ListView.builder(
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: high!.length,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                      child: SizedBox(
                                                          width: double.infinity,
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget> [
                                                                Expanded(
                                                                  child: Image.network(
                                                                      high![index]['img'],
                                                                      width: 50,
                                                                      height: 50
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child: Column(
                                                                        children: <Widget>[
                                                                          Text(high![index]['name']),
                                                                          Text(high![index]['category']),
                                                                          Text(high![index]['price'].toString()),
                                                                        ]
                                                                    )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  );
                                                }
                                            ),
                                            const SizedBox(height: 80),
                                          ]
                                      ),
                                    ]
                                )
                            ),
                          ),
                        )
                    ),
                  ]
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const TicketingList()
                      )
                  );
                },
                backgroundColor: (theme ? const Color(0xffe8e8e8) : Colors.green),
                foregroundColor: (theme ? const Color(0xff000000) : const Color(0xffFCF6F5)),
                label: const Text("티켓 구매"),
                icon: const Icon(Icons.navigation),
              ),
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