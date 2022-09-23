import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Screens/Market/auction_status.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';

class Selling extends StatefulWidget {
  const Selling({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Selling();
}

class _Selling extends State<Selling> {
  late double width;
  late double height;
  late final Future future;
  late bool theme;

  List<Map<String, dynamic>> sellinglist = [];

  List<String> filter = ['All', 'High', 'Row', 'Recent', 'Old'];
  String _selected = 'All';

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getSellinglistFromDB() async {
    const url = "$SERVER_IP/individual/sellinglist";
    try {
      final kas_address_data = await getKasAddress();
      if (kas_address_data['statusCode'] == 200) {
        var res = await http.post(Uri.parse(url), body: {
          'kas_address': kas_address_data['data'][0]['kas_address'],
        });
        Map<String, dynamic> data = json.decode(res.body);
        if (res.statusCode == 200) {
          List tickets = data["data"];
          for (Map<String, dynamic> ticket in tickets) {
            Map<String, dynamic> ex = {
              'token_id': ticket['token_id'],
              'product_name': ticket['product_name'],
              'place': ticket['place'],
              'seat_class': ticket['seat_class'],
              'seat_No': ticket['seat_No'],
              'performance_date': ticket['performance_date'],
              'auction_end_date': ticket['auction_end_date'],
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

            sellinglist.add(ex);
            setState(() {});
          }
        } else {
          String msg = data['msg'];
          displayDialog_checkonly(context, "판매 중 티켓 목록", msg);
        }
      } else {
        displayDialog_checkonly(context, "판매 중 티켓 목록", "보유 티켓 목록을 불러오는데 실패했습니다.");
      }
    } catch (ex) {
      print("판매 중 티켓 목록 --> ${ex.toString()}");
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

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getSellinglistFromDB();
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
            appBar: appbarWithArrowBackButton("판매 중 티켓", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("판매 중 티켓", theme),
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
                    Visibility(
                      visible: sellinglist.isEmpty,
                      child: SizedBox(
                        height: height - 200,
                        child: const Center(
                          child: Text(
                            "현재 판매 중인 티켓이 없습니다.",
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
                            itemCount: sellinglist.length,
                            itemBuilder: (ctx, i) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashFactory: InkRipple.splashFactory,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AuctionStatus(
                                          token_id: sellinglist[i]['token_id'],
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
                                        sellinglist[i]['poster_url'],
                                        // 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fkbo_logo.png?alt=media&token=b3a5372d-1e5c-4013-b2d5-1dad86ff4060',
                                        // width: 80,
                                        // height: 117.93,
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
                                                    sellinglist[i]['product_name'],
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
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Center(
                                                            child: Text(
                                                              "티켓 정보",
                                                              style: TextStyle(
                                                                fontFamily: "Pretendard",
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 19,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(32.0),
                                                            ),
                                                          ),
                                                          content: SizedBox(
                                                            height: 360,
                                                            width: _width - 10,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: <Widget> [
                                                                Text(
                                                                  sellinglist[i]['product_name'],
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Pretendard',
                                                                    fontSize: sellinglist[i]['product_name'].length >= 11 ? 15 : 20,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 14.0),
                                                                  child: Row(
                                                                    children: <Widget> [
                                                                      const Icon(
                                                                        Icons.location_on_outlined,
                                                                        size: 18,
                                                                      ),
                                                                      const SizedBox(width: 7),
                                                                      Text(
                                                                        sellinglist[i]['place'],
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
                                                                    children: <Widget> [
                                                                      const Icon(
                                                                        Icons.calendar_month,
                                                                        size: 18,
                                                                      ),
                                                                      const SizedBox(width: 7),
                                                                      Text(
                                                                        sellinglist[i]['performance_date'].substring(0, 10).replaceAll("-", ".") + " "
                                                                            + sellinglist[i]['performance_date'].substring(11, 16),
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
                                                                              "${sellinglist[i]['seat_class']}석 ${sellinglist[i]['seat_No']}번",
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
                                                                              sellinglist[i]['auction_end_date'].substring(0, 10).replaceAll("-", ".") + " "
                                                                                  + sellinglist[i]['auction_end_date'].substring(11, 16),
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
                                                                              remainSellingTime(sellinglist[i]['auction_end_date']),
                                                                              style: TextStyle(
                                                                                fontFamily: 'Pretendard',
                                                                                fontWeight: FontWeight.bold,
                                                                                color: (int.parse(remainSellingTime(sellinglist[i]['auction_end_date']).split("일")[0])) < 1 ? Colors.red : Colors.black,
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
                                                                      sellinglist[i]['count'] >= 2 ?
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
                                                                              "${sellinglist[i]['count'].toString()}명",
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
                                                                              "${sellinglist[i]['max'].toString().replaceAllMapped(reg, mathFunc)} 원",
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
                                                                const SizedBox(height: 10),
                                                                Container(
                                                                  padding: EdgeInsets.fromLTRB(_width * 0.03, _height * 0.01, _width * 0.03, _height * 0.011),
                                                                  width: _width,
                                                                  height: 80,
                                                                  child: CupertinoButton(
                                                                    padding: const EdgeInsets.all(10),
                                                                    borderRadius: BorderRadius.circular(50),
                                                                    color: Colors.green,
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                    child: const Text(
                                                                      "확인",
                                                                      style: TextStyle(
                                                                        fontFamily: "Pretendard",
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 16,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                children: <Widget> [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    sellinglist[i]['place'],
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
                                            // Padding(
                                            //   padding: const EdgeInsets.only(top: 15.0),
                                            //   child: Row(
                                            //     children: <Widget> [
                                            //       const Icon(
                                            //         Icons.calendar_month,
                                            //         size: 18,
                                            //       ),
                                            //       const SizedBox(width: 7),
                                            //       Text(
                                            //         sellinglist[i]['performance_date'].substring(0, 10).replaceAll("-", ".") + " "
                                            //             + sellinglist[i]['performance_date'].substring(11, 16),
                                            //         style: TextStyle(
                                            //           color: Colors.grey[600],
                                            //           fontWeight: FontWeight.bold,
                                            //           fontSize: 13,
                                            //           fontFamily: 'Pretendard',
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
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
                                                          "${sellinglist[i]['seat_class']}석 ${sellinglist[i]['seat_No']}번",
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
                                                          sellinglist[i]['auction_end_date'].substring(0, 10).replaceAll("-", ".") + " "
                                                              + sellinglist[i]['auction_end_date'].substring(11, 16),
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
                                            // Padding(
                                            //   padding: const EdgeInsets.only(top: 15.0),
                                            //   child: Row(
                                            //     mainAxisAlignment: MainAxisAlignment.start,
                                            //     children: <Widget> [
                                            //       const Icon(
                                            //         Icons.access_time_rounded,
                                            //         size: 18,
                                            //       ),
                                            //       const SizedBox(width: 5),
                                            //       Expanded(
                                            //         flex: 1,
                                            //         child: Row(
                                            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //           children: <Widget> [
                                            //             Text(
                                            //               "남은 시간",
                                            //               style: TextStyle(
                                            //                 fontFamily: 'Pretendard',
                                            //                 color: Colors.grey[600],
                                            //                 fontSize: 14,
                                            //               ),
                                            //             ),
                                            //             Text(
                                            //               remainSellingTime(sellinglist[i]['auction_end_date']),
                                            //               style: const TextStyle(
                                            //                 fontFamily: 'Pretendard',
                                            //                 fontWeight: FontWeight.bold,
                                            //                 color: Colors.black,
                                            //                 fontSize: 14,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       )
                                            //     ],
                                            //   ),
                                            // ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(top: 15.0),
                                            //   child: Row(
                                            //     mainAxisAlignment: MainAxisAlignment.start,
                                            //     children: <Widget> [
                                            //       sellinglist[i]['count'] >= 2 ?
                                            //       const Icon(
                                            //         Icons.people,
                                            //         size: 18,
                                            //       ) :
                                            //       const Icon(
                                            //         Icons.person,
                                            //         size: 18,
                                            //       ),
                                            //       const SizedBox(width: 5),
                                            //       Expanded(
                                            //         flex: 1,
                                            //         child: Row(
                                            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //           children: <Widget> [
                                            //             Text(
                                            //               "현재 입찰자 수",
                                            //               style: TextStyle(
                                            //                 fontFamily: 'Pretendard',
                                            //                 color: Colors.grey[600],
                                            //                 fontSize: 14,
                                            //               ),
                                            //             ),
                                            //             Text(
                                            //               "${sellinglist[i]['count'].toString()}명",
                                            //               style: const TextStyle(
                                            //                 fontFamily: 'Pretendard',
                                            //                 fontWeight: FontWeight.bold,
                                            //                 color: Colors.black,
                                            //                 fontSize: 14,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(top: 15.0),
                                            //   child: Row(
                                            //     mainAxisAlignment: MainAxisAlignment.start,
                                            //     children: <Widget> [
                                            //       const Icon(
                                            //         Icons.money,
                                            //         size: 18,
                                            //       ),
                                            //       const SizedBox(width: 5),
                                            //       Expanded(
                                            //         flex: 1,
                                            //         child: Row(
                                            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //           children: <Widget> [
                                            //             Text(
                                            //               "현재 최고 입찰가",
                                            //               style: TextStyle(
                                            //                 fontFamily: 'Pretendard',
                                            //                 color: Colors.grey[600],
                                            //                 fontSize: 14,
                                            //               ),
                                            //             ),
                                            //             Text(
                                            //               "${sellinglist[i]['max'].toString().replaceAllMapped(reg, mathFunc)} 원",
                                            //               style: const TextStyle(
                                            //                 fontFamily: 'Pretendard',
                                            //                 fontWeight: FontWeight.bold,
                                            //                 color: Colors.black,
                                            //                 fontSize: 14,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(
                                height: 20,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    // Expanded(
                    //   child: SingleChildScrollView(
                    //     child: Center(
                    //       child: ListView.builder(
                    //           physics: const NeverScrollableScrollPhysics(),
                    //           shrinkWrap: true,
                    //           itemCount: sellinglist.length,
                    //           itemBuilder: (context, index) {
                    //             return Card(
                    //               elevation: 0,
                    //               color: Colors.white24,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //               margin: const EdgeInsets.symmetric(
                    //                 vertical: 10,
                    //                 horizontal: 10,
                    //               ),
                    //               child: InkWell(
                    //                 highlightColor: Colors.transparent,
                    //                 splashFactory: NoSplash.splashFactory,
                    //                 onTap: () {
                    //                   Navigator.of(context).push(
                    //                       MaterialPageRoute(
                    //                           builder: (context) => AuctionStatus(
                    //                             token_id: sellinglist[index]['token_id'],
                    //                           )
                    //                       )
                    //                   );
                    //                 },
                    //                 child: SizedBox(
                    //                   width: double.infinity,
                    //                   child: Row(
                    //                     mainAxisSize: MainAxisSize.max,
                    //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //                     children: <Widget> [
                    //                       Container(
                    //                         width: (width - 20) / 5 * 2,
                    //                         height: 190,
                    //                         padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    //                         child: Center(
                    //                           child: Image.network(
                    //                             'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                    //                             width: 100,
                    //                             height: 100,
                    //                             fit: BoxFit.fill,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       Container(
                    //                           padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    //                           width: (width - 20) / 5 * 3,
                    //                           height: 190,
                    //                           child: GridView.count(
                    //                             crossAxisCount: 2,
                    //                             childAspectRatio: (width - 20) / 150,
                    //                             children: <Widget> [
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: <Widget> [
                    //                                   const Text(
                    //                                     "티켓명",
                    //                                     style: TextStyle(
                    //                                       color: Colors.grey,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                   const SizedBox(height: 4),
                    //                                   Flexible(
                    //                                       child : RichText(
                    //                                         overflow: TextOverflow.ellipsis,
                    //                                         maxLines: 2,
                    //                                         text : TextSpan(text :sellinglist[index]['product_name'], style: const TextStyle(
                    //                                           color: Colors.black,
                    //                                           fontSize: 12,
                    //                                         ),),
                    //                                       )
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: <Widget> [
                    //                                   const Text(
                    //                                     "장소",
                    //                                     style: TextStyle(
                    //                                       color: Colors.grey,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                   const SizedBox(height: 4),
                    //                                   Flexible(
                    //                                       child : RichText(
                    //                                         overflow: TextOverflow.ellipsis,
                    //                                         maxLines: 2,
                    //                                         text : TextSpan(text :sellinglist[index]['place'], style: const TextStyle(
                    //                                           color: Colors.black,
                    //                                           fontSize: 12,
                    //                                         ),),
                    //                                       )
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: <Widget> [
                    //                                   const Text(
                    //                                     "좌석 등급",
                    //                                     style: TextStyle(
                    //                                       color: Colors.grey,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                   const SizedBox(height: 4),
                    //                                   Text(
                    //                                     "${sellinglist[index]['seat_class']}석",
                    //                                     style: const TextStyle(
                    //                                       color: Colors.black,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   )
                    //                                 ],
                    //                               ),
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: <Widget> [
                    //                                   const Text(
                    //                                     "좌석 번호",
                    //                                     style: TextStyle(
                    //                                       color: Colors.grey,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                   const SizedBox(height: 4),
                    //                                   Text(
                    //                                     "${sellinglist[index]['seat_No']}번",
                    //                                     style: const TextStyle(
                    //                                       color: Colors.black,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   )
                    //                                 ],
                    //                               ),
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: <Widget> [
                    //                                   const Text(
                    //                                     "예매 날짜",
                    //                                     style: TextStyle(
                    //                                       color: Colors.grey,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                   const SizedBox(height: 4),
                    //                                   Text(
                    //                                     sellinglist[index]['performance_date'].substring(0, 10).replaceAll("-", ".")
                    //                                         + " "
                    //                                         + sellinglist[index]['performance_date'].substring(11, 16),
                    //                                     style: const TextStyle(
                    //                                       color: Colors.black,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: [],
                    //                               ),
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: <Widget> [
                    //                                   const Text(
                    //                                     "경매 마감 날짜",
                    //                                     style: TextStyle(
                    //                                       color: Colors.grey,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                   const SizedBox(height: 4),
                    //                                   Text(
                    //                                     sellinglist[index]['auction_end_date'].substring(0, 10).replaceAll("-", ".")
                    //                                         + " " +
                    //                                         sellinglist[index]['auction_end_date'].substring(11, 16),
                    //                                     style: const TextStyle(
                    //                                       color: Colors.black,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                               Column(
                    //                                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                                 children: <Widget> [
                    //                                   const Text(
                    //                                     "남은 시간",
                    //                                     style: TextStyle(
                    //                                       color: Colors.grey,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   ),
                    //                                   const SizedBox(height: 4),
                    //                                   Text(
                    //                                     remainSellingTime(sellinglist[index]['auction_end_date']),
                    //                                     style: const TextStyle(
                    //                                       color: Colors.black,
                    //                                       fontSize: 12,
                    //                                     ),
                    //                                   )
                    //                                 ],
                    //                               ),
                    //                             ],
                    //                           )
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             );
                    //           }
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ]
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
