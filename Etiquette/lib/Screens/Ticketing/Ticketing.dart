import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/Ticketing/total_imminent.dart';
import 'package:Etiquette/Screens/Ticketing/search_ticket.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';

class Ticketing extends StatefulWidget {
  const Ticketing({Key? key}) : super(key: key);

  @override
  State createState() => _Ticketing();
}

class _Ticketing extends State<Ticketing> {
  bool ala = true;
  late bool theme;
  var img = const Icon(Icons.notifications);
  List hotpick = [];
  List deadline = [];
  String? nickname = "";

  late final Future future;

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

  Future<void> getHotPickFromDB() async {
    const url = "$SERVER_IP/ticketing/hotPick";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        List _hotpick = data["data"];
        for (Map<String, dynamic> item in _hotpick) {
          Map<String, dynamic> ex = {
            'product_name': item['product_name'],
            'place': item['place'],
          };
          hotpick.add(ex);
          setState(() {});
        }
      } else {
        displayDialog_checkonly(context, "Hot Pick", "서버와의 상태가 원활하지 않습니다.");
      }
    } catch (ex) {
      String msg = ex.toString();
      displayDialog_checkonly(context, "티켓팅", msg);
    }
  }

  Future<void> getImminentDeadlineFromDB() async {
    const url = "$SERVER_IP/ticketing/deadLineTop5";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        List _deadline = data["data"];
        for (Map<String, dynamic> item in _deadline) {
          Map<String, dynamic> ex = {
            'product_name': item['product_name'],
            'place': item['place'],
          };
          deadline.add(ex);
          setState(() {});
        }
      } else {
        displayDialog_checkonly(context, "Imminent Deadline", "서버와의 상태가 원활하지 않습니다.");
      }
    } catch (ex) {
      String msg = ex.toString();
      displayDialog_checkonly(context, "Imminent Deadline", msg);
    }
  }

  Future<void> getNickname() async {
    nickname = await storage.read(key: "nickname");
  }

  Future<void> getTicketingDataFromDB() async {
    getHotPickFromDB();
    getImminentDeadlineFromDB();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    getTheme();
    getNickname();
    future = getTicketingDataFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("Ticketing"),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
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
              drawer: drawer(context, theme, nickname),
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
                                      const SizedBox(height: 20),
                                      const Text(
                                          "Hot Pick",
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      const Text(
                                          "사람들의 관심도가 높은 티켓을 보여드립니다.",
                                          style: TextStyle(
                                            fontSize: 15,
                                          )
                                      ),
                                      const SizedBox(height: 20),
                                      ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: hotpick.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                                child: SizedBox(
                                                    width: double.infinity,
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: <Widget>[
                                                          Expanded(
                                                              flex: 1,
                                                              child: Center(
                                                                child: Text(
                                                                  (index + 1).toString(),
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 25,
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Image.network(
                                                                "https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg",
                                                                width: 40,
                                                                height: 40
                                                            ),
                                                          ),
                                                          Expanded(
                                                              flex: 4,
                                                              child: Column(
                                                                  children: <Widget>[
                                                                    Text(hotpick[index]['product_name']),
                                                                    Text(hotpick[index]['place'].toString()),
                                                                  ]
                                                              )
                                                          )
                                                        ]
                                                    )
                                                )
                                            );
                                          }
                                      ),
                                      const SizedBox(height: 40),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget> [
                                          const Text(
                                              "Deadline Imminent",
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold
                                              )
                                          ),
                                          TextButton(
                                            child: const Text(
                                                "+ 더보기",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                )
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => const TotalImminent()
                                                  )
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      const Text(
                                          "마감 시각이 임박한 티켓들을 보여드립니다. (24시간 이내)",
                                          style: TextStyle(
                                            fontSize: 15,
                                          )
                                      ),
                                      const SizedBox(height: 10),
                                      ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: deadline.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                                child: SizedBox(
                                                    width: double.infinity,
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: <Widget> [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Image.network(
                                                                "https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg",
                                                                width: 40,
                                                                height: 40
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Column(
                                                                children: <Widget>[
                                                                  Text(deadline[index]['product_name']),
                                                                  Text(deadline[index]['place']),
                                                                ]
                                                            ),
                                                          )
                                                        ]
                                                    )
                                                )
                                            );
                                          }
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