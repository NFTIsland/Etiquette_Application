import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/Ticketing/search_ticket.dart';
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



  @override
  void initState() {
    super.initState();
    _loadData();
    future = getTheme();
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
                                // child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽에 딱 붙도록 설정
                                //     children: <Widget> [
                                //       Column(
                                //           children: <Widget> [
                                //             const SizedBox(height: 20),
                                //             const Text(
                                //                 "Hot Pick",
                                //                 style: TextStyle(
                                //                     fontSize: 20,
                                //                     fontWeight: FontWeight.bold
                                //                 )
                                //             ),
                                //             const SizedBox(height: 20),
                                //             ListView.builder(
                                //                 physics: const NeverScrollableScrollPhysics(),
                                //                 shrinkWrap: true,
                                //                 itemCount: high!.length,
                                //                 itemBuilder: (context, index) {
                                //                   return Card(
                                //                       child: SizedBox(
                                //                           width: double.infinity,
                                //                           child: Row(
                                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //                               children: <Widget>[
                                //                                 Expanded(
                                //                                   child: Image.network(
                                //                                       high![index]['img'],
                                //                                       width: 50,
                                //                                       height: 50
                                //                                   ),
                                //                                 ),
                                //                                 Expanded(
                                //                                     child: Column(
                                //                                         children: <Widget>[
                                //                                           Text(high![index]['name']),
                                //                                           Text(high![index]['category']),
                                //                                           Text(high![index]['price'].toString()),
                                //                                         ]
                                //                                     )
                                //                                 )
                                //                               ]
                                //                           )
                                //                       )
                                //                   );
                                //                 }
                                //             ),
                                //           ]
                                //       ),
                                //       Column(
                                //           children: <Widget> [
                                //             const SizedBox(height: 20),
                                //             const Text(
                                //                 "Deadline Imminent",
                                //                 style: TextStyle(
                                //                     fontSize: 20,
                                //                     fontWeight: FontWeight.bold
                                //                 )
                                //             ),
                                //             const SizedBox(height: 20),
                                //             ListView.builder(
                                //                 physics: const NeverScrollableScrollPhysics(),
                                //                 shrinkWrap: true,
                                //                 itemCount: high!.length,
                                //                 itemBuilder: (context, index) {
                                //                   return Card(
                                //                       child: SizedBox(
                                //                           width: double.infinity,
                                //                           child: Row(
                                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //                               children: <Widget> [
                                //                                 Expanded(
                                //                                   child: Image.network(
                                //                                       high![index]['img'],
                                //                                       width: 50,
                                //                                       height: 50
                                //                                   ),
                                //                                 ),
                                //                                 Expanded(
                                //                                     child: Column(
                                //                                         children: <Widget>[
                                //                                           Text(high![index]['name']),
                                //                                           Text(high![index]['category']),
                                //                                           Text(high![index]['price'].toString()),
                                //                                         ]
                                //                                     )
                                //                                 )
                                //                               ]
                                //                           )
                                //                       )
                                //                   );
                                //                 }
                                //             ),
                                //           ]
                                //       ),
                                //     ]
                                // )
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