import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Providers/DB/get_UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Screens/Ticketing/ticket_details.dart';
import 'package:Etiquette/Screens/Market/market_details.dart';

class Interest extends StatefulWidget {
  const Interest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Interest();
}

class _Interest extends State<Interest> with SingleTickerProviderStateMixin {
  late final Future future;
  List<Map<String, dynamic>> interest_ticketing_list = [];
  List<Map<String, dynamic>> interest_auction_list = [];

  late double width;
  late double height;
  late bool theme;

  final _tabbar = GlobalKey();
  late final TabController? tabcontroller;

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getInterestFromDB() async {
    const url_ticketing = "$SERVER_IP/individual/interestTicketinglist";
    final kas_address_data = await getKasAddress();

    if (kas_address_data['statusCode'] != 200) {
      displayDialog_checkonly(context, "관심 티켓 목록", "관심 티켓 목록을 불러오는데 실패했습니다.");
      return;
    }

    final kas_address = kas_address_data['data'][0]['kas_address'];

    try {
      var res = await http.post(Uri.parse(url_ticketing), body: {
        'kas_address': kas_address,
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        List tickets = data["data"];
        for (Map<String, dynamic> ticket in tickets) {
          Map<String, dynamic> ex = {
            'product_name': ticket['product_name'],
            'place': ticket['place'],
            'category': ticket['category'],
            'poster_url': ticket['poster_url'],
          };

          if (ticket['poster_url'] == null) {
            if (ticket['category'] == 'movie') {
              ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
            } else {
              ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
            }
          }

          interest_ticketing_list.add(ex);
          setState(() {});
        }
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "관심 티켓 목록", msg);
        return;
      }
    } catch (ex) {
      print("관심 티켓 목록(티켓팅) --> ${ex.toString()}");
      return;
    }

    const url_auction = "$SERVER_IP/individual/interestAuctionlist";
    try {
      var res = await http.post(Uri.parse(url_auction), body: {
        'kas_address': kas_address,
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        List tickets = data["data"];
        for (Map<String, dynamic> ticket in tickets) {
          Map<String, dynamic> ex = {
            'token_id': ticket['token_id'],
            'product_name': ticket['product_name'],
            'owner': ticket['owner'],
            'place': ticket['place'],
            'performance_date': ticket['performance_date'],
            'seat_class': ticket['seat_class'],
            'seat_No': ticket['seat_No'],
            'category': ticket['category'],
            'poster_url': ticket['poster_url'],
          };

          if (ticket['poster_url'] == null) {
            if (ticket['category'] == 'movie') {
              ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
            } else {
              ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
            }
          }

          interest_auction_list.add(ex);
          setState(() {});
        }
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "관심 티켓 목록", msg);
      }
    } catch (ex) {
      print("관심 티켓 목록(옥션) --> ${ex.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    tabcontroller = TabController(
      length: 2,
      vsync: this,
      animationDuration: Duration.zero,
    );
    future = getInterestFromDB();
  }

  @override
  void dispose() {
    tabcontroller!.dispose();
    super.dispose();
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
              appBar: appbarWithArrowBackButton("관심 티켓", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("관심 티켓", theme),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget> [
                    const SizedBox(height: 10),
                    Container(
                      key: _tabbar,
                      alignment: Alignment.topCenter,
                      width: width * 0.9,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: (theme ? const Color(0xffe8e8e8) : const Color(0xffffffff)),
                      ),
                      child: TabBar(
                        indicator: (tabcontroller!.index == 0) ?
                        const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(9),
                            topLeft: Radius.circular(9),
                          ),
                          color: Color(0xff333333),
                        ) :
                        const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(9),
                            topRight: Radius.circular(9),
                          ),
                          color: Color(0xff333333),
                        ),
                        indicatorPadding: EdgeInsets.zero,
                        labelPadding: EdgeInsets.zero,
                        controller: tabcontroller,
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w500,
                        ),
                        unselectedLabelColor: Colors.black,
                        labelColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: [
                          Container(
                            height: 70,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.shopping_bag_outlined),
                                Text(
                                  '티켓팅',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 70,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.back_hand_rounded),
                                Text(
                                  '옥션',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onTap: (int idx) {
                          setState(() {
                            tabcontroller!.index = idx;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: interest_ticketing_list.isEmpty,
                      child: SizedBox(
                        height: height - 200,
                        child: const Center(
                          child: Text(
                            "관심 목록이 없습니다.",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        SizedBox(
                          height: height - 220,
                          child: TabBarView(
                            controller: tabcontroller,
                            children: <Widget> [
                              // 티켓팅
                              ListView.separated(
                                itemCount: interest_ticketing_list.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashFactory: InkRipple.splashFactory,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => TicketDetails(
                                              product_name: interest_ticketing_list[index]['product_name'],
                                              place: interest_ticketing_list[index]['place'],
                                              bottomButtonType: 1,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget> [
                                          const SizedBox(width: 5),
                                          Image.network(
                                            interest_ticketing_list[index]['poster_url'],
                                            width: 67.83,
                                            height: 100,
                                            fit: BoxFit.fill,
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget> [
                                                Text(
                                                  interest_ticketing_list[index]['product_name'],
                                                  style: const TextStyle(
                                                    fontFamily: 'NotoSans',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 14),
                                                  child: Text(
                                                    interest_ticketing_list[index]['place'],
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      fontFamily: 'Pretendard',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15),
                                    child: Divider(
                                      height: 20,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              ),
                              // 옥션
                              ListView.separated(
                                itemCount: interest_auction_list.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashFactory: InkRipple.splashFactory,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MarketDetails(
                                              token_id: interest_auction_list[index]['token_id'],
                                              product_name: interest_auction_list[index]['product_name'],
                                              owner: interest_auction_list[index]['owner'],
                                              place: interest_auction_list[index]['place'],
                                              performance_date: interest_auction_list[index]['performance_date'],
                                              seat_class: interest_auction_list[index]['seat_class'],
                                              seat_No: interest_auction_list[index]['seat_No'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget> [
                                          const SizedBox(width: 5),
                                          Image.network(
                                            interest_auction_list[index]['poster_url'],
                                            width: 88.18,
                                            height: 130,
                                            fit: BoxFit.fill,
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget> [
                                                Text(
                                                  interest_auction_list[index]['product_name'],
                                                  style: const TextStyle(
                                                    fontFamily: 'NotoSans',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 14),
                                                  child: Text(
                                                    interest_auction_list[index]['place'],
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      fontFamily: 'Pretendard',
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 14),
                                                  child: Text(
                                                    "${interest_auction_list[index]['seat_class']}석 ${interest_auction_list[index]['seat_No']}번",
                                                    style: const TextStyle(
                                                      fontFamily: 'NotoSans',
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 14),
                                                  child: Text(
                                                    interest_auction_list[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + interest_auction_list[index]['performance_date'].substring(11, 16),
                                                    style: const TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15),
                                    child: Divider(
                                      height: 20,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
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
