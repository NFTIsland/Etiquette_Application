import 'dart:async';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/appbar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State createState() => _Home();
}

class _Home extends State<Home> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  bool ala = true;
  var img = const Icon(Icons.notifications);
  late bool theme;
  late double width;
  late double height;

  String currentTime = "Loading...";
  String klayCurrency = "Loading...";
  String? nickname = "";

  List home_posters = [];
  List notices = [];

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

  String loadCurrentTime() {
    final now = DateTime.now();
    // currentTime = "${now.year}년 ${now.month}월 ${now.day}일 ${now.hour}시 ${now.minute}분 ${now.second}초";
    return "${now.year}년 ${now.month}월 ${now.day}일 ${now.hour}시 ${now.minute}분 ${now.second}초";
  }

  Future<void> getKlayCurrency() async {
    final res = await http.get(Uri.parse("https://api.coinone.co.kr/public/v2/ticker_new/KRW/KLAY"));
    Map<String, dynamic> data = json.decode(res.body);
    if (data["result"] == "success") {
      klayCurrency = data["tickers"][0]["last"].toString();
    } else {
      klayCurrency = "Loading...";
    }
  }

  String getStrKlayCurrency() {
    getKlayCurrency();
    if (double.tryParse(klayCurrency) == null) {
      return klayCurrency;
    } else {
      return klayCurrency + " ￦";
    }
  }

  Future<void> loadHomePosters() async {
    const url = "$SERVER_IP/screen/homePosters";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        for (var _image in data['data']) {
          home_posters.add(_image['poster_url']);
        }
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "Home", msg);
      }
    } catch (ex) {
      displayDialog_checkonly(context, "Home", "네트워크 상태가 원활하지 않습니다.");
    }
  }

  Future<void> getNickname() async {
    nickname = await storage.read(key: "nickname");
  }

  _fetchData() async {
    return this._memoizer.runOnce(() async {
      _loadData();
      loadHomePosters();
      getHomeNotices();
      getNickname();
      await Future.delayed(
          const Duration(milliseconds: 1000)
      );
      return;
    });
  }

  Future<void> getHomeNotices() async {
    const url = "$SERVER_IP/screen/homeNotices";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        for (var _title in data['data']) {
          notices.add(_title);
        }
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "Home", msg);
      }
    } catch (ex) {
      displayDialog_checkonly(context, "Home", "네트워크 상태가 원활하지 않습니다.");
    }
  }

  @override
  void initState() {
    super.initState();
    getTheme();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: _fetchData(),
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

                    ]
                ),
                drawer: drawer(context, theme, nickname),
                drawerScrimColor: (theme ? const Color(0xffe8e8e8) : Colors.black),
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget> [
                      SizedBox(
                        width : width,
                        height : height * 0.4,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: height * 0.4,
                            autoPlay: true, //자동재생 여부
                          ),
                          items: home_posters.map((item) {
                            return Builder(builder: (BuildContext context) {
                              return Container(
                                width : width,
                                height : height * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  //border 를 주기 위해 decoration 사용
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: ClipRRect(
                                  //ClipRRect : 위젯 모서리 둥글게 하기위해 사용하는 위젯
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Image.network(
                                    item,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            });
                          }).toList(),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              width * 0.044, height * 0.04125, width * 0.044, 0
                          ),
                          child: Container(
                            width: width * 0.91,
                            height: height * 0.06125,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                  Padding(
                                    padding: EdgeInsets.only(left: width * 0.0361),
                                    child: Text(
                                        "Klay 시세",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: (theme
                                                ?  const Color(0xff000000)
                                                :  const Color(0xffffffff))
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: width * 0.0361),
                                    child: TimerBuilder.periodic(
                                      const Duration(seconds: 3),
                                      builder: (context) {
                                        return Text(
                                          getStrKlayCurrency(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (theme
                                                ?  const Color(0xff000000)
                                                :  const Color(0xffffffff)),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ]
                            ),
                            decoration: BoxDecoration(
                                color: (theme
                                    ? const Color(0xffe8e8e8)
                                    : const Color(0xff8AAAE5)),
                                borderRadius: BorderRadius.circular(9)
                            ),
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              width * 0.044, height * 0.02, width * 0.044, 0
                          ),
                          child: Container(
                            width: width * 0.91,
                            height: height * 0.06125,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                  Padding(
                                    padding: EdgeInsets.only(left: width * 0.0361),
                                    child: Text(
                                        "서버시간",
                                        style: TextStyle(
                                            fontSize: 20, color: (theme
                                            ?  const Color(0xff000000)
                                            :  const Color(0xffffffff)),
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: width * 0.0361),
                                    child: TimerBuilder.periodic(
                                      const Duration(seconds: 1),
                                      builder: (context) {
                                        return Text(
                                          loadCurrentTime(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (theme
                                              ?  const Color(0xff000000)
                                                :  const Color(0xffffffff)),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ]
                            ),
                            decoration: BoxDecoration(
                                color: (theme
                                    ? const Color(0xffe8e8e8)
                                    : const Color(0xff8AAAE5)),
                                borderRadius: BorderRadius.circular(9)),
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              width * 0.044, height * 0.04125, width * 0.044, 0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    "공지사항",
                                    style: TextStyle(fontSize: 20, color: (theme ? const Color(0xffffffff) : const Color(0xff000000)))
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => const NoticePage()
                                    //     )
                                    // )
                                  },
                                  child: Text(
                                      "+more",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: (theme ? const Color(0xffffffff) : const Color(0xff000000)),
                                      )
                                  ),
                                ),
                              ]
                          )
                      ),
                      Padding(
                          padding : EdgeInsets.fromLTRB(width*0.044, height*0.019, width*0.044, height*0.02875),
                          child : Container(
                              width : width * 0.91,
                              decoration : BoxDecoration(borderRadius: BorderRadius.circular(9), color : (theme ? const Color(0xffe8e8e8) : const Color(0xffffffff)),),
                              child : ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount : notices.length,
                                itemBuilder : (context, index) {
                                  return Container(
                                      alignment: Alignment.centerLeft,
                                      width : width * 0.91,
                                      height : height * 0.065,
                                      child : InkWell(
                                          onTap : () {

                                          },
                                          child : Padding(
                                              padding : EdgeInsets.only(left : width * 0.0361),
                                              child : Text(
                                                  notices[index]['title'],
                                                  style: TextStyle(fontSize: 20, color: (theme ? const Color(0xff000000) : const Color(0xff000000)))
                                              )
                                          )
                                      )
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) => const Divider(
                                  thickness: 1,
                                  height : 0,
                                  color : Color(0x55000000),
                                ),
                              )
                          )
                      ),
                    ],
                  ),
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