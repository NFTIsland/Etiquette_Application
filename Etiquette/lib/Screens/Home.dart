import 'dart:async';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/Providers/DB/get_UserInfo.dart';
import 'package:Etiquette/Providers/KAS/Wallet/get_balance.dart';

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
  String hold_counts = "";
  String auction_counts = "";
  String? nickname = "";
  late final String address;

  List home_posters = [];
  List titles = [];
  List contents = [];
  List upload_times = [];

  double current_klay = 0.0;

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
    // currentTime = "${now.year}??? ${now.month}??? ${now.day}??? ${now.hour}??? ${now.minute}??? ${now.second}???";
    return "${now.year}.${now.month.toString().padLeft(2, "0")}.${now.day.toString().padLeft(2, "0")}. ${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}:${now.second.toString().padLeft(2, "0")}";
  }

  Future<void> loadKlayBalance() async {
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      address = kas_address_data['data'][0]['kas_address'];
      Map<String, dynamic> data = await getBalance(address);
      if (data["statusCode"] == 200) {
        double _klay = double.parse(data["data"]);
        _klay = roundDouble(_klay, 2);
        setState(() {
          current_klay = _klay;
        });
      } else {
        String message = data["msg"];
        String errorMessage = "?????? ????????? ???????????? ???????????????.\n\n$message";
        displayDialog_checkonly(context, "?????? ??????", errorMessage);
      }
    } else {
      String message = kas_address_data["msg"];
      String errorMessage = "?????? ????????? ???????????? ???????????????.\n\n$message";
      displayDialog_checkonly(context, "?????? ??????", errorMessage);
    }
  }

  Future<void> getKlayCurrency() async {
    final res = await http
        .get(Uri.parse("https://api.coinone.co.kr/ticker?currency=klay"));
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
      return klayCurrency + " ???";
    }
  }

  Text getUpAndDownRate() {
    double? _klayCurrency = double.tryParse(klayCurrency);
    double? _yesterday_last = double.tryParse(yesterday_last);
    if (_klayCurrency == null || _yesterday_last == null) {
      return const Text("Loading...",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff147814),
          ));
    } else {
      double up_and_down_rate =
          (_klayCurrency - _yesterday_last) * 100 / _yesterday_last;
      if (up_and_down_rate >= 0.0) {
        return Text("${roundDouble(up_and_down_rate, 2)}%",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff147814),
            ));
      } else {
        return Text("${roundDouble(up_and_down_rate, 2)}%",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ));
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
      displayDialog_checkonly(context, "Home", "???????????? ????????? ???????????? ????????????.");
    }
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
      displayDialog_checkonly(context, "Home", "???????????? ????????? ???????????? ????????????.");
    }
  }

  _fetchData() async {
    return this._memoizer.runOnce(() async {
      _loadData();
      loadHomePosters();
      getHomeNotices();
      loadKlayBalance();
      List<String?> Infolist = await getInfo();
      nickname = Infolist[1];
      hold_counts = await getHoldCounts();
      auction_counts = await getAuctionCounts();
      await Future.delayed(const Duration(milliseconds: 1000));
      return;
    });
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
                child: Text("?????? ????????? ??????????????????."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                    iconTheme: IconThemeData(color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
                    title: Text("Etiquette", style: TextStyle(color: (theme ? const Color(0xffe8e8e8) : Colors.black))),
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.black,
                    elevation: 0, // elevation??? ???????????? ?????? ???????????? ???, 0?????? ?????? ?????? ??????, foreground??? ?????? ??? ??????
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
                    ]),
                drawer: drawer(context, theme, nickname),
                body: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Center(
                        child: SizedBox(
                          width: width * 0.3,
                          height: height * 0.1,
                          child: Image.asset('assets/image/today_pick.png', fit: BoxFit.contain),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        height: height * 0.55,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            viewportFraction: 0.8,
                            aspectRatio: 1.7,
                            height: height * 0.55,
                            enlargeCenterPage: true,
                            autoPlay: true, //???????????? ??????
                          ),
                          items: home_posters.map((item) {
                            return Builder(builder: (BuildContext context) {
                              return Container(
                                width: width,
                                height: height * 0.55,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  //border ??? ?????? ?????? decoration ??????
                                  border: Border.all(
                                    width: 0,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: ClipRRect(
                                  //ClipRRect : ?????? ????????? ????????? ???????????? ???????????? ??????
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Image.network(item, fit: BoxFit.fill,),
                                ),
                              );
                            });
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height : 10),
                      Container(
                        height : height*0.01,decoration: BoxDecoration(
                          border: const Border(
                              top: BorderSide(width : 1, color: Color(0xffC4C4C4)
                              )
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 0,
                              offset: const Offset(0, 0), // changes position of shadow
                            ),
                          ]),
                      ),
                      Container(
                        width: width * 0.91,
                        height: height * 0.15,
                        margin: EdgeInsets.fromLTRB(21, height * 0.015 , 21, 0),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(0xffFFDAB9),
                                Color(0xffFF7F50),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black87.withOpacity(0.4),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(1, 1), // changes position of shadow
                              ),
                            ]
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(nickname!, style: TextStyle(
                                          fontFamily: "Square",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30,
                                          color: (theme ? const Color(0xffffffff) : const Color(0xff000000))),),
                                      Text(" ?????? Etiquette", style: TextStyle(
                                          fontFamily: "Square",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          color: (theme ? const Color(0xffffffff) : const Color(0xff000000))),)
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      children: <Widget>[
                                        Text("?????? ?????? ??????", style: TextStyle(
                                            fontFamily: "Square",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: (theme ? const Color(0xffffffff) : Color(0xff000000)))),
                                        Text(hold_counts, style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: (theme ? const Color(0xffffffff) : Color(0xff5a5a5a))))
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      children: <Widget>[
                                        Text("?????? ???????????? ??????", style: TextStyle(
                                            fontFamily: "Square",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: (theme ? const Color(0xffffffff) : Color(0xff000000)))),
                                        Text(auction_counts.toString(), style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: (theme ? const Color(0xffffffff) : Color(0xff5a5a5a))))
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      children: <Widget>[
                                        Text("?????? ?????? KLAY", style: TextStyle(
                                            fontFamily: "Square",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: (theme ? const Color(0xffffffff) : Color(0xff000000)))),
                                        Text(current_klay.toString(), style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: (theme ? const Color(0xffffffff) : Color(0xff5a5a5a))))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                      Container(
                        width: width * 0.91,
                        height: height * 0.08,
                        margin: const EdgeInsets.fromLTRB(21, 10, 21, 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xffF4FFFF),
                              Color(0xff5AD2FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black87.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset:
                              const Offset(1, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: width * 0.0361),
                                child: Image.asset('assets/image/KlaytnLogo.png',
                                    width: width * 0.09, height: height * 0.18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Text("Klaytn",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: (theme ? const Color(0xffffffff) : const Color(0xff000000))))),
                                        const SizedBox(width: 5),
                                        TimerBuilder.periodic(
                                          const Duration(seconds: 1),
                                          builder: (context) {
                                            return Text(getStrKlayCurrency(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: (theme ? const Color(0xffffffff) : const Color(0xff000000))));
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text("KLAY",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: (theme ? const Color(0xffffffff) : Color(0xff5a5a5a)))),
                                        ),
                                        TimerBuilder.periodic(
                                            const Duration(seconds: 1),
                                            builder: (context) {
                                              return getUpAndDownRate();
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: width * 0.0361),
                              )
                            ]),
                      ),
                      Container(
                          width: width * 0.91,
                          height: height * 0.08,
                          margin: EdgeInsets.fromLTRB(21, 0, 21, height * 0.015),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(0xffFFDCFF),
                                Color(0xffFF4646),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black87.withOpacity(0.4),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: width * 0.0290),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.access_time_filled_outlined,
                                  size: width * 0.09,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "????????????",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.3),
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
                                                color: (theme ? const Color(0xff000000) : const Color(0xff2d386b))),
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
                          )),
                      Container(
                        height : height*0.01,decoration: BoxDecoration(
                          border: const Border(
                              top: BorderSide(
                                  width : 1,
                                  color: Color(0xffC4C4C4)
                              )
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 0,
                              offset: const Offset(0, 0), // changes position of shadow
                            ),
                          ]),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              width * 0.044, height * 0.01125, width * 0.044, 0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("????????????",
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: (theme ? const Color(0xffffffff) : const Color(0xff000000)))),
                                TextButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => const NoticePage()
                                    //     )
                                    // )
                                  },
                                  child: const Text("+more",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xff5D5D5D),
                                      )),
                                ),
                              ])),
                      Padding(
                        padding: EdgeInsets.fromLTRB(width * 0.044, height * 0.019,
                            width * 0.044, height * 0.02875),
                        child: Container(
                            width: width * 0.91,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: (theme
                                  ? const Color(0xffe8e8e8)
                                  : const Color(0xffffffff)),
                            ),
                            child: ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                const Divider(thickness: 2),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: contents.length,
                                itemBuilder: (context, index) {
                                  return Theme(
                                      data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                          backgroundColor: Colors.white,
                                          collapsedBackgroundColor: Colors.white,
                                          title: Text(titles[index],
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20,
                                                  color: (theme ? const Color(0xff000000) : const Color(0xff000000)),
                                                  overflow: TextOverflow.ellipsis)),
                                          subtitle: Text(upload_times[index],
                                              style: TextStyle(
                                                  fontFamily: "NotoSans",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  color: (theme ? const Color(0xff000000) : const Color(0xff000000)),
                                                  overflow: TextOverflow.ellipsis)),
                                          children: <Widget>[
                                            Container(
                                                width: width * 0.8,
                                                child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Flexible(
                                                          child: Text(
                                                              contents[index],
                                                              softWrap: true,
                                                              maxLines: 40,
                                                              style: TextStyle(
                                                                  fontFamily: "NotoSans",
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 15,
                                                                  color: (theme ? const Color(0xff000000) : const Color(0xff000000)))))
                                                    ]))
                                          ]));
                                })),
                      ),
                    ])));
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

_delToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.deleteToken();
  print("deleting token");
}
