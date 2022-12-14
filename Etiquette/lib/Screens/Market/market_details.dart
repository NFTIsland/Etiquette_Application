import 'dart:async';
import 'dart:convert';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/Coinone/get_klay_currency.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/Providers/DB/update_ticket_owner.dart';
import 'package:Etiquette/Providers/KAS/Kip17/kip17_token_transfer.dart';
import 'package:Etiquette/Providers/KAS/Wallet/klay_transaction.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketDetails extends StatefulWidget {
  String? token_id;
  String? product_name;
  String? owner;
  String? place;
  String? performance_date;
  String? seat_class;
  String? seat_No;

  MarketDetails(
      {Key? key,
      this.token_id,
      this.product_name,
      this.owner,
      this.place,
      this.performance_date,
      this.seat_class,
      this.seat_No})
      : super(key: key);

  @override
  State createState() => _MarketDetails();
}

class _MarketDetails extends State<MarketDetails> with SingleTickerProviderStateMixin {
  late bool theme;
  late double width;
  late double height;
  String? remain;
  String _price = "";
  String previous_bid_price = "-";
  String minimum_bid_price = "0";
  double _klayCurrency = 0.0;
  bool like = false;

  final GlobalKey _tabbar = GlobalKey();
  final GlobalKey _tabbarview = GlobalKey();

  TabController? tabcontroller;
  ScrollController? scrollController;

  late final Future future;
  late Map<String, dynamic> details;
  late Map<String, dynamic> auction_details;

  final rows = <DataRow>[];
  final TextEditingController bid_price_controller = TextEditingController();

