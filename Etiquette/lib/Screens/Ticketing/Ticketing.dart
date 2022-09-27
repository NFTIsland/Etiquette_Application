import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/Ticketing/total_imminent.dart';
import 'package:Etiquette/Screens/Ticketing/search_ticket.dart';
import 'package:Etiquette/Screens/Ticketing/ticket_details.dart';
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
  List commingsoon = [];
  List deadline = [];
  List banner_posters = [];
  String? nickname = "";
  late double width;
  late double height;

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
            'poster_url': item['poster_url'],
          };

          if (item['poster_url'] == null) {
            if (item['category'] == 'movie') {
              ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
            } else {
              ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
            }
          }

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

  Future<void> getCommingSoonFromDB() async {
    const url = "$SERVER_IP/ticketing/commingSoon";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        List _commingsoon = data["data"];
        for (Map<String, dynamic> item in _commingsoon) {
          final booking_start_date = item['booking_start_date'];

          Map<String, dynamic> ex = {
            'product_name': item['product_name'],
            'booking_start_date': booking_start_date,
            'booking_start_day_of_the_week': DateFormat.E('ko_KR').format(
              DateTime(
                int.parse(booking_start_date.substring(0, 4)),
                int.parse(booking_start_date.substring(5, 7)),
                int.parse(booking_start_date.substring(8, 10)),
              ),
            ),
            'performance_date': item['performance_date'],
            'place': item['place'],
            'poster_url': item['poster_url'],
          };

          if (item['poster_url'] == null) {
            if (item['category'] == 'movie') {
              ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
            } else {
              ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
            }
          }

          commingsoon.add(ex);
          setState(() {});
        }
      } else {
        displayDialog_checkonly(context, "Comming Soon", "서버와의 상태가 원활하지 않습니다.");
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

  Future<void> loadBannerPosters() async {
    const url = "$SERVER_IP/screen/backdropImages";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        for (var _image in data['data']) {
          banner_posters.add(_image['backdrop_url']);
        }
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "Ticketing", msg);
      }
    } catch (ex) {
      displayDialog_checkonly(context, "Ticketing", "네트워크 상태가 원활하지 않습니다.");
    }
  }

  Future<void> getTicketingDataFromDB() async {
    loadBannerPosters();
    getHotPickFromDB();
    getCommingSoonFromDB();
    // getImminentDeadlineFromDB();
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
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("Ticketing", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                  iconTheme: IconThemeData(color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
                  title: Text("Ticketing", style : TextStyle(color: (theme ? const Color(0xffe8e8e8) : Colors.black))),
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
                        Get.to(const TicketingList());
                      },
                    )
                  ]
              ),
              drawer: drawer(context, theme, nickname),
              body: SingleChildScrollView(
                  child: Column(
                      children: <Widget> [
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽에 딱 붙도록 설정
                                children: <Widget> [
                                  SizedBox(height: height*0.025),
                                  const Text(
                                    "Comming soon",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: "Pretendard",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "곧 티켓팅이 시작됩니다!",
                                    style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.025),
                                  (commingsoon.isEmpty) ? Container(
                                    padding : EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                                    width : width * 0.9,
                                    height : width * 0.5,
                                    alignment: Alignment.center,
                                    child : const Text(
                                      "예정된 티켓팅이 없습니다!",
                                      style : TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ) : GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                                        childAspectRatio: 3 / 5,
                                        mainAxisSpacing: height * 0.01, //수평 Padding
                                        crossAxisSpacing: width * 0.05, //수직 Padding
                                      ),
                                      shrinkWrap: true,
                                      itemCount: commingsoon.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          color: Colors.white24,
                                          elevation : 0,
                                          child: InkWell(
                                            highlightColor: Colors.transparent,
                                            splashFactory: InkRipple.splashFactory,
                                            // splashFactory: NoSplash.splashFactory,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => TicketDetails(
                                                    product_name: commingsoon[index]['product_name'],
                                                    place: commingsoon[index]['place'],
                                                    booking_start_date: commingsoon[index]['booking_start_date'],
                                                    booking_start_day_of_the_week: commingsoon[index]['booking_start_day_of_the_week'],
                                                    bottomButtonType: 0,
                                                  ),
                                                ),
                                              );
                                            },
                                            child : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children : <Widget> [
                                                  Expanded(
                                                    flex : 4,
                                                    child: Image.network(
                                                      // "https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fmainlogo.png?alt=media&token=6195fc49-ac21-4641-94d9-1586874ded92",
                                                      commingsoon[index]['poster_url'],
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children : <Widget> [
                                                          Row(
                                                              children: <Widget> [
                                                                Text(
                                                                  "${commingsoon[index]['booking_start_date'].substring(5, 10).replaceAll("-", ".")}",
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Quicksand',
                                                                    color: Colors.grey[600],
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "(${commingsoon[index]['booking_start_day_of_the_week']}) ",
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Quicksand',
                                                                    color: Colors.grey[600],
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${commingsoon[index]['booking_start_date'].substring(11, 16)}에 오픈",
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Quicksand',
                                                                    color: Colors.grey[600],
                                                                  ),
                                                                ),
                                                              ]
                                                          ),
                                                          Text(
                                                            commingsoon[index]['product_name'],
                                                            style: const TextStyle(
                                                              fontFamily: "NotoSans",
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Text(
                                                            commingsoon[index]['place'].toString(),
                                                            style: const TextStyle(
                                                              fontSize: 10,
                                                              fontFamily: "NotoSans",
                                                              color: Colors.grey,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ]
                                                    ),
                                                  ),
                                                ]
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                  SizedBox(height: height*0.05),
                                ]
                            )
                        ),
                        CarouselSlider(
                          options: CarouselOptions(
                            viewportFraction: 1,
                            // height: height * 0.125,
                            // height: height * 0.2,
                            height: height * 0.3,
                            autoPlay: true, //자동재생 여부
                          ),
                          items: banner_posters.map((item) {
                            return Builder(builder: (BuildContext context) {
                              return SizedBox(
                                width : width,
                                child: Image.network(
                                  item,
                                  fit: BoxFit.fill,
                                ),
                              );
                            });
                          }).toList(),
                        ),
                        SizedBox(height: height * 0.05),
                        const Text(
                          "Hot Pick",
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "사람들의 관심도가 높은 티켓을 보여드립니다.",
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: height * 0.025),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                            child : Column(
                                children : <Widget> [
                                  ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: hotpick.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          color: Colors.white24,
                                          elevation : 0,
                                          child: InkWell(
                                            highlightColor: Colors.transparent,
                                            splashFactory: InkRipple.splashFactory,
                                            // splashFactory: NoSplash.splashFactory,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => TicketDetails(
                                                    product_name: hotpick[index]['product_name'],
                                                    place: hotpick[index]['place'],
                                                    bottomButtonType: 1,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: SizedBox(
                                                width: double.infinity,
                                                // height: height * 0.07,
                                                height: 70,
                                                child: Row(
                                                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Image.network(
                                                        hotpick[index]['poster_url'],
                                                        // width: height*0.07,
                                                        // height: height*0.07,
                                                        width: 47.48,
                                                        height: 70,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: <Widget> [
                                                            Container(
                                                              width: height*0.07,
                                                              // height: height*0.07,
                                                              alignment: Alignment.center,
                                                              child : Text(
                                                                (index + 1).toString(),
                                                                style: const TextStyle(
                                                                  // fontFamily: "Pretendard",
                                                                  // fontWeight: FontWeight.w400,
                                                                  // fontSize: 15,
                                                                  fontFamily: "Quicksand",
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 25,
                                                                ),
                                                              ),
                                                            ),
                                                            Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: <Widget> [
                                                                  Text(
                                                                    hotpick[index]['product_name'],
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                      fontFamily: 'NotoSans',
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 12,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 8),
                                                                    child: Text(
                                                                      hotpick[index]['place'].toString(),
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style : const TextStyle(
                                                                        color: Color(0xff7E7E7E),
                                                                        fontFamily: 'NotoSans',
                                                                        fontWeight: FontWeight.w500,
                                                                        fontSize: 10,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                  SizedBox(height: height * 0.05),
                                ]
                            )
                        )
                      ]
                  )
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