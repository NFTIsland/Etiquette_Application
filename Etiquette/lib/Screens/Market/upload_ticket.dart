import 'dart:async';
import 'dart:convert';

import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  UploadTicket({Key? key,
    required this.token_id,
    required this.product_name,
    required this.original_price,
    required this.owner,
    required this.place,
    required this.performance_date,
    required this.category,
    required this.seat_class,
    required this.seat_No})
      : super(key: key);

  @override
  State createState() => _UploadTicket();
}

class _UploadTicket extends State<UploadTicket>
    with SingleTickerProviderStateMixin {
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
    Scrollable.ensureVisible(_tabbar.currentContext!,
        duration: Duration(
          milliseconds: 500,
        ),
        curve: Curves.ease);
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
            context, "티켓 업로드", "티켓 업로드가 성공적으로 완료되었습니다.");
        Navigator.of(context).pop();
        send_data_for_schedule();
      } else {
        displayDialog_checkonly(context, "티켓 업로드", "티켓 업로드에 실패했습니다.");
      }
    } catch (ex) {
      print("티켓 업로드 --> ${ex.toString()}");
      displayDialog_checkonly(context, "티켓 업로드", "티켓 업로드에 실패했습니다.");
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
      print("티켓 업로드 --> ${ex.toString()}");
      displayDialog_checkonly(context, "티켓 업로드", "티켓 업로드에 실패했습니다.");
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
        displayDialog_checkonly(context, "통신 오류", errorMessage);
      }
    } else {
      String errorMessage = "${kas_address_data['msg']}";
      displayDialog_checkonly(context, "통신 오류", errorMessage);
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
              appBar: appbarWithArrowBackButton("티켓 상세 정보", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                appBar: defaultAppbar("티켓 상세 정보"),
                body: Column(
                    children: <Widget>[
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
                                  Image(
                                      image: AssetImage("assets/image/mainlogo.png"),
                                      width: width,
                                      height: width * 0.33,
                                      fit: BoxFit.fill),
                                  Positioned(
                                      left: width * 0.05,
                                      top: width * 0.05,
                                      child: Image.network(
                                          "https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg",
                                          width: width * 0.25,
                                          height: width * 0.38,
                                          fit: BoxFit.fill))
                                ],
                                clipBehavior: Clip.none,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(width * 0.05, width * 0.15, width * 0.05, 0),
                                child: Text(
                                    "${widget.product_name!}",
                                    style: TextStyle(fontSize: 20, fontFamily: 'NotoSans', fontWeight: FontWeight.w800)
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(width * 0.04, width * 0.01, width * 0.04, 0
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(children: <Widget>[
                                            Icon(Icons.location_on_outlined, size: 20),
                                            SizedBox(width: width * 0.01),
                                            Text(
                                                "${widget.place!}",
                                                style: TextStyle(fontSize: 15, fontFamily: 'Pretendard', fontWeight: FontWeight.w400)
                                            )
                                          ]),
                                          LikeButton(
                                            circleColor: const CircleColor(
                                                start: Color(0xff00ddff),
                                                end: Color(0xff0099cc)),
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
                                      Row(children: [
                                        Icon(Icons.event_seat_outlined, size: 20),
                                        SizedBox(width: width * 0.01),
                                        Text(
                                            "${widget.seat_class}석 ${widget.seat_No}번",
                                            style: TextStyle(fontSize: 15, fontFamily: 'Pretendard', fontWeight: FontWeight.w400)
                                        )
                                      ])
                                  ])
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
                                    BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(9), topLeft: Radius.circular(9)),
                                        color: Color(0xff333333)
                                    ) :
                                    BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(9), topRight: Radius.circular(9)),
                                        color: Color(0xff333333)
                                    ),
                                    indicatorPadding: EdgeInsets.zero,
                                    labelPadding: EdgeInsets.zero,
                                    controller: tabcontroller,
                                    indicatorWeight: 0,
                                    unselectedLabelStyle:
                                    const TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w500),
                                    unselectedLabelColor: Colors.black,
                                    labelColor: Colors.white,
                                    labelStyle: TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w700),
                                    tabs: [
                                      Tab(
                                        //text: "코멘트",
                                          child: Container(
                                            child: const Text('코멘트'),
                                            alignment: Alignment.center,
                                            height: double.infinity,
                                            decoration: const BoxDecoration(
                                              //color: Colors.white,
                                              border: Border(right: BorderSide(color: Colors.grey),),
                                            ),
                                          )
                                      ),
                                      Tab(
                                        //text: "경매 정보",
                                          child: Container(
                                            child: const Text('경매 정보'),
                                            alignment: Alignment.center,
                                            height: double.infinity,
                                          )
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
                            ]
                          )
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
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("\n판매자의 코멘트\n",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "NotoSans",
                                                  fontWeight: FontWeight.w600)
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
                                                          color: Colors.grey)
                                                  ),
                                                  disabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: Colors.grey)
                                                  ),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: Colors.red)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: "Pretendard",
                                                    fontWeight: FontWeight.w400)
                                            ),
                                          ),
                                        ]
                                    )
                                  ]),
                              ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(top: height * 0.03),
                                children: ListTile.divideTiles(
                                    context: context, tiles: [
                                  ListTile(
                                      title: Row(
                                          children: [
                                            Container(
                                              width: width * 0.25,
                                              child: Text("거래 종료일",
                                                  style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393))
                                              ),
                                            ),
                                        Expanded(
                                            child: auction_end_date == "" ?
                                            ElevatedButton(
                                                onPressed: () {
                                                  if (widget.product_name != "" &&
                                                      widget.place != "" &&
                                                      widget.original_price != "") {
                                                    final maxTime =
                                                    DateTime(
                                                        int.parse(widget.performance_date!.substring(0, 4)),
                                                        int.parse(widget.performance_date!.substring(5, 7)),
                                                        int.parse(widget.performance_date!.substring(8, 10)),
                                                        int.parse(widget.performance_date!.substring(11, 13)),
                                                        int.parse(widget.performance_date!.substring(14, 16)))
                                                        .subtract(const Duration(hours: 3));
                                                    DatePicker.showDateTimePicker(
                                                      context,
                                                      showTitleActions: true,
                                                      minTime: DateTime.now()
                                                          .add(const Duration(minutes: 1)),
                                                      maxTime: maxTime,
                                                      onChanged: (date) {
                                                        print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                                      },
                                                      onConfirm: (date) {
                                                        if (date.isBefore(maxTime) ||
                                                            date.isAtSameMomentAs(maxTime)) {
                                                          setState(() {
                                                            auction_end_date =
                                                            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
                                                            "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                                                          });
                                                        } else {
                                                          displayDialog_checkonly(
                                                              context,
                                                              "티켓 업로드",
                                                              "경매 마감 시각은 티켓 사용 시각으로부터 3시간 전 까지 선택 할 수 있습니다.");
                                                        }
                                                      },
                                                      locale: LocaleType.ko,
                                                    );
                                                  } else {
                                                    displayDialog_checkonly(
                                                        context, "티켓 업로드",
                                                        "업로드 할 티켓을 선택해 주세요.");
                                                  }
                                                },
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  shadowColor: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(9.5)),
                                                  primary: (theme ? const Color(0xffe8e8e8) : Color(0xffEE3D43)
                                                  )
                                              ),
                                                child: const Text(
                                                  '경매 마감 시각 선택',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                )
                                            )
                                                :
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text("$auction_end_date"),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        if (widget.product_name != "" &&
                                                            widget.place != "" &&
                                                            widget.original_price != "") {
                                                          final maxTime = DateTime(
                                                              int.parse(widget.performance_date!.substring(0, 4)),
                                                              int.parse(widget.performance_date!.substring(5, 7)),
                                                              int.parse(widget.performance_date!.substring(8, 10)),
                                                              int.parse(widget.performance_date!.substring(11, 13)),
                                                              int.parse(widget.performance_date!.substring(14, 16)))
                                                              .subtract(const Duration(hours: 3));
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
                                                                displayDialog_checkonly(
                                                                    context,
                                                                    "티켓 업로드",
                                                                    "경매 마감 시각은 티켓 사용 시각으로부터 3시간 전 까지 선택 할 수 있습니다.");
                                                              }
                                                            },
                                                            locale: LocaleType.ko,
                                                          );
                                                        } else {
                                                          displayDialog_checkonly(
                                                              context,
                                                              "티켓 업로드",
                                                              "업로드 할 티켓을 선택해 주세요.");
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          shadowColor: Colors.transparent,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(9.5)),
                                                          primary: (theme ? const Color(0xffe8e8e8) : Color(0xffEE3D43)
                                                          )
                                                      ),
                                                      child: const Text('수정',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                  )
                                                ]
                                            )
                                        )
                                      ])
                                  ),
                                  ListTile(
                                      title: Row(children: [
                                        SizedBox(
                                          width: width * 0.25,
                                          child: Text(
                                              "티켓 원가",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393))),
                                        ),
                                        Expanded(
                                          child: Text(
                                              "${widget.original_price}",
                                              style: TextStyle(
                                                  fontFamily: "NotoSans",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Color(0xff1F1F1F))),

                                        )
                                      ])
                                  ),
                                  ListTile(
                                      title: Row(children: [
                                        Container(
                                          width: width * 0.25,
                                          child: Text("경매 시작가",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393))),
                                        ),
                                        Expanded(
                                            child: TextField(
                                              controller: start_controller,
                                              keyboardType: TextInputType.number,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w400),
                                            )
                                        )
                                      ])),
                                  ListTile(
                                      title: Row(children: [
                                        SizedBox(
                                          width: width * 0.25,
                                          child: Text("입찰 단위",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff808393))),
                                        ),
                                        Expanded(
                                            child: TextField(
                                                controller: bid_controller,
                                                keyboardType: TextInputType.number,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: "Pretendard",
                                                    fontWeight: FontWeight.w400)
                                            )
                                        )
                                      ])),
                                  ListTile(
                                      title: Row(children: [
                                        SizedBox(
                                          width: width * 0.25,
                                          child: Text("즉시 거래가",
                                            style: TextStyle(
                                              fontFamily: "Pretendard",
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Color(0xff808393)
                                            )
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                              controller: buynow_controller,
                                              keyboardType: TextInputType.number,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w400)
                                          )
                                        )
                                      ])),
                                ]).toList(),
                              ),
                            ],
                          ),
                        )
                    )
                  ),
                ]),
                bottomNavigationBar: Container(
                  padding : EdgeInsets.fromLTRB(width*0.03, 0, width*0.03, 0),
                  child: ElevatedButton(
                    child: const Text("티켓 업로드"),
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
                                title: const Text("티켓 업로드"),
                                content: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "위 옵션으로 티켓 업로드를 진행하시겠습니까?\n",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          )
                                      ),
                                      TextSpan(
                                          text: "한번 업로드한 티켓은 취소할 수 없습니다.",
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
                            else {displayDialog_checkonly(context, "티켓 업로드", "경매 마감 날짜 및 시각을 선택해 주세요.");}
                          }
                          else {displayDialog_checkonly(context, "티켓 업로드", "사용자 코멘트를 작성해 주십시오.");}
                      }
                      else {displayDialog_checkonly(context, "티켓 업로드", "조건을 모두 만족하는지 확인해 주십시오.");}
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