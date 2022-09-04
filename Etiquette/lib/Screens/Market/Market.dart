import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Screens/Search.dart';
import 'package:Etiquette/Screens/Market/upload_ticket.dart';
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
            'bid_count': item['bid_count']
          };
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
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("Auction"),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
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
              drawer: drawer(context, theme, nickname),
              body: Column(
                children: <Widget> [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                const SizedBox(height: 20),
                                const Text(
                                    "Top 5 Tickets With Many Bidders",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                const Text(
                                    "입찰자가 많은 티켓 상위 5개를 보여드립니다.",
                                    style: TextStyle(
                                      fontSize: 15,
                                    )
                                ),
                                const SizedBox(height: 20),
                                ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: top5RankBid.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                          child: InkWell(
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
                                                  )
                                                )
                                              );
                                            },
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
                                                          height: 40,
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                              children: <Widget>[
                                                                Text(
                                                                  top5RankBid[index]['product_name'],
                                                                  style: const TextStyle(
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  top5RankBid[index]['place'].toString(),
                                                                  style: const TextStyle(
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${top5RankBid[index]['seat_class']}석 ${top5RankBid[index]['seat_No']}번",
                                                                  style: const TextStyle(
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ]
                                                          )
                                                      ),
                                                      Expanded(
                                                          flex: 1,
                                                          child: Center(
                                                            child: Row(
                                                              children: <Widget> [
                                                                Text(
                                                                  top5RankBid[index]['bid_count'].toString(),
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20,
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  "명",
                                                                  style: TextStyle(
                                                                    fontSize: 20,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                      ),
                                                    ]
                                                )
                                            ),
                                          ),
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
                                                builder: (context) => const TotalImminentAuction()
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
                                                              Text("${deadline[index]['seat_class']}석 ${deadline[index]['seat_No']}번",),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchMarketTicket()
                          )
                      );
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