  // String bid_price = "";
  void _scrollDown() {
    Scrollable.ensureVisible(
      _tabbar.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getMarketDetailFromDB() async {
    final kas_address_data = await getKasAddress();

    if (kas_address_data['statusCode'] != 200) {
      await displayDialog_checkonly(context, "?????? ??????", "???????????? ????????? ???????????? ????????????.");
      Navigator.of(context).pop();
    }

    final kas_address = kas_address_data['data'][0]['kas_address'];

    final url = "$SERVER_IP/ticket/ticketPrice/${widget.product_name!}/${widget.seat_class!}";
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
        displayDialog_checkonly(context, "?????? ??????", msg);
        setState(() {
          _price = "";
        });
        return;
      }
    } catch (ex) {
      print("?????? ?????? --> ${ex.toString()}");
      return;
    }

    const url_isInterested = "$SERVER_IP/individual/isInterestedAuction";
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
        displayDialog_checkonly(context, "?????? ??????", msg);
        return;
      }
    } catch (ex) {
      String msg = ex.toString();
      displayDialog_checkonly(context, "?????? ??????", msg);
      return;
    }

    final url_description = "$SERVER_IP/ticket/ticketDescription/${widget.product_name!}";
    try {
      var res = await http.get(Uri.parse(url_description));
      Map<String, dynamic> data = json.decode(res.body);
      details = data["data"][0];
    } catch (ex) {
      String msg = ex.toString();

      await displayDialog_checkonly(context, "?????? ??????", msg);
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
      } else if (data['statusCode'] == 201) {
        // ?????? ????????? ????????? ????????? ??????
        String msg = data['msg'];

        await displayDialog_checkonly(context, "?????? ??????", msg);
        Navigator.of(context).pop();
      } else {
        String msg = data['msg'];

        await displayDialog_checkonly(context, "?????? ??????", msg);
        Navigator.of(context).pop();
      }
    } catch (ex) {
      String msg = ex.toString();
      displayDialog_checkonly(context, "?????? ??????", msg);
      print("?????? ?????? --> $msg");
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
          rows.add(dataRow(
            rank.toString(),
            bid['nickname'],
            bid['bid_date'],
            bid['bid_price'].toString().replaceAllMapped(reg, mathFunc) + " ???",
          ));
          rank += 1;
          setState(() {});
        }
      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "?????? ??????", msg);
        return;
      }

      const url_bidlist = "$SERVER_IP/market/bidStatus";
      try {
        var res = await http.post(Uri.parse(url_bidlist), body: {
          'token_id': widget.token_id!,
        });
        Map<String, dynamic> data = json.decode(res.body);
        if (data['statusCode'] == 200) {
          minimum_bid_price = auction_details['auction_start_price'].toString();
          List bid_data = data["data"];
          for (Map<String, dynamic> bid in bid_data) {
            if (bid['bidder'] == kas_address) {
              previous_bid_price = bid['bid_price'].toString();
              minimum_bid_price = (bid['bid_price'] + auction_details['bid_unit']).toString();
              if ((bid['bid_price'] + auction_details['bid_unit']) > auction_details['immediate_purchase_price']) {
                minimum_bid_price = auction_details['immediate_purchase_price'].toString();
              }
              setState(() {});
              break;
            }
          }
        }
      } catch (ex) {
        String msg = data['msg'];
        displayDialog_checkonly(context, "?????? ??????", msg);
        return;
      }
    } catch (ex) {
      print("?????? ?????? --> ${ex.toString()}");
      return;
    }
  }

  Future<void> bid() async {
    if (bid_price_controller.text == "") {
      displayDialog_checkonly(context, "??????", "???????????? ????????? ????????????.");
      return;
    }

    final bid_price = int.parse(bid_price_controller.text);
    if (bid_price % auction_details['bid_unit'] != 0) {
      displayDialog_checkonly(context, "??????", "?????? ????????? ?????? ????????????. ?????? ????????? ????????????.");
      return;
    }

    if (bid_price < auction_details['auction_start_price']) {
      displayDialog_checkonly(context, "??????", "???????????? ?????? ??????????????? ?????? ?????????.");
      return;
    }

    if (int.tryParse(previous_bid_price) != null) {
      if (bid_price < int.parse(previous_bid_price) + auction_details['bid_unit']
          && bid_price != auction_details['immediate_purchase_price']) {
        displayDialog_checkonly(context, "??????", "?????? ??????????????? ??? ????????? ???????????? ?????????.");
        return;
      }
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
          displayDialog_checkonly(context, "??????", "????????? ??????????????? ?????????????????????.");
        } else {
          final msg = data['msg'];
          displayDialog_checkonly(context, "??????", "????????? ??????????????????.\n\n$msg");
          print("?????? --> $msg");
        }
      } else {
        String message = kas_address_data["msg"];
        String errorMessage = "?????? ????????? ???????????? ???????????????.\n\n$message";
        displayDialog_checkonly(context, "?????? ??????", errorMessage);
        print("?????? --> $errorMessage");
      }
    } catch (ex) {
      int statusCode = 400;
      String msg = ex.toString();
      displayDialog_checkonly(context, "??????", "statusCode: $statusCode\n\nmessage: $msg");
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
      return {"statusCode": 400, "msg": ex.toString()};
    }
  }

  Future<void> loadKlayCurrency() async {
    Map<String, dynamic> data = await getKlayCurrency(); // ?????? KLAY ?????? ????????? API??? ?????? ?????????
    if (data["statusCode"] == 200) {
      // ?????? KLAY ?????? ????????? ??????????????? ?????????
      String klayCurrency = data['lastCurrency'];
      _klayCurrency = double.parse(klayCurrency);
    } else {
      _klayCurrency = 0.0;
    }
  }

  Future<void> setInterest() async {
    const url = "$SERVER_IP/individual/interestAuction";
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
      if (data['statusCode'] == 200) {} else {
        String errorMessage = "${data['msg']}";
        displayDialog_checkonly(context, "?????? ??????", errorMessage);
      }
    } else {
      String errorMessage = "${kas_address_data['msg']}";
      displayDialog_checkonly(context, "?????? ??????", errorMessage);
    }
  }

  Future<void> setUnInterest() async {
    const url = "$SERVER_IP/individual/uninterestAuction";
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
      if (data['statusCode'] == 200) {} else {
        String errorMessage = "${data['msg']}";
        displayDialog_checkonly(context, "?????? ??????", errorMessage);
      }
    } else {
      String errorMessage = "${kas_address_data['msg']}";
      displayDialog_checkonly(context, "?????? ??????", errorMessage);
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
    tabcontroller = TabController(length: 4, vsync: this, animationDuration: Duration.zero);
    scrollController = ScrollController(initialScrollOffset: 0);
    getTheme();
    future = getMarketDetailFromDB();
  }

  @override
  void dispose() {
    tabcontroller!.dispose();
    scrollController!.dispose();
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
              appBar: appbarWithArrowBackButton("?????? ?????? ??????", theme),
              body: const Center(
                child: Text("?????? ????????? ??????????????????."),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: defaultAppbar("?????? ?????? ??????"),
              body: Column(
                children: <Widget> [
                  Flexible(
                      fit: FlexFit.tight,
                      child: NestedScrollView(
                          headerSliverBuilder: (context, value) {
                            return [
                              SliverToBoxAdapter(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget> [
                                        Stack(
                                          children: <Widget> [
                                            Image.network(
                                              details['backdrop_url'],
                                              width: width,
                                              height: width * 0.4,
                                              fit: BoxFit.fill,
                                            ),
                                            Visibility(
                                              visible: details['category'] != 'sports',
                                              child: Positioned(
                                                left: width * 0.05,
                                                top:  width * 0.1,
                                                child: Image.network(
                                                  details['poster_url'],
                                                  width: width * 0.25,
                                                  height: width * 0.38,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            )
                                          ],
                                          clipBehavior: Clip.none,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(width * 0.05, width * 0.1, width * 0.05, 0),
                                          child: Text(
                                            widget.product_name!,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'NotoSans',
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(width * 0.04, width * 0.01, width * 0.04, 0),
                                          child: Column(
                                            children: <Widget> [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget> [
                                                      const Icon(
                                                        Icons.location_on_outlined,
                                                        size: 20,
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.01,
                                                      ),
                                                      Text(
                                                        widget.place!,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontFamily: 'Pretendard',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  LikeButton(
                                                    circleColor: const CircleColor(
                                                      start: Color(0xff00ddff),
                                                      end: Color(0xff0099cc),
                                                    ),
                                                    bubblesColor: const BubblesColor(
                                                      dotPrimaryColor: Color(0xff33b5e5),
                                                      dotSecondaryColor: Color(0xff0099cc),
                                                    ),
                                                    likeBuilder: (like) {
                                                      return Icon(
                                                        Icons.favorite,
                                                        color: like ? Colors.red : Colors.grey,
                                                        size: 30,
                                                      );
                                                    },
                                                    isLiked: like,
                                                    onTap: onLikeButtonTapped,
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.event_seat_outlined,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: width * 0.01),
                                                  Text("${widget.seat_class}??? ${widget.seat_No}???",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_month_outlined,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: width * 0.01),
                                                  Text(
                                                    "${widget.performance_date!.substring(0, 10).replaceAll("-", ".")} ${widget.performance_date!.substring(11, 16)}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: height * 0.015),
                                        Center(
                                          child: Container(
                                            key: _tabbar,
                                            alignment: Alignment.topCenter,
                                            width: width * 0.9,
                                            height: width * 0.09,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                              color: theme ? const Color(0xffe8e8e8) : const Color(0xffffffff),
                                            ),
                                            child: TabBar(
                                              indicator: (tabcontroller!.index == 0) ?
                                              const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(9),
                                                  topLeft: Radius.circular(9),
                                                ),
                                                color: Color(0xff333333),
                                              ) : (tabcontroller!.index == 1 || tabcontroller!.index == 2) ?
                                              const BoxDecoration(
                                                color: Color(0xff333333),
                                              ) :
                                              const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(9),
                                                  topRight: Radius.circular(9),
                                                ),
                                                color: Color(0xff333333),
                                              ),
                                              indicatorPadding: EdgeInsets.zero,
                                              labelPadding: EdgeInsets.zero,
                                              controller: tabcontroller,
                                              indicatorWeight: 0,
                                              unselectedLabelStyle: const TextStyle(
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.w500,
                                              ),
                                              unselectedLabelColor: Colors.black,
                                              labelColor: Colors.white,
                                              labelStyle: const TextStyle(
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.w700,
                                              ),
                                              tabs: [
                                                Tab(
                                                  child: Container(
                                                    child: const Text('?????? ??????'),
                                                    alignment: Alignment.center,
                                                    height: double.infinity,
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Tab(
                                                  child: Container(
                                                    child: const Text('?????????'),
                                                    alignment: Alignment.center,
                                                    height: double.infinity,
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Tab(
                                                  child: Container(
                                                    child: const Text('?????? ??????'),
                                                    alignment: Alignment.center,
                                                    height: double.infinity,
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Tab(
                                                  child: Container(
                                                    child: const Text('????????????'),
                                                    alignment: Alignment.center,
                                                    height: double.infinity,
                                                    decoration: const BoxDecoration(),
                                                  ),
                                                ),
                                              ],
                                              onTap: (int idx) {
                                                setState(() {
                                                  tabcontroller!.index = idx;
                                                  _scrollDown();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                  ),
                              ),
                            ];
                          },
                          body: Container(
                            padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                            child: TabBarView(
                              key: _tabbarview,
                              physics: const NeverScrollableScrollPhysics(),
                              controller: tabcontroller,
                              children: [
                                ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "\n?????? ??????\n",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.clip,
                                        ),
                                        Text(
                                          details['description'].replaceAll('\\n', '\n'),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.clip,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "\n???????????? ?????????\n",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          auction_details['auction_comments'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.only(top: height * 0.03),
                                  children: ListTile.divideTiles(
                                    context: context,
                                    tiles: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              width: width * 0.3,
                                              child: const Text(
                                                "?????? ?????????",
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${auction_details['auction_end_date'].substring(0, 10).replaceAll("-", ".")} ${auction_details['auction_end_date'].substring(11, 16)}",
                                              style: const TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Color(0xff1F1F1F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              width: width * 0.3,
                                              child: const Text(
                                                "?????? ?????????",
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${auction_details['auction_start_price'].toString().replaceAllMapped(reg, mathFunc)} ???",
                                              style: const TextStyle(
                                                  fontFamily: "NotoSans",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Color(0xff1F1F1F)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              width: width * 0.3,
                                              child: const Text(
                                                "?????? ??????",
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${auction_details['bid_unit'].toString().replaceAllMapped(reg, mathFunc)} ???",
                                              style: const TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Color(0xff1F1F1F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              width: width * 0.3,
                                              child: const Text(
                                                "?????? ?????????",
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${auction_details['immediate_purchase_price'].toString().replaceAllMapped(reg, mathFunc)} ???",
                                              style: const TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Color(0xff1F1F1F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ).toList(),
                                ),
                                ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "\n?????? ??????",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Visibility(
                                              visible: rows.isEmpty,
                                              child: Column(
                                                children: const <Widget> [
                                                  SizedBox(height: 15),
                                                  Text(
                                                    "?????? ????????? ????????????.",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
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
                                                            '??????',
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
                                                            '?????????',
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
                                                            '?????? ??????',
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
                                                            '?????????',
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
                                            ),
                                            Visibility(
                                              visible: rows.isNotEmpty,
                                              child: Column(
                                                children: <Widget> [
                                                  const SizedBox(height: 15),
                                                  Text(
                                                    "\n?????? ?????? ?????????: ${previous_bid_price.replaceAllMapped(reg, mathFunc)} ???",
                                                    style: const TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("????????? ??????",
                                              style: TextStyle(
                                                fontFamily: "Pretendard",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 25,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: width * 0.05,
                                              ),
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
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly
                                                ],
                                                cursorColor: const Color(0xff808393),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: '????????? ??????(?????? ${minimum_bid_price.replaceAllMapped(reg, mathFunc)} ??? ??????)',
                                                  counterText: "",
                                                  suffix: const Padding(
                                                    padding: EdgeInsets.all(2.0),
                                                    child: Text(
                                                      '???',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  hintStyle: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                  focusedBorder: const OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Color(0xff808393),
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xff808393),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                          ]
                                      ),
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget> [
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (int.parse(bid_price_controller.text) >= auction_details['immediate_purchase_price']) {
                                                  final immediate_purchase_price = auction_details['immediate_purchase_price'];
                                                  await loadKlayCurrency();
                                                  if (_klayCurrency == 0.0) {
                                                    await displayDialog_checkonly(context, "?????? ??????", "???????????? ????????? ???????????? ????????????. ?????? ??? ?????? ????????? ?????????.");
                                                    return;
                                                  }
                                                  final immidiate_purchase = await showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text("??????"),
                                                      content: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text: "?????? ???????????? ?????????????????????.\n\n",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            const TextSpan(
                                                              text: "?????? KLAY ?????? ?????? ??? ",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: "${roundDouble(immediate_purchase_price / _klayCurrency, 2)} KLAY",
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            const TextSpan(
                                                              text: "??? ???????????????.\n\n",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            const TextSpan(
                                                              text: "?????? ?????? ??? ???????????? ????????? ???????????? ?????? ????????? ??? ????????????.",
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            const TextSpan(
                                                              text: "\n\n?????? ?????? ???????????????????",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget> [
                                                        TextButton(
                                                          child: const Text('Cancel'),
                                                          onPressed: () => Navigator.pop(context, false),
                                                        ),
                                                        TextButton(
                                                          child: const Text('OK'),
                                                          onPressed: () => Navigator.pop(context, true),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (immidiate_purchase) {
                                                    final kas_address_data = await getKasAddress(); // jwt token???????????? kas_address ????????????
                                                    final owner = widget.owner!;
                                                    if (kas_address_data['statusCode'] != 200) {
                                                      // jwt token???????????? kas_address??? ???????????? ????????? ??????
                                                      String? message = kas_address_data["msg"];
                                                      String errorMessage = "?????? ????????? ???????????? ???????????????.\n\n$message";
                                                      displayDialog_checkonly(context, "?????? ??????", errorMessage);
                                                      return;
                                                    }

                                                    final bidder = kas_address_data['data'][0]['kas_address'];
                                                    double payment_klay = auction_details['immediate_purchase_price'] / _klayCurrency;
                                                    if (payment_klay.isInfinite) {
                                                      // _klayCurrency??? 0??? ??????
                                                      String errorMessage = "?????? ????????? ??????????????????.\n\nKLAY ?????? ????????? ???????????? ???????????????.";
                                                      displayDialog_checkonly(context, "?????? ?????? ??????", errorMessage);
                                                      return;
                                                    }

                                                    Map<String, dynamic> klayTransactionData = await klayTransaction(bidder, payment_klay.toString(), owner);
                                                    if (klayTransactionData['statusCode'] != 200) {
                                                      // ???????????? ??????
                                                      String message = klayTransactionData["msg"];
                                                      String errorMessage = "?????? ????????? ??????????????????.\n\n$message";
                                                      displayDialog_checkonly(context, "?????? ?????? ??????", errorMessage);
                                                      return;
                                                    }

                                                    Map<String, dynamic>kip17TokenTransferData = await kip17TokenTransfer(details['category'], widget.token_id!, owner, owner, bidder);

                                                    if (kip17TokenTransferData['statusCode'] != 200) {
                                                      // ?????? ?????? ??????
                                                      String message = kip17TokenTransferData["msg"];
                                                      String errorMessage = "?????? ????????? ??????????????????.\n\n$message";
                                                      displayDialog_checkonly(context, "?????? ?????? ??????", errorMessage);

                                                      // ?????? ?????? ????????? ?????? klay ?????? ??????
                                                      // ????????? 1. owner??? klay ????????? ???????????? ????????? ???????????? ?????????.
                                                      payment_klay = payment_klay + 0.000525;
                                                      Map<String, dynamic>klayTransactionData = await klayTransaction(owner, payment_klay.toString(), bidder);
                                                      if (klayTransactionData['statusCode'] == 200) {
                                                        displayDialog_checkonly(context, "?????? ?????? ??????", "??? ??? ?????? ????????? ????????? ?????????????????????.\n\n?????? ????????? ????????????."
                                                        );
                                                      } else {
                                                        displayDialog_checkonly(context, "?????? ?????? ??????", "??? ??? ?????? ????????? ????????? ?????????????????????.\n\n????????? ????????? ????????? ????????????."
                                                        );
                                                      }
                                                      return;
                                                    }

                                                    Map<String, dynamic>updateTicketOwnerData =
                                                    await updateTicketOwner(bidder, widget.token_id!);
                                                    if (updateTicketOwnerData['statusCode'] != 200) {
                                                      // DB??? ?????? owner??? ???????????? ?????? ??????
                                                      String errorMessage = "?????? ????????? ??????????????????.\n\n???????????? ????????? ???????????? ????????????.";
                                                      displayDialog_checkonly(context, "?????? ?????? ??????", errorMessage);
                                                      return;
                                                    }

                                                    Map<String, dynamic>terminateAuctionData = await terminateAuction(bidder);

                                                    if (terminateAuctionData['statusCode'] != 200) {
                                                      String errorMessage = "?????? ????????? ??????????????????.\n\n${terminateAuctionData['msg']}";
                                                      displayDialog_checkonly(context, "?????? ?????? ??????", errorMessage);
                                                      return;
                                                    }

                                                    await displayDialog_checkonly(context, "?????? ?????? ??????", "?????? ????????? ??????????????? ?????????????????????.");
                                                    Navigator.of(context).pop();
                                                    return;
                                                  } else {
                                                    return;
                                                  }
                                                }

                                                final selected = await displayDialog_YesOrNo(context, "????????????", "??? ???????????? ????????? ?????????????????????????");
                                                if (selected) {
                                                  bid();
                                                }
                                              },
                                              child: const Text(
                                                "????????????",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(9.5),
                                                ),
                                                minimumSize: Size.fromHeight(height * 0.062),
                                                primary: theme ? const Color(0xffe8e8e8) : const Color(0xffEE3D43),
                                              ),
                                            ),
                                          ]
                                      ),
                                    ]
                                ),
                              ],
                            ),
                          )
                      )
                  ),
                ]
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
            //color: Colors.black,
            width: (width / 7),
            height: 50,
            alignment: Alignment.center,
            child: Text(
              ranking,
              style: const TextStyle(
                //fontFamily: 'FiraBold',
                fontSize: 20,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: width / 6,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              bidder,
              style: const TextStyle(
                //fontFamily: 'FiraBold',
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: width / 3,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              bid_date,
              style: const TextStyle(
                //fontFamily: 'FiraBold',
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            //height: 50,
            alignment: Alignment.center,
            child: Text(
              bid_price,
              style: const TextStyle(
                //fontFamily: 'FiraBold',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
