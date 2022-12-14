import 'dart:async';
import 'dart:convert';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utilities/add_comma_to_number.dart';

class UploadTicket extends StatefulWidget {
  String? token_id;
  String? product_name;
  String? owner;
  String? place;
  String? performance_date;
  String? seat_class;
  String? seat_No;
  String? original_price;
  String? category;
  String? poster_url;
  String? backdrop_url;

  UploadTicket({Key? key,
    required this.token_id,
    required this.product_name,
    required this.original_price,
    required this.owner,
    required this.place,
    required this.performance_date,
    required this.category,
    required this.seat_class,
    required this.seat_No,
    required this.poster_url,
    required this.backdrop_url})
      : super(key: key);

  @override
  State createState() => _UploadTicket();
}

class _UploadTicket extends State<UploadTicket> with SingleTickerProviderStateMixin {
  late bool theme;
  late double width;
  late double height;
  String? remain;
  String _price = "";
  String previous_bid_price = "-";
  String minimum_bid_price = "0";
  double _klayCurrency = 0.0;
  String auction_end_date = "";
  bool like = false;
  final comments_controller = TextEditingController();

  final start_controller = TextEditingController();
  final bid_controller = TextEditingController();
  final buynow_controller = TextEditingController();

  GlobalKey _tabbar = GlobalKey();
  GlobalKey _tabbarview = GlobalKey();

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

  Future<void> upload_ticket() async {
    const url = "$SERVER_IP/market/setTicketToBid";
    try {
      var res = await http.post(Uri.parse(url), body: {
        "token_id": widget.token_id,
        "auction_start_price": start_controller.text,
        "bid_unit": bid_controller.text,
        "immediate_purchase_price": buynow_controller.text,
        "auction_end_date": auction_end_date,
        "auction_comments": comments_controller.text
      });
      if (res.statusCode == 200) {
        await displayDialog_checkonly(
            context, "?????? ?????????", "?????? ???????????? ??????????????? ?????????????????????.");
        Navigator.of(context).pop();
        send_data_for_schedule();
      } else {
        displayDialog_checkonly(context, "?????? ?????????", "?????? ???????????? ??????????????????.");
      }
    } catch (ex) {
      print("?????? ????????? --> ${ex.toString()}");
      displayDialog_checkonly(context, "?????? ?????????", "?????? ???????????? ??????????????????.");
    }
  }

  Future<void> send_data_for_schedule() async {
    const url = "$SERVER_IP/scheduler/auctionSchedule";
    try {
      await http.post(Uri.parse(url), body: {
        "token_id": widget.token_id,
        "alias": widget.category,
        "auction_end_date": auction_end_date,
      });
    } catch (ex) {
      print("?????? ????????? --> ${ex.toString()}");
      displayDialog_checkonly(context, "?????? ?????????", "?????? ???????????? ??????????????????.");
    }
  }

