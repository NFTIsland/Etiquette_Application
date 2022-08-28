import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';

class Selling extends StatefulWidget {
  const Selling({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Selling();
}

class _Selling extends State<Selling> {
  late double width;
  late double height;
  late final Future future;

  List<Map<String, dynamic>> sellinglist = [];

  List<String> filter = ['All', 'High', 'Row', 'Recent', 'Old'];
  String _selected = 'All';

  Future<void> getSellinglistFromDB() async {
    const url = "$SERVER_IP/sellinglist";
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
              'product_name': ticket['product_name'],
              'place': ticket['place'],
              'seat_class': ticket['seat_class'],
              'seat_No': ticket['seat_No'],
              'performance_date': ticket['performance_date'],
              'auction_end_date': ticket['auction_end_date'],
            };
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
    final remaining = DateTime(end_year, end_month, end_day, end_hour, end_minute).difference(DateTime.now()).toString();
    return "(${remaining.substring(0, 2)}시간 ${remaining.substring(3, 5)}분 남음)";
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
            appBar: appbarWithArrowBackButton("판매 중 티켓"),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("판매 중 티켓"),
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: sellinglist.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  child: InkWell(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget> [
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Image.network(
                                                  'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                  width: 80,
                                                  height: 80
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget> [
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    sellinglist[index]['product_name'],
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    sellinglist[index]['place'],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    "${sellinglist[index]['seat_class']}석 ${sellinglist[index]['seat_No']}번",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    "예매 일자: " + sellinglist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + sellinglist[index]['performance_date'].substring(11, 16),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    "경매 마감 일자: " + sellinglist[index]['auction_end_date'].substring(0, 10).replaceAll("-", ".") + " " + sellinglist[index]['performance_date'].substring(11, 16),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    remainSellingTime(sellinglist[index]['auction_end_date']),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
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
                  ]
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
