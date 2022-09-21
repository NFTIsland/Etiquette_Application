import 'dart:async';
import 'package:async/async.dart';
import 'dart:convert';
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
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/round.dart';


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
  String yesterday_last = "";
  String? nickname = "";

  List home_posters = [];
  List titles = [];
  List contents = [];
  List upload_times = [];


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
    return "${now.year}.${now.month.toString().padLeft(2, "0")}.${now.day.toString().padLeft(2, "0")}. ${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}:${now.second.toString().padLeft(2, "0")}";
  }

  Future<void> getKlayCurrency() async {
    final res = await http.get(Uri.parse("https://api.coinone.co.kr/ticker?currency=klay"));
    Map<String, dynamic> data = json.decode(res.body);
    if (data["result"] == "success") {
      klayCurrency = data["last"];
      yesterday_last = data["yesterday_last"];
    } else {
      klayCurrency = "Loading...";
      yesterday_last = "Loading...";
    }
  }

  String getStrKlayCurrency() {
    getKlayCurrency();
    if (double.tryParse(klayCurrency) == null) {
      return "Loading...";
    } else {
      return klayCurrency + " ￦";
    }
  }

  Text getUpAndDownRate() {
    double? _klayCurrency = double.tryParse(klayCurrency);
    double? _yesterday_last = double.tryParse(yesterday_last);
    if (_klayCurrency == null || _yesterday_last == null) {
      return const Text(
          "Loading...",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff4bc46d),
          )
      );
    } else {
      double up_and_down_rate = (_klayCurrency - _yesterday_last) * 100 / _yesterday_last;
      if (up_and_down_rate >= 0.0) {
        return Text(
            "${roundDouble(up_and_down_rate, 2)}%",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff4bc46d),
            )
        );
      } else {
        return Text(
            "${roundDouble(up_and_down_rate, 2)}%",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            )
        );
      }
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
          titles.add(_title['title']);
          contents.add(_title['contents']);
          upload_times.add(_title['upload_time'].toString());
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
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget> [
                      SizedBox(
                        width : width,
                        height : height * 0.55,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            viewportFraction: 0.8,
                            aspectRatio: 1.7,
                            height: height * 0.55,
                            enlargeCenterPage: true,
                            autoPlay: true, //자동재생 여부
                          ),
                          items: home_posters.map((item) {
                            return Builder(builder: (BuildContext context) {
                              return Container(
                                width : width,
                                height : height * 0.55,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  //border 를 주기 위해 decoration 사용
                                  border: Border.all(
                                    width: 0,
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
                      Container(
                        width: width * 0.91,
                        height: height * 0.08,
                        margin: const EdgeInsets.fromLTRB(21, 20, 21, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black87.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(1, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget> [
                              Padding(
                                padding: EdgeInsets.only(left: width * 0.0361),
                                child: Image.asset('assets/image/KlaytnLogo.png', width: width * 0.09, height: height * 0.18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget> [
                                    const SizedBox(height: 8),
                                    Row(
                                      children: <Widget> [
                                        Expanded(
                                            child: Text(
                                                "Klaytn",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: (theme ? const Color(0xffffffff) : const Color(0xff000000))
                                                )
                                            )
                                        ),
                                        const SizedBox(width: 5),
                                        TimerBuilder.periodic(
                                          const Duration(seconds: 1),
                                          builder: (context) {
                                            return Text(
                                                getStrKlayCurrency(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    // color: (theme ? const Color(0xff000000) : const Color(0xffffffff))
                                                    color: (theme ? const Color(0xffffffff) : const Color(0xff000000))
                                                )
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              "KLAY",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  // color: (theme ? const Color(0xff000000) : const Color(0xffffffff))
                                                  color: (theme ? const Color(0xffffffff) : Colors.grey)
                                              )
                                          ),
                                        ),
                                        TimerBuilder.periodic(
                                            const Duration(seconds: 1),
                                            builder: (context) {
                                              return getUpAndDownRate();
                                            }
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: width * 0.0361),
                              )
                            ]
                        ),
                      ),
                      Container(
                        width: width * 0.91,
                        height: height * 0.08,
                        margin: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black87.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(1, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: width * 0.0290),
                          child: Row(
                            children: <Widget> [
                              Icon(
                                Icons.access_time_filled_outlined,
                                size: width * 0.09,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget> [
                                    const Text(
                                      "서버시간",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.3
                                      ),
                                    ),
                                    TimerBuilder.periodic(
                                      const Duration(seconds: 1),
                                      builder: (context) {
                                        return Text(
                                          loadCurrentTime(),
                                          style: TextStyle(
                                              fontFamily: "Pretendard",
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: (theme ? const Color(0xff000000) : const Color(0xff2d386b))
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: width * 0.0361),
                              )
                            ],
                          ),
                          // child: Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: <Widget> [
                          //     const SizedBox(height: 5),
                          //     const Text(
                          //       "서버시간",
                          //       style: TextStyle(
                          //           color: Color(0xffff0863),
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.w700,
                          //           letterSpacing: 1.3
                          //       ),
                          //     ),
                          //     const SizedBox(height: 10),
                          //     TimerBuilder.periodic(
                          //       const Duration(seconds: 1),
                          //       builder: (context) {
                          //         return Text(
                          //           loadCurrentTime(),
                          //           style: TextStyle(
                          //               fontFamily: "Pretendard",
                          //               fontWeight: FontWeight.w700,
                          //               fontSize: 16,
                          //               color: (theme ? const Color(0xff000000) : const Color(0xff2d386b))
                          //           ),
                          //         );
                          //       },
                          //     ),
                          //   ],
                          // ),
                        )
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(width * 0.044, height * 0.04125, width * 0.044, 0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    "공지사항",
                                    style: TextStyle( fontFamily : "Pretendard",fontWeight: FontWeight.w500, fontSize: 20, color: (theme ? const Color(0xffffffff) : const Color(0xff000000)))
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
                                  child: const Text(
                                      "+more",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xff5D5D5D),
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
                                itemCount : contents.length,
                                itemBuilder : (context, index) {
                                  return Container(
                                      alignment: Alignment.centerLeft,
                                      width : width * 0.91,
                                      height : height * 0.08,
                                      child : InkWell(
                                          onTap : () {

                                          },
                                          child: Padding(
                                              padding : EdgeInsets.only(left: width * 0.0361, right: width * 0.0361),
                                              child : Padding(
                                                padding: EdgeInsets.fromLTRB(0, height*0.005, 0, height*0.005),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                            titles[index],
                                                            style: TextStyle(fontFamily : "NotoSans", fontWeight : FontWeight.w400,fontSize: 15, color: (theme ? const Color(0xff000000) : const Color(0xff000000)), overflow: TextOverflow.ellipsis)
                                                        ),
                                                        Text(
                                                            upload_times[index],
                                                            style: TextStyle(fontFamily : "NotoSans", fontWeight : FontWeight.w400,fontSize: 7, color: (theme ? const Color(0xff000000) : const Color(0xff000000)))
                                                        )
                                                      ],
                                                    ),
                                                    Padding(
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(
                                                                contents[index],
                                                                style: TextStyle(fontFamily : "NotoSans", fontWeight : FontWeight.w400,fontSize: 10, color: (theme ? const Color(0xff000000) : const Color(0xff000000)), overflow: TextOverflow.ellipsis)
                                                            )
                                                          ]
                                                      ),
                                                      padding : EdgeInsets.fromLTRB(0, height*0.01, 0, height*0.01),
                                                    )],
                                                ),
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