  @override
  void initState() {
    super.initState();
    tabcontroller = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    scrollController = ScrollController(initialScrollOffset: 0);
    future = getTheme();
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
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
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
                                    children: <Widget>[
                                      Stack(
                                        children: <Widget>[
                                          Image.network(
                                            widget.backdrop_url!,
                                            width: width,
                                            // height: width * 0.33,
                                            height: width * 0.4,
                                            fit: BoxFit.fill,
                                          ),
                                          Positioned(
                                            left: width * 0.05,
                                            top: width * 0.1,
                                            child: Visibility(
                                              visible: widget.category! != "sports",
                                              child: Image.network(
                                                widget.poster_url!,
                                                width: width * 0.25,
                                                height: width * 0.38,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          // Positioned(
                                          //   left: width * 0.05,
                                          //   top: width * 0.05,
                                          //   child: Image.network(
                                          //     "https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg",
                                          //     width: width * 0.25,
                                          //     height: width * 0.38,
                                          //     fit: BoxFit.fill,
                                          //   ),
                                          // ),
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
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget> [
                                                const Icon(Icons.location_on_outlined, size: 20),
                                                SizedBox(width: width * 0.01),
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
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget> [
                                                const Icon(Icons.calendar_month, size: 20),
                                                SizedBox(width: width * 0.01),
                                                Text(
                                                  widget.performance_date ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(Icons.event_seat_outlined, size: 20),
                                                SizedBox(width: width * 0.01),
                                                Text(
                                                  "${widget.seat_class}??? ${widget.seat_No}???",
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
                                          child : Container(
                                            key: _tabbar,
                                            alignment: Alignment.topCenter,
                                            width: width * 0.9,
                                            height: width * 0.09,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey, width: 1),
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color: (theme ? const Color(0xffe8e8e8) : const Color(0xffffffff)),
                                            ),
                                            child: TabBar(
                                              indicator: (tabcontroller!.index == 0) ?
                                              const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(9),
                                                  topLeft: Radius.circular(9),
                                                ),
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
                                                  // text: "?????????",
                                                  child: Container(
                                                    child: const Text('?????????'),
                                                    alignment: Alignment.center,
                                                    height: double.infinity,
                                                    decoration: const BoxDecoration(
                                                      //color: Colors.white,
                                                      border: Border(
                                                        right: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Tab(
                                                  // text: "?????? ??????",
                                                  child: Container(
                                                    child: const Text('?????? ??????'),
                                                    alignment: Alignment.center,
                                                    height: double.infinity,
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
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            body: Container(
                              padding: EdgeInsets.fromLTRB(width * 0.05, 0, width*0.05, 0),
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
                                        children: <Widget> [
                                          const Text("\n???????????? ?????????\n",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "NotoSans",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            child: TextField(
                                              maxLines: 500,
                                              maxLength: 500,
                                              minLines: 30,
                                              //expands: true,
                                              keyboardType: TextInputType.multiline,
                                              controller: comments_controller,
                                              decoration: const InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Pretendard",
                                                fontWeight: FontWeight.w400,
                                              ),
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
                                                    width: width * 0.25,
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
                                                  Expanded(
                                                      child: auction_end_date == "" ?
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            if (widget.product_name != "" && widget.place != "" && widget.original_price != "") {
                                                              final maxTime = DateTime(
                                                                  int.parse(widget.performance_date!.substring(0, 4)),
                                                                  int.parse(widget.performance_date!.substring(5, 7)),
                                                                  int.parse(widget.performance_date!.substring(8, 10)),
                                                                  int.parse(widget.performance_date!.substring(11, 13)),
                                                                  int.parse(widget.performance_date!.substring(14, 16))
                                                              ).subtract(const Duration(hours: 3));
                                                              DatePicker.showDateTimePicker(
                                                                context,
                                                                showTitleActions: true,
                                                                minTime: DateTime.now().add(const Duration(minutes: 1)),
                                                                maxTime: maxTime,
                                                                onChanged: (date) {
                                                                  print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                                                },
                                                                onConfirm: (date) {
                                                                  if (date.isBefore(maxTime) || date.isAtSameMomentAs(maxTime)) {
                                                                    setState(() {
                                                                      auction_end_date =
                                                                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
                                                                          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                                                                    });
                                                                  } else {
                                                                    displayDialog_checkonly(context, "?????? ?????????", "?????? ?????? ????????? ?????? ?????? ?????????????????? 3?????? ??? ?????? ?????? ??? ??? ????????????.");
                                                                  }
                                                                },
                                                                locale: LocaleType.ko,
                                                              );
                                                            } else {
                                                              displayDialog_checkonly(context, "?????? ?????????", "????????? ??? ????????? ????????? ?????????.");
                                                            }
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            elevation: 0,
                                                            shadowColor: Colors.transparent,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(9.5),
                                                            ),
                                                            primary: theme ? const Color(0xffe8e8e8) : const Color(0xffEE3D43),
                                                          ),
                                                          child: const Text(
                                                            '?????? ?????? ?????? ??????',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                      ) :
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: <Widget> [
                                                            Text(auction_end_date),
                                                            ElevatedButton(
                                                                onPressed: () {
                                                                  if (widget.product_name != "" && widget.place != "" && widget.original_price != "") {
                                                                    final maxTime = DateTime(
                                                                        int.parse(widget.performance_date!.substring(0, 4)),
                                                                        int.parse(widget.performance_date!.substring(5, 7)),
                                                                        int.parse(widget.performance_date!.substring(8, 10)),
                                                                        int.parse(widget.performance_date!.substring(11, 13)),
                                                                        int.parse(widget.performance_date!.substring(14, 16))
                                                                    ).subtract(const Duration(hours: 3));
                                                                    DatePicker.showDateTimePicker(
                                                                      context, showTitleActions: true,
                                                                      minTime: DateTime.now().add(const Duration(minutes: 1)),
                                                                      maxTime: maxTime,
                                                                      onChanged: (date) {
                                                                        print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                                                      },
                                                                      onConfirm: (date) {
                                                                        if (date.isBefore(maxTime) || date.isAtSameMomentAs(maxTime)) {
                                                                          setState(() {
                                                                            auction_end_date =
                                                                            "${date.year}-${date.month.toString().padLeft(2, '0')}"
                                                                                "-${date.day.toString().padLeft(2, '0')} "
                                                                                "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                                                                          });
                                                                        } else {
                                                                          displayDialog_checkonly(context, "?????? ?????????", "?????? ?????? ????????? ?????? ?????? ?????????????????? 3?????? ??? ?????? ?????? ??? ??? ????????????.");
                                                                        }
                                                                      },
                                                                      locale: LocaleType.ko,
                                                                    );
                                                                  } else {
                                                                    displayDialog_checkonly(context, "?????? ?????????", "????????? ??? ????????? ????????? ?????????.");
                                                                  }
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  elevation: 0,
                                                                  shadowColor: Colors.transparent,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(9.5),
                                                                  ),
                                                                  primary: theme ? const Color(0xffe8e8e8) : const Color(0xffEE3D43),
                                                                ),
                                                                child: const Text(
                                                                  '??????',
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                            ),
                                                          ],
                                                      ),
                                                  ),
                                                ],
                                            ),
                                        ),
                                        ListTile(
                                          title: Row(
                                            children: [
                                              SizedBox(
                                                width: width * 0.25,
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
                                              Expanded(
                                                child: Text(
                                                  "${widget.original_price?.replaceAllMapped(reg, mathFunc)} ???",
                                                  style: const TextStyle(
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    color: Color(0xff1F1F1F),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListTile(
                                          title: Row(
                                            children: [
                                              Container(
                                                width: width * 0.25,
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
                                              Expanded(
                                                flex: 1,
                                                child: TextField(
                                                  onChanged: (start) {
                                                    setState(() {
                                                      int? _parse = int.tryParse(start);
                                                      int? _original_price = int.tryParse(widget.original_price!);
                                                      if (_parse != null && _original_price != null) {
                                                        if (_parse > _original_price) {
                                                          start_controller.text = (widget.original_price!).toString();
                                                        }
                                                      }
                                                    });
                                                  },
                                                  controller: start_controller,
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: "Pretendard",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: '?????? ????????? ?????? ??????',
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontFamily: 'Pretendard',
                                                    ),
                                                    counterText: "",
                                                    suffixText: " ???",
                                                    suffixStyle: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "Pretendard",
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListTile(
                                          title: Row(
                                            children: [
                                              SizedBox(
                                                width: width * 0.25,
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
                                              Expanded(
                                                child: TextField(
                                                  onChanged: (bid_unit) {
                                                    setState(() {
                                                      int? _parse = int.tryParse(bid_unit);
                                                      int? _original_price = int.tryParse(widget.original_price!);
                                                      if (_parse != null && _original_price != null) {
                                                        if (_parse > _original_price) {
                                                          bid_controller.text = (widget.original_price!).toString();
                                                        }
                                                      }
                                                    });
                                                  },
                                                  controller: bid_controller,
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: "Pretendard",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    suffixText: " ???",
                                                    suffixStyle: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "Pretendard",
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListTile(
                                          title: Row(
                                            children: [
                                              SizedBox(
                                                width: width * 0.25,
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
                                              Expanded(
                                                child: TextField(
                                                  onChanged: (buynow) {
                                                    setState(() {
                                                      int? _parse = int.tryParse(buynow);
                                                      int? _original_price = int.tryParse(widget.original_price!);
                                                      if (_parse != null && _original_price != null) {
                                                        if (_parse > _original_price) {
                                                          buynow_controller.text = (widget.original_price!).toString();
                                                        }
                                                      }
                                                    });
                                                  },
                                                  controller: buynow_controller,
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: "Pretendard",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: '?????? ????????? ?????? ??????',
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontFamily: 'Pretendard',
                                                    ),
                                                    counterText: "",
                                                    suffixText: " ???",
                                                    suffixStyle: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "Pretendard",
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]).toList(),
                                  ),
                                ],
                              ),
                            ),
                        ),
                    ),
                  ],
                ),
                bottomNavigationBar: Container(
                  padding : EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, 0),
                  child: ElevatedButton(
                    child: const Text("?????? ?????????"),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(9.5)),
                      minimumSize: Size.fromHeight(height * 0.062),
                      primary: (theme ? const Color(0xffe8e8e8) : Color(0xffEE3D43)
                      )
                    ),
                    onPressed: () async {
                      int _startPrice = int.parse(start_controller.text);
                      int _bidUnit = int.parse(bid_controller!.text);
                      int _immediatePurchasePrice = int.parse(buynow_controller.text);
                      int _originalPrice = int.parse(widget.original_price!);
                      if (_startPrice <= _originalPrice
                          && (_bidUnit % 100 == 0)
                          && _immediatePurchasePrice <= _originalPrice) {
                          if (comments_controller.text != "") {
                            if (auction_end_date != "") {
                            final selected = await showDialog(
                              context: context,
                              builder: (context) =>
                              AlertDialog(
                                title: const Text("?????? ?????????"),
                                content: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "??? ???????????? ?????? ???????????? ?????????????????????????\n",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          )
                                      ),
                                      TextSpan(
                                          text: "?????? ???????????? ????????? ????????? ??? ????????????.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          )
                                      )
                                    ],
                                  )
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                              );
                              if (selected) {upload_ticket();}
                            }
                            else {displayDialog_checkonly(context, "?????? ?????????", "?????? ?????? ?????? ??? ????????? ????????? ?????????.");}
                          }
                          else {displayDialog_checkonly(context, "?????? ?????????", "????????? ???????????? ????????? ????????????.");}
                      }
                      else {displayDialog_checkonly(context, "?????? ?????????", "????????? ?????? ??????????????? ????????? ????????????.");}
                    },
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}