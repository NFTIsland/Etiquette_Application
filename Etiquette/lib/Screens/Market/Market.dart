import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/SellTicket.dart';
import 'package:Etiquette/Screens/Market/upload_ticket.dart';
// import 'package:Etiquette/Screens/bid_buy.dart';

class Market extends StatefulWidget {
  const Market({Key? key}) : super(key: key);

  @override
  State createState() => _Market();
}

class _Market extends State<Market> {
  bool ala = true;
  late bool theme;
  var img = const Icon(Icons.notifications);
  List? high;

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

  @override
  void initState() {
    super.initState();
    _loadData();
    getTheme();
    high = List.empty(growable: true);
    high!.add(ex1);
    high!.add(ex2);
    high!.add(ex3);
    high!.add(ex4);
    high!.add(ex5);
  }

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTheme(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                  title: const Text("Auction"),
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.black,
                  elevation: 0,
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
                children: <Widget> [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 18, right: 18),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                Column(
                                    children: <Widget> [
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Best Selling Tickets",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                        ),
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
                                      )
                                    ]
                                ),
                                Column(
                                    children: <Widget> [
                                      const SizedBox(height: 20),
                                      const Text("Deadline Imminent",
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
                                            return GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => SellTicket()
                                                      )
                                                  );
                                                },
                                                child : Card(
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
                                                )
                                            );
                                          }
                                      )
                                    ]
                                ),
                                Column(
                                    children: <Widget> [
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
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Image.network(
                                                                high![index]['img'],
                                                                width: 50,
                                                                height: 50
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child:
                                                              Column(
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget> [
                  FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => BBuy()));
                    },
                    backgroundColor: (theme ? const Color(0xffe8e8e8) : const Color(0xff7b9acc)),
                    foregroundColor: (theme ? const Color(0xff000000) : const Color(0xffFCF6F5)),
                    label: const Text("중고 티켓 구매"),
                    icon: const Icon(Icons.navigation),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => const UploadTicket()
                          )
                      );
                    },
                    backgroundColor: (theme ? const Color(0xffe8e8e8) : const Color(0xff7b9acc)),
                    foregroundColor: (theme ? const Color(0xff000000) : const Color(0xffFCF6F5)),
                    label: const Text("티켓 업로드"),
                    icon: const Icon(Icons.add_card),
                  ),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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