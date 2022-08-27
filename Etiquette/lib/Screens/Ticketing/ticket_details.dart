import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Screens/Ticketing/select_ticket.dart';

class TicketDetails extends StatefulWidget {
  String? product_name;
  String? place;
  bool? showPurchaseButton;
  TicketDetails({Key? key, this.product_name, this.place, this.showPurchaseButton}) : super(key: key);

  @override
  State createState() => _TicketDetails();
}

class _TicketDetails extends State<TicketDetails> {
  late bool theme;
  late double width;
  late double height;
  String? remain;
  //TabController? controller;

  late final Future future;
  late Map<String, dynamic> detail;
  List price_list = [];
  String price_description = "";

  @override
  void dispose(){
    super.dispose();
  }

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  String buildPriceDescription(String seat_class, int price) {
    return "$seat_class석: ${price.toString().replaceAllMapped(reg, mathFunc)}원";
  }

  Future<void> getTicketDetailFromDB() async {
    final url_priceInfo = "$SERVER_IP/ticketPriceInfo/${widget.product_name!}";
    price_description = "";
    try {
      var res = await http.get(Uri.parse(url_priceInfo));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        List price_info = data["data"];
        int len = price_info.length;
        if (len == 1) {
          price_description = buildPriceDescription(price_info[0]['seat_class'], price_info[0]['price']);
        } else {
          for (int i = 0; i < len - 1; i++) {
            price_description = price_description + buildPriceDescription(price_info[i]['seat_class'], price_info[i]['price']) + "\n";
          }
          price_description = price_description + buildPriceDescription(price_info[len - 1]['seat_class'], price_info[len - 1]['price']);
        }
      } else {
        int statusCode = res.statusCode;
        String msg = data['msg'];
        displayDialog_checkonly(context, "티켓팅", "statusCode: $statusCode\n\nmessage: $msg");
      }
    } catch (ex) {
      print("티켓팅 --> ${ex.toString()}");
    }

    final url_description = "$SERVER_IP/ticketDescription/${widget.product_name!}";
    try {
      var res = await http.get(Uri.parse(url_description));
      Map<String, dynamic> data = json.decode(res.body);
      detail = data["data"][0];
    } catch (ex) {
      int statusCode = 400;
      String msg = ex.toString();
      displayDialog_checkonly(context, "티켓팅", "statusCode: $statusCode\n\nmessage: $msg");
    }
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getTicketDetailFromDB();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("Error")
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: defaultAppbar("티켓 상세 정보"),
              body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                        padding : const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // Image.network(img, width : double.infinity, height : width/2),
                              const SizedBox(height : 10),
                              Table(
                                  border: TableBorder.all(),
                                  columnWidths: const {
                                    0: FixedColumnWidth(140.0),
                                  },
                                  children: <TableRow>[
                                    TableRow(
                                      children: <Widget> [
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                              height: 50,
                                              alignment: Alignment.center,
                                              child: const Text(
                                                  " 카테고리",
                                                  style: TextStyle(
                                                    fontFamily: 'FiraBold',
                                                    fontSize: 20,
                                                  )
                                              )
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                              height: 50,
                                              alignment: Alignment.center,
                                              child : Text(
                                                  detail['category'],
                                                  style : const TextStyle(
                                                    fontFamily: 'FiraRegular',
                                                    fontSize: 15,
                                                  )
                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                    TableRow(
                                        children: <Widget> [
                                          TableCell(
                                            verticalAlignment: TableCellVerticalAlignment.middle,
                                            child: Container(
                                              height: 50,
                                              alignment: Alignment.center,
                                              child: const Text(
                                                  "티켓 이름",
                                                  style : TextStyle(
                                                    fontFamily: 'FiraBold',
                                                    fontSize: 20,
                                                  )
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                              verticalAlignment: TableCellVerticalAlignment.middle,
                                              child: Container(
                                                height: 50,
                                                alignment: Alignment.center,
                                                child : Text(
                                                    widget.product_name!,
                                                    style : const TextStyle(
                                                      fontFamily: 'FiraRegular',
                                                      fontSize: 15,
                                                    )
                                                ),
                                              )
                                          ),
                                        ]
                                    ),
                                    TableRow(
                                      children: <Widget> [
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                            padding: const EdgeInsets.all(12.0),
                                            alignment: Alignment.center,
                                            child: const Text(
                                                "가격",
                                                style: TextStyle(
                                                  fontFamily: 'FiraBold',
                                                  fontSize: 20,
                                                )
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                            padding: const EdgeInsets.all(12.0),
                                            alignment: Alignment.center,
                                            child: Text(
                                                price_description,
                                                style: const TextStyle(
                                                  fontFamily: 'FiraBold',
                                                  fontSize: 15,
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: <Widget> [
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                  "장소",
                                                  style: TextStyle(
                                                    fontFamily: 'FiraBold',
                                                    fontSize: 20,
                                                  )
                                              )
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                              alignment: Alignment.center,
                                              child: Text(
                                                  widget.place!,
                                                  style: const TextStyle(
                                                    fontFamily: 'FiraRegular',
                                                    fontSize: 15,
                                                  )
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                child: Text(
                                  detail['description'].replaceAll('\\n', '\n\n'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ]
                        )
                    ),
                  )
              ),
              floatingActionButton: Visibility(
                visible: widget.showPurchaseButton!,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => SelectTicket(
                              product_name: widget.product_name!,
                              place: widget.place!,
                              category: detail['category'],
                            )
                        )
                    );
                  },
                  backgroundColor: (theme ? const Color(0xffe8e8e8) : Colors.green),
                  foregroundColor: (theme ? const Color(0xff000000) : const Color(0xffFCF6F5)),
                  label: const Text("구매하기"),
                  icon: const Icon(Icons.navigation),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
