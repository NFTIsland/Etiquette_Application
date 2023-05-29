import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Providers/DB/get_UserInfo.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';

class LoadHoldingTickets extends StatefulWidget {
  const LoadHoldingTickets({Key? key}) : super(key: key);

  @override
  State createState() => _LoadHoldingTickets();
}

class _LoadHoldingTickets extends State<LoadHoldingTickets> {
  late double width;
  late double height;
  late final Future future;
  late bool theme;

  List<Map<String, dynamic>> holdlist = [];

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getHoldlistFromDB() async {
    const url = "$SERVER_IP/individual/holdlist";
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
              'category': ticket['category'],
              'place': ticket['place'],
              'seat_class': ticket['seat_class'],
              'seat_No': ticket['seat_No'],
              'performance_date': ticket['performance_date'],
            };
            holdlist.add(ex);
            setState(() {});
          }
        } else {
          String msg = data['msg'];
          displayDialog_checkonly(context, "보유 티켓 목록", msg);
        }
      } else {
        displayDialog_checkonly(context, "보유 티켓 목록", "보유 티켓 목록을 불러오는데 실패했습니다.");
      }
    } catch (ex) {
      print("보유 티켓 목록 --> ${ex.toString()}");
    }
  }

  Future<int> load_price(String product_name, String seat_class) async {
    final url = "$SERVER_IP/ticket/ticketPrice/$product_name/$seat_class";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        return data["data"][0]["price"];
      } else {
        return 0;
      }
    } catch (ex) {
      print("가격 가져오기 --> ${ex.toString()}");
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getHoldlistFromDB();
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
              appBar: appbarWithArrowBackButton("업로드 티켓 선택", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("업로드 티켓 선택", theme),
              body: Column(
                children: <Widget> [
                  Visibility(
                    visible: holdlist.isEmpty,
                    child: SizedBox(
                      height: height - 200,
                      child: const Center(
                        child: Text(
                          "현재 보유중인 티켓이 없습니다.",
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
                            itemCount: holdlist.length,
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
                                  onTap: () async {
                                    final token_id = holdlist[index]['token_id'];
                                    final product_name = holdlist[index]['product_name'];
                                    final seat_class = holdlist[index]['seat_class'];
                                    final place = holdlist[index]['place'];
                                    final original_price = await load_price(product_name, seat_class);
                                    Navigator.pop(
                                        context,
                                        {
                                          "token_id": token_id,
                                          "product_name": product_name,
                                          "place": place,
                                          "original_price": original_price,
                                          "end_year": holdlist[index]['performance_date'].substring(0, 4),
                                          "end_month": holdlist[index]['performance_date'].substring(5, 7),
                                          "end_day": holdlist[index]['performance_date'].substring(8, 10),
                                          "end_hour": holdlist[index]['performance_date'].substring(11, 13),
                                          "end_minute": holdlist[index]['performance_date'].substring(14, 16),
                                        }
                                    );
                                  },
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
                                                  holdlist[index]['product_name'],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  holdlist[index]['place'],
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "${holdlist[index]['seat_class']}석 ${holdlist[index]['seat_No']}번",
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  holdlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + holdlist[index]['performance_date'].substring(11, 16),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
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