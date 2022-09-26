import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/Market/search_market_ticket.dart';
import 'package:Etiquette/Screens/Market/market_details.dart';
import 'package:Etiquette/Screens/Market/total_imminent_auction.dart';
import 'package:Etiquette/widgets/drawer.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';

class Market extends StatefulWidget {
  const Market({Key? key}) : super(key: key);

  @override
  State createState() => _Market();
}

class _Market extends State<Market> {
  bool ala = true;
  late bool theme;
  var img = const Icon(Icons.notifications);
  List top5RankBid = [];
  List deadline = [];
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

  Future<void> getTop5RankBidFromDB() async {
    const url = "$SERVER_IP/market/top5RankBid";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        List _top5RankBid = data["data"];
        for (Map<String, dynamic> item in _top5RankBid) {
          Map<String, dynamic> ex = {
            'token_id': item['token_id'],
            'product_name': item['product_name'],
            'owner': item['owner'],
            'place': item['place'],
            'performance_date': item['performance_date'],
            'seat_class': item['seat_class'],
            'seat_No': item['seat_No'],
            'bid_count': item['bid_count'],
            'poster_url': item['poster_url'],
          };

          if (item['poster_url'] == null) {
            if (item['category'] == 'movie') {
              ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
            } else {
              ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
            }
          }

          top5RankBid.add(ex);
          setState(() {});
        }
      } else {
        displayDialog_checkonly(context, "Top 5 Rank Bid", "서버와의 상태가 원활하지 않습니다.");
      }
    } catch (ex) {
      String msg = ex.toString();
      displayDialog_checkonly(context, "Top 5 Rank Bid", msg);
    }
  }

  Future<void> getImminentDeadlineFromDB() async {
    const url = "$SERVER_IP/market/deadLineTop5Auction";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        List _deadline = data["data"];
        for (Map<String, dynamic> item in _deadline) {
          Map<String, dynamic> ex = {
            'product_name': item['product_name'],
            'place': item['place'],
            'seat_class': item['seat_class'],
            'seat_No': item['seat_No'],
            'performance_date': item['performance_date'],
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
    getTop5RankBidFromDB();
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

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
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
              appBar: appbarWithArrowBackButton("Auction", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                  iconTheme: IconThemeData(color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
                  title: Text("Auction", style : TextStyle(color: (theme ? const Color(0xffe8e8e8) : Colors.black))),
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
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        Get.to(const SearchMarketTicket());
                      },
                    )
                  ]
              ),
              drawer: drawer(context, theme, nickname),
              body: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        SizedBox(height: height * 0.025),
                        const Text(
                            "Top 5 Tickets With Many Bidders",
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                        ),
                        const Text(
                            "입찰자가 많은 티켓 상위 5개를 보여드립니다.",
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                        ),
                        SizedBox(height: height * 0.025),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: top5RankBid.length,
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
                                        builder: (context) => MarketDetails(
                                          token_id: top5RankBid[index]['token_id'],
                                          product_name: top5RankBid[index]['product_name'],
                                          owner: top5RankBid[index]['owner'],
                                          place: top5RankBid[index]['place'],
                                          performance_date: top5RankBid[index]['performance_date'],
                                          seat_class: top5RankBid[index]['seat_class'],
                                          seat_No: top5RankBid[index]['seat_No'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 70,
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget> [
                                            Image.network(
                                              top5RankBid[index]['poster_url'],
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
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget> [
                                                  Container(
                                                    width: height * 0.05,
                                                    // height: height * 0.07,
                                                    height: 70,
                                                    alignment: Alignment.center,
                                                    child : Text(
                                                      (index + 1).toString(),
                                                      style: const TextStyle(
                                                        fontFamily: "Quicksand",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.5,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget> [
                                                        Text(
                                                          top5RankBid[index]['product_name'],
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
                                                            top5RankBid[index]['place'].toString(),
                                                            style: const TextStyle(
                                                              color: Color(0xff7E7E7E),
                                                              fontFamily: 'NotoSans',
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 9,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 8),
                                                          child: Text(
                                                            "${top5RankBid[index]['seat_class']}석 ${top5RankBid[index]['seat_No']}번",
                                                            style: const TextStyle(
                                                              color: Color(0xff7E7E7E),
                                                              fontFamily: 'NotoSans',
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 10,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: <Widget> [
                                                        Text(
                                                          top5RankBid[index]['bid_count'].toString(),
                                                          style: const TextStyle(
                                                            fontFamily: "Pretendard",
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const Text(
                                                          "명",
                                                          style: TextStyle(
                                                            fontFamily: "Pretendard",
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
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
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children : <Widget>[
                              const Text(
                                  "Deadline Imminent",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.bold,
                                  )
                              ),
                              TextButton(
                                child: const Text(
                                    "+ 더보기",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff5D5D5D),
                                    )
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const TotalImminentAuction()
                                      )
                                  );
                                },
                              )
                            ]
                        ),
                        const Text(
                          "마감 시각이 임박한 티켓들을 보여드립니다.",
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: height * 0.025),
                        (deadline.length! == 0) ?
                        (
                            Container(
                              padding : EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                              width : width*0.9,
                              height : width*0.5,
                              alignment: Alignment.center,
                              child : const Text(
                                "마감이 임박한 티켓이 없습니다!",
                                style : TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            )
                        )
                            :
                        (
                            GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                                  childAspectRatio: 3 / 5.5,
                                  mainAxisSpacing: height * 0.01, //수평 Padding
                                  crossAxisSpacing: width * 0.05, //수직 Padding
                                ),
                                shrinkWrap: true,
                                itemCount: deadline.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    color: Colors.white24,
                                    elevation : 0,
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashFactory: NoSplash.splashFactory,
                                      onTap: () {

                                      },
                                      child : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children : <Widget> [
                                            Expanded(
                                              flex : 3,
                                              child: Image.network(
                                                "https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fmainlogo.png?alt=media&token=6195fc49-ac21-4641-94d9-1586874ded92",
                                                fit: BoxFit.fill,
                                                //color: Colors.blue,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children : <Widget> [
                                                    Row(
                                                        children : <Widget> [
                                                          //Text(deadline[index]['performance_date'])
                                                          Text(
                                                            "14:00",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            " | 12.31",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ]
                                                    ),
                                                    Text(
                                                      deadline[index]['product_name'],
                                                      style: const TextStyle(
                                                        fontFamily: "NotoSans",
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      deadline[index]['place'].toString(),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontFamily: "NotoSans",
                                                        color: Colors.grey,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${deadline[index]['seat_class']}석 ${deadline[index]['seat_No']}번",
                                                      style : const TextStyle(
                                                        fontFamily: "NotoSans",
                                                        fontSize: 10,
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
                            )
                        ),
                        SizedBox(height: height*0.05),
                                /*
                                                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget> [
                                    const Text(
                                        "Deadline Imminent",
                                        style: TextStyle(
                                            fontSize: 20,
                                          fontFamily: "Pretendard",
                                          fontWeight: FontWeight.bold,
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
                                                builder: (context) => const TotalImminentAuction()
                                            )
                                        );
                                      },
                                    )
                                  ],
                                ),
                                const Text(
                                    "마감 시각이 임박한 티켓들을 보여드립니다.",
                                    style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    )
                                ),
                                SizedBox(height: height*0.025),
                                ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: deadline.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                          color: Colors.white24,
                                          elevation : 0,
                                          child: InkWell
                                          (
                                            highlightColor: Colors.transparent,
                                            splashFactory: NoSplash.splashFactory,
                                            onTap :(){
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => MarketDetails(
                                                        token_id: deadline[index]['token_id'],
                                                        product_name: deadline[index]['product_name'],
                                                        owner: deadline[index]['owner'],
                                                        place: deadline[index]['place'],
                                                        performance_date: deadline[index]['performance_date'],
                                                        seat_class: deadline[index]['seat_class'],
                                                        seat_No: deadline[index]['seat_No'],
                                                      )
                                                  )
                                              );
                                            },
                                          child : SizedBox(
                                              width: double.infinity,
                                              height : height*0.07,
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget> [
                                                    Image.network(
                                                      "https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg",
                                                      width: height*0.07,
                                                      height: height*0.07,
                                                      fit: BoxFit.fill,
                                                    ),
                                                    SizedBox(width : height*0.07),
                                                    Expanded(
                                                        child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(deadline[index]['product_name']),
                                                              Text(deadline[index]['place']),
                                                              Text("${deadline[index]['seat_class']}석 ${deadline[index]['seat_No']}번",),
                                                            ]
                                                        )
                                                    )
                                                  ]
                                              )
                                          ),
                                      )
                                      );
                                    }
                                ),
                                SizedBox(height: height*0.025),
                                 */
                              ]
                          ),
                        ),
                    ),

              /*
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget> [
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
              */
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