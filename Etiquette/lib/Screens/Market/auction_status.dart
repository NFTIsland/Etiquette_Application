import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';

class AuctionStatus extends StatefulWidget {
  String? token_id;
  AuctionStatus({Key? key, this.token_id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuctionStatus();
}

class _AuctionStatus extends State<AuctionStatus> {
  late double width;
  late double height;
  late final Future future;
  List bidlist = [];

  Future<void> getBidlistFromDB() async {
    const url = "$SERVER_IP/market/bidStatus";
    try {
      var res = await http.post(Uri.parse(url), body: {
        'token_id': widget.token_id!,
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        List bid_data = data["data"];
        for (Map<String, dynamic> bid in bid_data) {
          Map<String, dynamic> ex = {
            'bid_date': bid['bid_date'],
            'bid_price': bid['bid_price'],
          };
          bidlist.add(ex);
          setState(() {});
        }
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "입찰 현황", msg);
      }
    } catch (ex) {
      print("입찰 현황 --> ${ex.toString()}");
    }
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
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("입찰 현황"),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("입찰 현황"),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget> [
                  Visibility(
                    visible: bidlist.isEmpty,
                    child: SizedBox(
                      height: height - 200,
                      child: const Center(
                        child: Text(
                          "아직 입찰이 없습니다.",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: bidlist.isNotEmpty,
                    child: const Card(
                      elevation: 0,
                      color: Colors.white24,
                      child: ListTile(
                        leading: Text(
                          "순위",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Text(
                            "입찰 날짜",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        trailing: Text(
                          "입찰가",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: bidlist.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              bidlist[index]['bid_date'],
                            ),
                          ),
                          trailing: Text(
                            bidlist[index]['bid_price'].toString().replaceAllMapped(reg, mathFunc) + "원",
                          ),
                        ),
                      );
                    },
                  )
                ],
              )
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