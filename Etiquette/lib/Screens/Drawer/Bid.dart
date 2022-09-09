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
    // return "${remaining.inDays}일 ${remaining.inHours % 24}시간 ${remaining.inMinutes % 60}분 남음";
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
              body: Column(
                children: <Widget> [
                  Container(
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: SizedBox(
                          width: 150,
                          height: 60,
                          child: DropdownButtonFormField(
                            icon: const Icon(Icons.expand_more),
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        width: 1,
                                        color: Colors.grey
                                    )
                                ),
                                labelStyle: const TextStyle(
                                    color: Colors.grey
                                ),
                                labelText: 'Filter',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)
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
                          )
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: bidlist.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 0,
                                color: Colors.white24,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => MarketDetails(
                                              token_id: bidlist[index]['token_id'],
                                              product_name: bidlist[index]['product_name'],
                                              owner: bidlist[index]['owner'],
                                              place: bidlist[index]['place'],
                                              performance_date: bidlist[index]['performance_date'],
                                              seat_class: bidlist[index]['seat_class'],
                                              seat_No: bidlist[index]['seat_No'],
                                            )
                                        )
                                    );
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget> [
                                        Container(
                                          width: (width - 20) / 5 * 2,
                                          height: 230,
                                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                          child: Center(
                                            child: Image.network(
                                                'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                            width: (width - 20) / 5 * 3,
                                            height: 230,
                                            child: GridView.count(
                                              crossAxisCount: 2,
                                              childAspectRatio: (width - 20) / 150,
                                              children: <Widget> [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "티켓명",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      bidlist[index]['product_name'],
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "장소",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      bidlist[index]['place'],
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "좌석 등급",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "${bidlist[index]['seat_class']}석",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "좌석 번호",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "${bidlist[index]['seat_No']}번",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "예매 날짜",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      bidlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".")
                                                          + " "
                                                          + bidlist[index]['performance_date'].substring(11, 16),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "경매 마감 날짜",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      bidlist[index]['auction_end_date'].substring(0, 10).replaceAll("-", ".")
                                                          + " " +
                                                          bidlist[index]['auction_end_date'].substring(11, 16),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "남은 시간",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      remainSellingTime(bidlist[index]['auction_end_date']),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "현재 입찰자 수",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "${bidlist[index]['count'].toString()}명",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget> [
                                                    const Text(
                                                      "현재 최고 입찰가",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "${bidlist[index]['max'].toString().replaceAllMapped(reg, mathFunc)} 원",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ],
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
