import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late bool theme;
  final rows = <DataRow> [];

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getBidlistFromDB() async {
    const url = "$SERVER_IP/market/bidStatus";
    try {
      var res = await http.post(Uri.parse(url), body: {
        'token_id': widget.token_id!,
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        int rank = 1;
        List bid_data = data["data"];
        for (Map<String, dynamic> bid in bid_data) {
          rows.add(
            dataRow(rank.toString(), bid['nickname'], bid['bid_date'], bid['bid_price'].toString().replaceAllMapped(reg, mathFunc) + " 원")
          );
          rank += 1;
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
            appBar: appbarWithArrowBackButton("입찰 현황", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("입찰 현황", theme),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: <Widget> [
                  Visibility(
                    visible: rows.isEmpty,
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
                    visible: rows.isNotEmpty,
                    child: Container(
                      width: width,
                      padding: EdgeInsets.only(
                        top: height * 0.01,
                      ),
                      child: DataTable(
                        columnSpacing: 10,
                        horizontalMargin: 0,
                        columns: <DataColumn> [
                          DataColumn(
                            label: SizedBox(
                              width: (width / 7),
                              child: const Center(
                                child: Text(
                                  '순위',
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: (width / 6),
                              child: const Center(
                                child: Text(
                                  '입찰자',
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: (width / 3),
                              child: const Center(
                                child: Text(
                                  '입찰 날짜',
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: SizedBox(
                              child: Center(
                                child: Text(
                                  '입찰가',
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: rows,
                      ),
                    ),
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

  DataRow dataRow(String ranking, String bidder, String bid_date, String bid_price) {
    return DataRow(
      cells: <DataCell> [
        DataCell(
            Container(
              height: 50,
              width: width / 7,
              alignment: Alignment.center,
              child: Text(
                ranking,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                ),
              ),
            )
        ),
        DataCell(
          Container(
            height: 50,
            width: width / 6,
            alignment: Alignment.center,
            child: Text(
              bidder,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
            Container(
              height: 50,
              width: width / 3,
              alignment: Alignment.center,
              child: Text(
                bid_date,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                ),
              ),
            )
        ),
        DataCell(
            Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                bid_price,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                ),
              ),
            )
        ),
      ],
    );
  }
}

// TableRow tableRow(String ranking, String bidder, String bid_date, String bid_price) {
//   return TableRow(
//     children: <Widget> [
//       TableCell(
//         verticalAlignment: TableCellVerticalAlignment.middle,
//         child: Container(
//             height: 50,
//             alignment: Alignment.center,
//             child: Text(
//                 ranking,
//                 style: const TextStyle(
//                   fontFamily: 'FiraBold',
//                   fontSize: 20,
//                 )
//             )
//         ),
//       ),
//       TableCell(
//         verticalAlignment: TableCellVerticalAlignment.middle,
//         child: Container(
//             height: 50,
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(10.0),
//             child : Text(
//                 bidder,
//                 style : const TextStyle(
//                   fontFamily: 'FiraRegular',
//                   fontSize: 12,
//                 )
//             )
//         ),
//       ),
//       TableCell(
//         verticalAlignment: TableCellVerticalAlignment.middle,
//         child: Container(
//             height: 50,
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(10.0),
//             child : Text(
//                 bid_date,
//                 style : const TextStyle(
//                   fontFamily: 'FiraRegular',
//                   fontSize: 12,
//                 )
//             )
//         ),
//       ),
//       TableCell(
//         verticalAlignment: TableCellVerticalAlignment.middle,
//         child: Container(
//             height: 50,
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(10.0),
//             child : Text(
//                 bid_price,
//                 style : const TextStyle(
//                   fontFamily: 'FiraRegular',
//                   fontSize: 12,
//                 )
//             )
//         ),
//       )
//     ],
//   );
// }