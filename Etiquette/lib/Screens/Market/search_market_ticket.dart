import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Screens/Market/market_details.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';

class SearchMarketTicket extends StatefulWidget {
  const SearchMarketTicket({Key? key}) : super(key: key);

  @override
  State createState() => _SearchMarketTicket();
}

class _SearchMarketTicket extends State<SearchMarketTicket> {
  List list = [];
  late final Future future;

  final inputTicketNameController = TextEditingController();

  Future<void> getMarketTicketsFromDB() async {
    if (inputTicketNameController.text == "") {
      displayDialog_checkonly(context, "티켓 마켓", "검색어를 입력해 주세요.");
      return;
    }

    list = new List.empty(growable: true);
    final url = "$SERVER_IP/market/search/${inputTicketNameController.text}";
    try {
      var res = await http.get(Uri.parse(url));
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
          list.add(ex);
          setState(() {});
        }
      } else {
        int statusCode = res.statusCode;
        String msg = data['msg'];
        displayDialog_checkonly(context, "티켓 마켓", "statusCode: $statusCode\n\nmessage: $msg");
      }
    } catch (ex) {
      print("티켓 마켓 --> ${ex.toString()}");
    }
  }

  @override
  void initState(){
    super.initState();
    future = getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("티켓 마켓"),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: defaultAppbar("티켓 마켓"),
              body: Column(
                children: <Widget> [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 18, right: 18),
                          child: Column(
                            children: <Widget> [
                              Column(
                                children: <Widget> [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                    child: TextField(
                                      keyboardType: TextInputType.emailAddress,
                                      controller: inputTicketNameController,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '티켓 이름',
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        focusedBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.blueAccent,
                                            )
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).accentColor,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          color: Theme.of(context).accentColor,
                                          icon: const Icon(
                                              Icons.search,
                                              size: 30
                                          ),
                                          onPressed: () async {
                                            getMarketTicketsFromDB();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: list.length,
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
                                            final kas_address_data = await getKasAddress();
                                            if (kas_address_data['statusCode'] != 200) {
                                              displayDialog_checkonly(context, "티켓 검색", "티켓 목록을 불러오는데 실패했습니다.");
                                              return;
                                            }
                                            final kas_address = kas_address_data['data'][0]['kas_address'];
                                            if (kas_address == list[index]['owner']) {
                                              displayDialog_checkonly(context, "티켓 검색", "이미 해당 티켓을 가지고 있습니다.");
                                              return;
                                            }
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => MarketDetails(
                                                      token_id: list[index]['token_id'],
                                                      product_name: list[index]['product_name'],
                                                      place: list[index]['place'],
                                                      performance_date: list[index]['performance_date'],
                                                      seat_class: list[index]['seat_class'],
                                                      seat_No: list[index]['seat_No'],
                                                    )
                                                )
                                            );
                                          },
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget> [
                                                Expanded(
                                                  flex: 2,
                                                  child: Image.network(
                                                      'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                      width: 50,
                                                      height: 50
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: <Widget> [
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        list[index]['product_name'],
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        list[index]['place'],
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        "${list[index]['seat_class']}석 ${list[index]['seat_No']}번",
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      // Text(
                                                      //   "${list[index]['first_date']} ~ ${list[index]['last_date']}",
                                                      //   style: const TextStyle(
                                                      //     fontSize: 15,
                                                      //   ),
                                                      // ),
                                                      // const SizedBox(height: 5),
                                                      // Text(
                                                      //   list[index]['place'],
                                                      //   style: const TextStyle(
                                                      //     fontSize: 20,
                                                      //   ),
                                                      // ),
                                                      // const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
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