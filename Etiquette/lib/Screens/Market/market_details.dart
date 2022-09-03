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
import 'package:Etiquette/Providers/Coinone/get_klay_currency.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/Providers/DB/update_ticket_owner.dart';
import 'package:Etiquette/Providers/KAS/Kip17/kip17_token_transfer.dart';
import 'package:Etiquette/Providers/KAS/Wallet/klay_transaction.dart';

class MarketDetails extends StatefulWidget {
  String? token_id;
  String? product_name;
  String? owner;
  String? place;
  String? performance_date;
  String? seat_class;
  String? seat_No;

  MarketDetails({Key? key, this.token_id, this.product_name, this.owner, this.place, this.performance_date, this.seat_class, this.seat_No}) : super(key: key);

  @override
  State createState() => _MarketDetails();
}

class _MarketDetails extends State<MarketDetails> {
  late bool theme;
  late double width;
  late double height;
  String? remain;
  String _price = "";
  double _klayCurrency = 0.0;
  bool like = false;

  late final Future future;
  late Map<String, dynamic> details;
  late Map<String, dynamic> auction_details;

  final rows = <DataRow> [];
  final TextEditingController bid_price_controller = TextEditingController();
  // String bid_price = "";

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getMarketDetailFromDB() async {
    final kas_address_data = await getKasAddress();

    if (kas_address_data['statusCode'] != 200) {
      await displayDialog_checkonly(context, "티켓 마켓", "서버와의 연결이 원활하지 않습니다.");
      Navigator.of(context).pop();
    }

    final kas_address = kas_address_data['data'][0]['kas_address'];

    final url = "$SERVER_IP/ticketPrice/${widget.product_name!}/${widget.seat_class!}";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        int ticket_price = data["data"][0]["price"];
        setState(() {
          _price = ticket_price.toString();
        });
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "티켓 마켓", msg);
        setState(() {
          _price = "";
        });
        return;
      }
    } catch (ex) {
      print("티켓 마켓 --> ${ex.toString()}");
      return;
    }

    const url_isInterested = "$SERVER_IP/isInterestedAuction";
    try {
      var res = await http.post(Uri.parse(url_isInterested), body: {
        "product_name": widget.product_name!,
        "place": widget.place!,
        "seat_class": widget.seat_class!,
        "seat_No": widget.seat_No!,
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
        displayDialog_checkonly(context, "티켓 마켓", msg);
        return;
      }
    } catch (ex) {
      String msg = ex.toString();
      displayDialog_checkonly(context, "티켓 마켓", msg);
      return;
    }

    final url_description = "$SERVER_IP/ticketDescription/${widget.product_name!}";
    try {
      var res = await http.get(Uri.parse(url_description));
      Map<String, dynamic> data = json.decode(res.body);
      details = data["data"][0];
    } catch (ex) {
      String msg = ex.toString();

      await displayDialog_checkonly(context, "티켓 마켓", msg);
      Navigator.of(context).pop();
    }

    const url_auction = "$SERVER_IP/market/auctionInfo";
    try {
      var res = await http.post(Uri.parse(url_auction), body: {
        "token_id": widget.token_id!,
      });
      Map<String, dynamic> data = json.decode(res.body);

      if (data['statusCode'] == 200) {
        auction_details = data["data"][0];
      } else if (data['statusCode'] == 201) { // 이미 경매가 마감된 티켓인 경우
        String msg = data['msg'];

        await displayDialog_checkonly(context, "티켓 마켓", msg);
        Navigator.of(context).pop();
      } else {
        String msg = data['msg'];

        await displayDialog_checkonly(context, "티켓 마켓", msg);
        Navigator.of(context).pop();
      }

    } catch (ex) {
      int statusCode = 400;
      String msg = ex.toString();
      displayDialog_checkonly(context, "티켓 마켓", "statusCode: $statusCode\n\nmessage: $msg");
      return;
    }

    // bidlist
    const url_bidlist_top5 = "$SERVER_IP/market/bidStatusTop5";
    try {
      var res = await http.post(Uri.parse(url_bidlist_top5), body: {
        'token_id': widget.token_id!,
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        List bid_data = data["data"];
        int rank = 1;
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
        return;
      }
    } catch (ex) {
      print("입찰 현황 --> ${ex.toString()}");
      return;
    }
  }

  Future<void> bid() async {
    if (bid_price_controller.text == "") {
      displayDialog_checkonly(context, "입찰", "입찰가를 입력해 주십시오.");
      return;
    }

    final bid_price = int.parse(bid_price_controller.text);
    if (bid_price % auction_details['bid_unit'] != 0) {
      displayDialog_checkonly(context, "입찰", "입찰 단위에 맞지 않습니다. 다시 입력해 주십시오.");
      return;
    }

    if (bid_price < auction_details['auction_start_price']) {
      displayDialog_checkonly(context, "입찰", "입찰가는 경매 시작가보다 커야 합니다.");
      return;
    }

    const url_bid = "$SERVER_IP/market/bid";
    try {
      Map<String, dynamic> kas_address_data = await getKasAddress();
      if (kas_address_data['statusCode'] == 200) {
        final bidder = kas_address_data['data'][0]['kas_address'];
        var res = await http.post(Uri.parse(url_bid), body: {
          "token_id": widget.token_id!,
          "bidder": bidder,
          "bid_price": bid_price.toString(),
        });
        Map<String, dynamic> data = json.decode(res.body);
        if (data['statusCode'] == 200) {
          displayDialog_checkonly(context, "입찰", "입찰이 성공적으로 완료되었습니다.");
        } else {
          final msg = data['msg'];
          displayDialog_checkonly(context, "입찰", "입찰에 실패했습니다.\n\n$msg");
          print("입찰 --> $msg");
        }
      } else {
        String message = kas_address_data["msg"];
        String errorMessage = "계정 정보를 가져오지 못했습니다.\n\n$message";
        displayDialog_checkonly(context, "통신 오류", errorMessage);
        print("입찰 --> $errorMessage");
      }
    } catch (ex) {
      int statusCode = 400;
      String msg = ex.toString();
      displayDialog_checkonly(context, "입찰", "statusCode: $statusCode\n\nmessage: $msg");
    }
  }

  Future<Map<String, dynamic>> terminateAuction(String bidder) async {
    const url = "$SERVER_IP/market/terminateAuction";
    try {
      var res = await http.delete(Uri.parse(url), body: {
        'token_id': widget.token_id!,
        'bidder': bidder
      });
      Map<String, dynamic> data = json.decode(res.body);
      return data;
    } catch (ex) {
      return {
        "statusCode": 400,
        "msg": ex.toString()
      };
    }
  }

  Future<void> loadKlayCurrency() async {
    Map<String, dynamic> data = await getKlayCurrency(); // 현재 KLAY 시세 정보를 API를 통해 가져옴
    if (data["statusCode"] == 200) { // 현재 KLAY 시세 정보를 정상적으로 가져옴
      String klayCurrency = data['lastCurrency'];
      _klayCurrency = double.parse(klayCurrency);
    } else {
      _klayCurrency = 0.0;
    }
  }

  Future<void> setInterest() async {
    const url = "$SERVER_IP/interestAuction";
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      final kas_address = kas_address_data['data'][0]['kas_address'];
      var res = await http.post(Uri.parse(url), body: {
        "product_name": widget.product_name!,
        "place": widget.place!,
        "seat_class": widget.seat_class!,
        "seat_No": widget.seat_No!,
        "kas_address": kas_address,
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
      } else {
        String errorMessage = "${data['msg']}";
        displayDialog_checkonly(context, "통신 오류", errorMessage);
      }
    } else {
      String errorMessage = "${kas_address_data['msg']}";
      displayDialog_checkonly(context, "통신 오류", errorMessage);
    }
  }

  Future<void> setUnInterest() async {
    const url = "$SERVER_IP/uninterestAuction";
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      final kas_address = kas_address_data['data'][0]['kas_address'];
      var res = await http.delete(Uri.parse(url), body: {
        "product_name": widget.product_name!,
        "place": widget.place!,
        "seat_class": widget.seat_class!,
        "seat_No": widget.seat_No!,
        "kas_address": kas_address
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
      } else {
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
    loadKlayCurrency();
    future = getMarketDetailFromDB();
  }

  @override
  void dispose() {
    super.dispose();
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
              appBar: appbarWithArrowBackButton("티켓 상세 정보"),
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
                              const SizedBox(height : 10),
                              Table(
                                  border: TableBorder.all(),
                                  columnWidths: const {
                                    0: FixedColumnWidth(140.0),
                                  },
                                  children: <TableRow>[
                                    tableRow("카테고리", details['category']),
                                    tableRow("티켓 이름", widget.product_name!),
                                    tableRow("원가", _price.replaceAllMapped(reg, mathFunc) + " 원"),
                                    tableRow("장소", widget.place!),
                                    tableRow("날짜",
                                        widget.performance_date!.substring(0, 10).replaceAll("-", ".")
                                            + " "
                                            + widget.performance_date!.substring(11, 16)),
                                    tableRow("좌석 정보", "${widget.seat_class!}석 ${widget.seat_No!}번"),
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
                                  ]
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                child: Text(
                                  details['description'].replaceAll('\\n', '\n\n'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "해당 티켓의 옥션 현황 정보",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Table(
                                border: TableBorder.all(),
                                columnWidths: const {
                                  0: FixedColumnWidth(140.0),
                                },
                                children: <TableRow> [
                                  tableRow("거래 종료일",
                                      auction_details['auction_end_date'].substring(0, 10).replaceAll("-", ".")
                                          + " "
                                          + auction_details['auction_end_date'].substring(11, 16)),
                                  tableRow("경매 시작가", auction_details['auction_start_price'].toString().replaceAllMapped(reg, mathFunc) + " 원"),
                                  tableRow("입찰 단위", auction_details['bid_unit'].toString().replaceAllMapped(reg, mathFunc) + " 원"),
                                  tableRow("즉시 거래가", auction_details['immediate_purchase_price'].toString().replaceAllMapped(reg, mathFunc) + " 원"),
                                  TableRow(
                                    children: <Widget> [
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Container(
                                            height: 300,
                                            alignment: Alignment.center,
                                            child: const Text(
                                                "판매자 코멘트",
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
                                            height: 300,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(10.0),
                                            child : Text(
                                                auction_details['auction_comments'],
                                                style : const TextStyle(
                                                  fontFamily: 'FiraRegular',
                                                  fontSize: 15,
                                                )
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "입찰 현황",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              Visibility(
                                  visible: rows.isEmpty,
                                  child: Column(
                                    children: const <Widget> [
                                      SizedBox(height: 15),
                                      Text(
                                        "아직 입찰이 없습니다.",
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              Visibility(
                                visible: rows.isNotEmpty,
                                child: Container(
                                  width: width - 30,
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: DataTable(
                                    columnSpacing: 0,
                                    horizontalMargin: 0,
                                    columns: <DataColumn> [
                                      DataColumn(
                                        label: SizedBox(
                                            width: (width - 30) / 10,
                                            child: const Center(
                                              child: Text(
                                                '순위',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                            width: (width - 30) / 10 * 3,
                                            child: const Center(
                                              child: Text(
                                                '입찰자',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                            width: (width - 30) / 10 * 4,
                                            child: const Center(
                                              child: Text(
                                                '입찰 날짜',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                            width: (width - 30) / 10 * 2,
                                            child: const Center(
                                              child: Text(
                                                '입찰가',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                    ],
                                    rows: rows,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                  "입찰가 입력",
                                  style: TextStyle(
                                    fontSize: 25,
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: TextField(
                                  onChanged: (bid_price) {
                                    setState(() {
                                      int? _parse = int.tryParse(bid_price);
                                      if (_parse != null) {
                                        if (_parse > auction_details['immediate_purchase_price']) {
                                          bid_price_controller.text = auction_details['immediate_purchase_price'].toString();
                                        }
                                      }
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  controller: bid_price_controller,
                                  maxLines: 1,
                                  maxLength: 11,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '입찰가 입력',
                                    counterText: "",
                                    suffix: const Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Text(
                                        '원',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
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
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                  onPressed: () async {
                                    if (int.parse(bid_price_controller.text) >= auction_details['immediate_purchase_price']) {
                                      final immidiate_purchase = await displayDialog_YesOrNo(context, "입찰", "즉시 입찰가를 입력하셨습니다. 즉시 입찰 하시겠습니까?");
                                      if (immidiate_purchase) {
                                        final kas_address_data = await getKasAddress(); // jwt token으로부터 kas_address 가져오기
                                        final owner = widget.owner!;

                                        if (kas_address_data['statusCode'] != 200) { // jwt token으로부터 kas_address를 가져오지 못했을 경우
                                          String? message = kas_address_data["msg"];
                                          String errorMessage = "잔액 정보를 가져오지 못했습니다.\n\n$message";
                                          displayDialog_checkonly(context, "통신 오류", errorMessage);
                                          return;
                                        }

                                        final bidder = kas_address_data['data'][0]['kas_address'];
                                        double payment_klay = auction_details['immediate_purchase_price'] / _klayCurrency;

                                        if (payment_klay.isInfinite) { // _klayCurrency가 0인 경우
                                          String errorMessage = "즉시 입찰에 실패했습니다.\n\nKLAY 환율 정보를 받아오지 못했습니다.";
                                          displayDialog_checkonly(context, "즉시 입찰 실패", errorMessage);
                                          return;
                                        }

                                        Map<String, dynamic> klayTransactionData = await klayTransaction(bidder, payment_klay.toString(), owner);

                                        if (klayTransactionData['statusCode'] != 200) { // 트랜잭션 실패
                                          String message = klayTransactionData["msg"];
                                          String errorMessage = "즉시 입찰에 실패했습니다.\n\n$message";
                                          displayDialog_checkonly(context, "즉시 입찰 실패", errorMessage);
                                          return;
                                        }

                                        Map<String, dynamic> kip17TokenTransferData = await kip17TokenTransfer(details['category'], widget.token_id!, owner, owner, bidder);

                                        if (kip17TokenTransferData['statusCode'] != 200) { // 토큰 전송 실패
                                          String message = kip17TokenTransferData["msg"];
                                          String errorMessage = "즉시 입찰에 실패했습니다.\n\n$message";
                                          displayDialog_checkonly(context, "즉시 입찰 실패", errorMessage);

                                          // 토큰 전송 실패로 인한 klay 환불 조치
                                          // 문제점 1. owner의 klay 잔액이 부족하면 환불이 진행되지 않는다.
                                          payment_klay = payment_klay + 0.000525;
                                          Map<String, dynamic> klayTransactionData = await klayTransaction(owner, payment_klay.toString(), bidder);
                                          if (klayTransactionData['statusCode'] == 200) {
                                            displayDialog_checkonly(context, "즉시 입찰 실패", "알 수 없는 오류로 거래가 취소되었습니다.\n\n다시 시도해 주십시오.");
                                          } else {
                                            displayDialog_checkonly(context, "즉시 입찰 실패", "알 수 없는 오류로 거래가 취소되었습니다.\n\n서비스 센터에 문의해 주십시오.");
                                          }
                                          return;
                                        }

                                        Map<String, dynamic> updateTicketOwnerData = await updateTicketOwner(bidder, widget.token_id!);

                                        if (updateTicketOwnerData['statusCode'] != 200) { // DB에 티켓 owner를 업데이트 하지 못함
                                          String errorMessage = "즉시 입찰에 실패했습니다.\n\n서버와의 통신이 원활하지 않습니다.";
                                          displayDialog_checkonly(context, "즉시 입찰 실패", errorMessage);
                                          return;
                                        }

                                        Map<String, dynamic> terminateAuctionData = await terminateAuction(bidder);

                                        if (terminateAuctionData['statusCode'] != 200) {
                                          String errorMessage = "즉시 입찰에 실패했습니다.\n\n${terminateAuctionData['msg']}";
                                          displayDialog_checkonly(context, "즉시 입찰 실패", errorMessage);
                                          return;
                                        }

                                        displayDialog_checkonly(context, "즉시 입찰 완료", "즉시 입찰이 성공적으로 완료되었습니다.");
                                        return;
                                      } else {
                                        return;
                                      }
                                    }

                                    final selected = await displayDialog_YesOrNo(context, "입찰하기", "위 입찰가로 경매에 참여하시겠습니까?");
                                    if (selected) {
                                      bid();
                                    }
                                  },
                                  child: const Text(
                                    "입찰하기",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  )
                              )
                            ]
                        )
                    ),
                  )
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

DataRow dataRow(String ranking, String bidder, String bid_date, String bid_price) {
  return DataRow(
    cells: <DataCell> [
      DataCell(
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              ranking,
              style: const TextStyle(
                fontFamily: 'FiraBold',
                fontSize: 20,
              ),
            ),
          )
      ),
      DataCell(
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              bidder,
              style: const TextStyle(
                fontFamily: 'FiraBold',
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
              bid_date,
              style: const TextStyle(
                fontFamily: 'FiraBold',
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
                fontFamily: 'FiraBold',
                fontSize: 12,
              ),
            ),
          )
      ),
    ],
  );
}

TableRow tableRow(String title, String value) {
  return TableRow(
    children: <Widget> [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Container(
            height: 50,
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
            height: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child : Text(
                value,
                style : const TextStyle(
                  fontFamily: 'FiraRegular',
                  fontSize: 15,
                )
            )
        ),
      )
    ],
  );
}