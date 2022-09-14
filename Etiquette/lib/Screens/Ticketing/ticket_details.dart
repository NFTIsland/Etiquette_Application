import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Screens/Ticketing/select_ticket.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';

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
  bool like = false;

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
    final kas_address_data = await getKasAddress();

    if (kas_address_data['statusCode'] != 200) {
      await displayDialog_checkonly(context, "티켓명", "서버와의 연결이 원활하지 않습니다.");
      Navigator.of(context).pop();
      return;
    }

    final kas_address = kas_address_data['data'][0]['kas_address'];
    final url_priceInfo = "$SERVER_IP/ticket/ticketPriceInfo/${widget.product_name!}";
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
        String msg = data['msg'];
        await displayDialog_checkonly(context, "티켓팅", msg);
        Navigator.of(context).pop();
        return;
      }
    } catch (ex) {
      print("티켓팅 --> ${ex.toString()}");
    }

    final url_description = "$SERVER_IP/ticket/ticketDescription/${widget.product_name!}";
    try {
      var res = await http.get(Uri.parse(url_description));
      Map<String, dynamic> data = json.decode(res.body);
      detail = data["data"][0];
    } catch (ex) {
      String msg = ex.toString();
      await displayDialog_checkonly(context, "티켓팅", msg);
      Navigator.of(context).pop();
      return;
    }

    const url_isInterested = "$SERVER_IP/individual/isInterestedTicketing";
    try {
      var res = await http.post(Uri.parse(url_isInterested), body: {
        "product_name": widget.product_name!,
        "place": widget.place!,
        "kas_address": kas_address
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        if (data['data']) {
          like = true;
        } else {
          like = false;
        }
        setState(() {});
      } else {
        String msg = data['msg'];
        await displayDialog_checkonly(context, "티켓팅", msg);
        Navigator.of(context).pop();
        return;
      }
    } catch (ex) {
      String msg = ex.toString();
      await displayDialog_checkonly(context, "티켓팅", msg);
      Navigator.of(context).pop();
      return;
    }
  }

  Future<void> setInterest() async {
    const url = "$SERVER_IP/individual/interestTicketing";
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      final kas_address = kas_address_data['data'][0]['kas_address'];
      var res = await http.post(Uri.parse(url), body: {
        "product_name": widget.product_name!,
        "place": widget.place!,
        "kas_address": kas_address
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] != 200) {
        String errorMessage = "${data['msg']}";
        displayDialog_checkonly(context, "통신 오류", errorMessage);
      }
    } else {
      String errorMessage = "${kas_address_data['msg']}";
      displayDialog_checkonly(context, "통신 오류", errorMessage);
    }
  }

  Future<void> setUnInterest() async {
    const url = "$SERVER_IP/individual/uninterestTicketing";
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      final kas_address = kas_address_data['data'][0]['kas_address'];
      var res = await http.delete(Uri.parse(url), body: {
        "product_name": widget.product_name!,
        "place": widget.place!,
        "kas_address": kas_address
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] != 200) {
        String errorMessage = "${data['msg']}";
        displayDialog_checkonly(context, "통신 오류", errorMessage);
      }
    } else {
      String errorMessage = "${kas_address_data['msg']}";
      displayDialog_checkonly(context, "통신 오류", errorMessage);
    }
  }

  Future<bool> onLikeButtonTapped(bool like) async {
    if (like) {
      setUnInterest();
    } else {
      setInterest();
    }

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;
    return !like;
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
            return Scaffold(
              appBar: appbarWithArrowBackButton("Ticketing", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
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
                                    tableRow("카테고리", detail['category']),
                                    tableRow("티켓 이름", widget.product_name!),
                                    tableRow("가격", price_description),
                                    tableRow("장소", widget.place!),
                                    TableRow(
                                      children: <Widget> [
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                  "관심 티켓 등록",
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
                                              child: LikeButton(
                                                circleColor: const CircleColor(
                                                    start: Color(0xff00ddff),
                                                    end: Color(0xff0099cc)
                                                ),
                                                bubblesColor: const BubblesColor(
                                                  dotPrimaryColor: Color(0xff33b5e5),
                                                  dotSecondaryColor: Color(0xff0099cc),
                                                ),
                                                likeBuilder: (like) {
                                                  return Icon(
                                                    Icons.favorite,
                                                    color: like ? Colors.deepPurpleAccent : Colors.grey,
                                                  );
                                                },
                                                isLiked: like,
                                                onTap: onLikeButtonTapped,
                                              ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // TableRow(
                                    //   children: <Widget> [
                                    //     TableCell(
                                    //       verticalAlignment: TableCellVerticalAlignment.middle,
                                    //       child: Container(
                                    //           height: 50,
                                    //           alignment: Alignment.center,
                                    //           child: const Text(
                                    //               " 카테고리",
                                    //               style: TextStyle(
                                    //                 fontFamily: 'FiraBold',
                                    //                 fontSize: 20,
                                    //               )
                                    //           )
                                    //       ),
                                    //     ),
                                    //     TableCell(
                                    //       verticalAlignment: TableCellVerticalAlignment.middle,
                                    //       child: Container(
                                    //           height: 50,
                                    //           alignment: Alignment.center,
                                    //           child : Text(
                                    //               detail['category'],
                                    //               style : const TextStyle(
                                    //                 fontFamily: 'FiraRegular',
                                    //                 fontSize: 15,
                                    //               )
                                    //           )
                                    //       ),
                                    //     )
                                    //   ],
                                    // ),
                                    // TableRow(
                                    //     children: <Widget> [
                                    //       TableCell(
                                    //         verticalAlignment: TableCellVerticalAlignment.middle,
                                    //         child: Container(
                                    //           height: 50,
                                    //           alignment: Alignment.center,
                                    //           child: const Text(
                                    //               "티켓 이름",
                                    //               style : TextStyle(
                                    //                 fontFamily: 'FiraBold',
                                    //                 fontSize: 20,
                                    //               )
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       TableCell(
                                    //           verticalAlignment: TableCellVerticalAlignment.middle,
                                    //           child: Container(
                                    //             height: 50,
                                    //             alignment: Alignment.center,
                                    //             child : Text(
                                    //                 widget.product_name!,
                                    //                 style : const TextStyle(
                                    //                   fontFamily: 'FiraRegular',
                                    //                   fontSize: 15,
                                    //                 )
                                    //             ),
                                    //           )
                                    //       ),
                                    //     ]
                                    // ),
                                    // TableRow(
                                    //   children: <Widget> [
                                    //     TableCell(
                                    //       verticalAlignment: TableCellVerticalAlignment.middle,
                                    //       child: Container(
                                    //         padding: const EdgeInsets.all(12.0),
                                    //         alignment: Alignment.center,
                                    //         child: const Text(
                                    //             "가격",
                                    //             style: TextStyle(
                                    //               fontFamily: 'FiraBold',
                                    //               fontSize: 20,
                                    //             )
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     TableCell(
                                    //       verticalAlignment: TableCellVerticalAlignment.middle,
                                    //       child: Container(
                                    //         padding: const EdgeInsets.all(12.0),
                                    //         alignment: Alignment.center,
                                    //         child: Text(
                                    //             price_description,
                                    //             style: const TextStyle(
                                    //               fontFamily: 'FiraBold',
                                    //               fontSize: 15,
                                    //             )
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    // TableRow(
                                    //   children: <Widget> [
                                    //     TableCell(
                                    //       verticalAlignment: TableCellVerticalAlignment.middle,
                                    //       child: Container(
                                    //           padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    //           alignment: Alignment.center,
                                    //           child: const Text(
                                    //               "장소",
                                    //               style: TextStyle(
                                    //                 fontFamily: 'FiraBold',
                                    //                 fontSize: 20,
                                    //               )
                                    //           )
                                    //       ),
                                    //     ),
                                    //     TableCell(
                                    //       verticalAlignment: TableCellVerticalAlignment.middle,
                                    //       child: Container(
                                    //           padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    //           alignment: Alignment.center,
                                    //           child: Text(
                                    //               widget.place!,
                                    //               style: const TextStyle(
                                    //                 fontFamily: 'FiraRegular',
                                    //                 fontSize: 15,
                                    //               )
                                    //           )
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
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
                //visible: widget.showPurchaseButton!,
                child:
                widget.showPurchaseButton! ?
                FloatingActionButton.extended(
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
                )
                :
                FloatingActionButton.extended(
                  onPressed: () {

                  },
                  backgroundColor: (theme ? const Color(0xffe8e8e8) : Colors.green),
                  foregroundColor: (theme ? const Color(0xff000000) : const Color(0xffFCF6F5)),
                  label: const Text("판매하기"),
                  icon: const Icon(Icons.navigation),
                )
                ,
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

TableRow tableRow(String title, String value) {
  return TableRow(
    children: <Widget> [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
            alignment: Alignment.center,
            child: Text(
                title,
                style: const TextStyle(
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
                value,
                style: const TextStyle(
                  fontFamily: 'FiraRegular',
                  fontSize: 15,
                )
            )
        ),
      ),
    ],
  );
}
