import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Screens/Ticketing/ticket_details.dart';
import 'package:Etiquette/Screens/Market/market_details.dart';

class Interest extends StatefulWidget {
  const Interest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Interest();
}

class _Interest extends State<Interest> {
  late final Future future;
  List<Map<String, dynamic>> interest_ticketing_list = [];
  List<Map<String, dynamic>> interest_auction_list = [];

  late double width;
  late double height;

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
          };
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
          };
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
    future = getInterestFromDB();
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
              appBar: appbarWithArrowBackButton("관심 티켓"),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: appbarWithArrowBackButton("관심 티켓"),
                body: Container(
                    width: double.infinity,
                    alignment: Alignment.topLeft,
                    child: Column(
                        children: <Widget> [
                          const SizedBox(
                            child: Text(
                              "Interesting Tickets For Ticketing",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: interest_ticketing_list.isEmpty,
                            child: Center(
                                child: Column(
                                  children: const <Widget> [
                                    SizedBox(height: 10),
                                    Text(
                                      "관심 목록이 없습니다.",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Center(
                                child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: interest_ticketing_list.length,
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
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => TicketDetails(
                                                      product_name: interest_ticketing_list[index]['product_name'],
                                                      place: interest_ticketing_list[index]['place'],
                                                      showPurchaseButton: true,
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Center(
                                                    child: Image.network(
                                                        'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                        width: 80,
                                                        height: 80
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget> [
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          interest_ticketing_list[index]['product_name'],
                                                          style: const TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          interest_ticketing_list[index]['place'],
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
                          const SizedBox(
                            child: Text(
                              "Interesting Tickets For Auction",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: interest_auction_list.isEmpty,
                            child: Center(
                                child: Column(
                                  children: const <Widget> [
                                    SizedBox(height: 10),
                                    Text(
                                      "관심 목록이 없습니다.",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Center(
                                child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: interest_auction_list.length,
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Center(
                                                    child: Image.network(
                                                        'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                        width: 80,
                                                        height: 80
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget> [
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          interest_auction_list[index]['product_name'],
                                                          style: const TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          interest_auction_list[index]['place'],
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          "${interest_auction_list[index]['seat_class']}석 ${interest_auction_list[index]['seat_No']}번",
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
