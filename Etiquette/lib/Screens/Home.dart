import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Screens/Search.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State createState() => _Home();
}

class _Home extends State<Home> {
  bool ala = true;
  var img = const Icon(Icons.notifications);
  late bool theme;
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

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
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
                    title: const Text("Etiquette"),
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => Search()
                          //     )
                          // );
                        },
                      )
                    ]
                ),
                drawer: drawer(context, theme), // 왼쪽 위 부가 메뉴버튼을 단순 ListView에서 Drawer 사용하여 슬라이드로
                body: SingleChildScrollView( // 만약 화면에 다 표현할 수 없으면 스크롤 할 수 있게 설정
                    child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: <Widget> [
                            const SizedBox(height: 15),
                            Column( // Tickets with high bidders를 위한 공간
                              children: <Widget> [
                                const Text(
                                    "Tickets with high bidders",
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold
                                    )
                                ),
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
                                const Text(
                                    "Deadline Imminent",
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold
                                    )
                                ),
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
                                                            children: <Widget> [
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
                            )
                          ]
                        )
                    )
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