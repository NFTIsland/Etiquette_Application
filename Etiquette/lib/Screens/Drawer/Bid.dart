import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/show_ticket_details_dialog.dart';
import 'package:Etiquette/Screens/Market/market_details.dart';

class Bid extends StatefulWidget {
  const Bid({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Bid();
}

class _Bid extends State<Bid> {
  late double width;
  late double height;

  List<String> filter = ['경매 마감 날짜 (오름차순)', '경매 마감 날짜 (내림차순)', '이름 (오름차순)', '이름 (내림차순)'];
  String _selected = '경매 마감 날짜 (오름차순)';
  late bool theme;
  late final Future future;

  List<Map<String, dynamic>> bidlist = [];

  Future<void> getBidlistFromDB() async {
    const url = "$SERVER_IP/individual/bidlist";
    try {
      final kas_address_data = await getKasAddress();

      if (kas_address_data['statusCode'] != 200) {
        await displayDialog_checkonly(context, "입찰 티켓 목록", "보유 티켓 목록을 불러오는데 실패했습니다.");
        return;
      }

      var res = await http.post(Uri.parse(url), body: {
        'kas_address': kas_address_data['data'][0]['kas_address'],
      });
      Map<String, dynamic> data = json.decode(res.body);

      if (res.statusCode != 200) {
        String msg = data['msg'];
        await displayDialog_checkonly(context, "입찰 티켓 목록", msg);
        return;
      }

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
          'auction_end_date': ticket['auction_end_date'],
          'category': ticket['category'],
          'poster_url': ticket['poster_url'],
          'count': ticket['count'],
          'max': ticket['max'],
        };

        if (ticket['poster_url'] == null) {
          if (ticket['category'] == 'movie') {
            ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
          } else {
            ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
          }
        }

        bidlist.add(ex);
        setState(() {});
      }
    } catch (ex) {
      print("입찰 티켓 목록 --> ${ex.toString()}");
    }
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
    getTheme();
    future = getBidlistFromDB();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future : future,
      builder : (context, snapshot) {
        if(snapshot.hasError) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("입찰 티켓 목록", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        } else if(snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: appbarWithArrowBackButton("입찰 티켓 목록", theme),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: DropdownButtonFormField(
                        icon: const Icon(Icons.expand_more),
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    width: 1,
                                    color: Colors.grey,
                                  )
                              ),
                              labelStyle: const TextStyle(
                                  color: Colors.grey
                              ),
                              labelText: 'Filter',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                              )
                          ),
                          value: _selected,
                          items: filter.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(
                                  value,
                                  style: const TextStyle(
                                      fontSize: 15
                                  )
                              ),
                            );
                          }).toList(),
                          onChanged: (dynamic value) {
                            setState(() {
                              _selected = value;
                            });
                          },
                        ),
                    ),
                    Visibility(
                      visible: bidlist.isEmpty,
                      child: SizedBox(
                        height: height - 200,
                        child: const Center(
                          child: Text(
                            "현재 입찰 중인 티켓이 없습니다.",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Divider(
                          height: 31,
                          color: Colors.grey[400],
                        ),
                        SizedBox(
                          height: height - 220,
                          child: ListView.separated(
                            itemCount: bidlist.length,
                            itemBuilder: (ctx, i) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashFactory: InkRipple.splashFactory,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => MarketDetails(
                                          token_id: bidlist[i]['token_id'],
                                          product_name: bidlist[i]['product_name'],
                                          owner: bidlist[i]['owner'],
                                          place: bidlist[i]['place'],
                                          performance_date: bidlist[i]['performance_date'],
                                          seat_class: bidlist[i]['seat_class'],
                                          seat_No: bidlist[i]['seat_No'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget> [
                                      const SizedBox(width: 10),
                                      Image.network(
                                        bidlist[i]['poster_url'],
                                        // 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fkbo_logo.png?alt=media&token=b3a5372d-1e5c-4013-b2d5-1dad86ff4060',
                                        width: 88.18,
                                        height: 130,
                                        fit: BoxFit.fill,
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget> [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget> [
                                                Flexible(
                                                  child: Text(
                                                    bidlist[i]['product_name'],
                                                    style: Theme.of(context).textTheme.subtitle1?.apply(
                                                      color: Colors.black,
                                                      fontWeightDelta: 2,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                IconButton(
                                                  icon: const Icon(Icons.info_outline_rounded),
                                                  iconSize: 25,
                                                  onPressed: () {
                                                    final _width = MediaQuery.of(context).size.width;
                                                    final _height = MediaQuery.of(context).size.height;
                                                    showTicketDetailsDialog(
                                                      context,
                                                      _width,
                                                      _height,
                                                      bidlist[i]['product_name'],
                                                      bidlist[i]['place'],
                                                      bidlist[i]['performance_date'],
                                                      bidlist[i]['seat_class'],
                                                      bidlist[i]['seat_No'],
                                                      bidlist[i]['auction_end_date'],
                                                      bidlist[i]['count'],
                                                      bidlist[i]['max'],
                                                      Colors.cyan
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 14.0),
                                              child: Row(
                                                children: <Widget> [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    bidlist[i]['place'],
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      fontFamily: 'Pretendard',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 14.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget> [
                                                  const Icon(
                                                    Icons.event_seat_outlined,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget> [
                                                        Text(
                                                          "좌석 정보",
                                                          style: TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            color: Colors.grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${bidlist[i]['seat_class']}석 ${bidlist[i]['seat_No']}번",
                                                          style: const TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget> [
                                                  const Icon(
                                                    Icons.access_alarms_outlined,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget> [
                                                        Text(
                                                          "경매 마감 날짜",
                                                          style: TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            color: Colors.grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          bidlist[i]['auction_end_date'].substring(0, 10).replaceAll("-", ".") + " "
                                                              + bidlist[i]['auction_end_date'].substring(11, 16),
                                                          style: const TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(
                                height: 20,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
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