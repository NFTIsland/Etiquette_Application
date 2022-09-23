import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Screens/Market/market_details.dart';
import 'package:get/get.dart';

class Bid extends StatefulWidget {
  const Bid({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Bid();
}

class _Bid extends State<Bid> {
  late double width;
  late double height;

  List<String> filter = ['All', 'High', 'Row', 'Recent', 'Old'];
  String _selected = 'All';
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
          'count': ticket['count'],
          'max': ticket['max'],
        };
        bidlist.add(ex);
        setState(() {});
      }
    } catch (ex) {
      print("입찰 티켓 목록 --> ${ex.toString()}");
    }
  }

  String remainSellingTime(String auction_end_date) {
    final end_year = int.parse(auction_end_date.substring(0, 4));
    final end_month = int.parse(auction_end_date.substring(5, 7));
    final end_day = int.parse(auction_end_date.substring(8, 10));
    final end_hour = int.parse(auction_end_date.substring(11, 13));
    final end_minute = int.parse(auction_end_date.substring(14, 16));
    final remaining = DateTime(end_year, end_month, end_day, end_hour, end_minute).difference(DateTime.now());
    return "${remaining.inDays}일 ${remaining.inHours % 24}시간 ${remaining.inMinutes % 60}분";
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
                      width: 150,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Divider(
                          height: 31,
                          color: Colors.grey[400],
                        ),
                        SizedBox(
                          height: height - 200,
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
                                      Center(
                                        child: Image.network(
                                          // bidlist[i]['poster_url'],
                                          'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fkbo_logo.png?alt=media&token=b3a5372d-1e5c-4013-b2d5-1dad86ff4060',
                                          width: 80,
                                          height: 117.93,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget> [
                                            Text(
                                              bidlist[i]['product_name'],
                                              style: Theme.of(context).textTheme.subtitle1?.apply(
                                                  color: Colors.black,
                                                  fontWeightDelta: 2
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                children: <Widget> [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 7),
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
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                children: <Widget> [
                                                  const Icon(
                                                    Icons.calendar_month,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 7),
                                                  Text(
                                                    bidlist[i]['performance_date'].substring(0, 10).replaceAll("-", ".") + " "
                                                        + bidlist[i]['performance_date'].substring(11, 16),
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
                                              padding: const EdgeInsets.only(top: 15.0),
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
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget> [
                                                  const Icon(
                                                    Icons.access_time_rounded,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget> [
                                                        Text(
                                                          "남은 시간",
                                                          style: TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            color: Colors.grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          remainSellingTime(bidlist[i]['auction_end_date']),
                                                          style: const TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget> [
                                                  bidlist[i]['count'] >= 2 ?
                                                  const Icon(
                                                    Icons.people,
                                                    size: 18,
                                                  ) :
                                                  const Icon(
                                                    Icons.person,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget> [
                                                        Text(
                                                          "현재 입찰자 수",
                                                          style: TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            color: Colors.grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${bidlist[i]['count'].toString()}명",
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
                                                    Icons.money,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget> [
                                                        Text(
                                                          "현재 최고 입찰가",
                                                          style: TextStyle(
                                                            fontFamily: 'Pretendard',
                                                            color: Colors.grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${bidlist[i]['max'].toString().replaceAllMapped(reg, mathFunc)} 원",
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

Widget ticketDetailsWidget(String firstTitle, String firstDesc) {
  return Padding(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          firstTitle,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
            fontFamily: "Pretendard",
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            firstDesc,
            style: TextStyle(
              color: Colors.black,
              fontSize: firstDesc.length >= 11 ? 15 : 17,
              fontWeight: FontWeight.bold,
              fontFamily: "Pretendard",
            ),
          ),
        )
      ],
    ),
  );
}