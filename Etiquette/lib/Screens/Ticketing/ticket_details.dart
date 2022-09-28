import 'dart:async';
import 'dart:convert';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/Screens/Ticketing/select_ticket.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Screens/Market/upload_ticket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketDetails extends StatefulWidget {
  String? owner;
  String? token_id;
  String? product_name;
  String? place;
  // bool? showPurchaseButton;
  int? bottomButtonType;
  String? seat_class;
  String? seat_No;
  String? booking_start_date;
  String? booking_start_day_of_the_week;
  String? performance_date;

  TicketDetails({
    Key? key,
    this.owner,
    this.token_id,
    this.product_name,
    this.place,
    this.bottomButtonType,
    this.seat_class,
    this.seat_No,
    this.booking_start_date,
    this.booking_start_day_of_the_week,
    this.performance_date
  }) : super(key: key);

  @override
  State createState() => _TicketDetails();
}

class _TicketDetails extends State<TicketDetails> with SingleTickerProviderStateMixin {
  late bool theme;
  late double width;
  late double height;
  int? original_price;
  String? remain;
  bool like = false;
  List tab = ["내용 요약", "가격 정보"];
  late final Future future;
  late Map<String, dynamic> detail;
  List price_list = [];
  String price_description = "";
  String backdrop_url = "";
  String poster_url = "";
  GlobalKey _tabbar = GlobalKey();
  GlobalKey _tabbarview = GlobalKey();

  TabController? tabcontroller;
  ScrollController? scrollController;

  @override
  void dispose() {
    tabcontroller!.dispose();
    scrollController!.dispose();
    super.dispose();
  }

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<int> load_price(String product_name, String seat_class) async {
    final url = "$SERVER_IP/ticket/ticketPrice/$product_name/$seat_class";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        return data["data"][0]["price"];
      } else {
        return 0;
      }
    } catch (ex) {
      print("가격 가져오기 --> ${ex.toString()}");
      return 0;
    }
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
          price_description = buildPriceDescription(
              price_info[0]['seat_class'], price_info[0]['price']);
        } else {
          for (int i = 0; i < len - 1; i++) {
            price_description = price_description +
                buildPriceDescription(
                    price_info[i]['seat_class'], price_info[i]['price']) +
                "\n";
          }
          price_description = price_description +
              buildPriceDescription(price_info[len - 1]['seat_class'],
                  price_info[len - 1]['price']);
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

  void _scrollDown() {
    Scrollable.ensureVisible(
      _tabbar.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  void initState() {
    super.initState();
    tabcontroller = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    scrollController = ScrollController(initialScrollOffset: 0);
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
                body: Column(children: <Widget>[
                  Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                          child: NestedScrollView(
                              headerSliverBuilder: (context, value) {
                                return [
                                  SliverToBoxAdapter(
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget> [
                                        Stack(
                                          children: <Widget>[
                                            Image.network(
                                                detail['backdrop_url'],
                                                width: width,
                                                height: width * 0.4,
                                                fit: BoxFit.fill
                                            ),
                                            Positioned(
                                                left: width * 0.05,
                                                top: width * 0.1,
                                                child: Visibility(
                                                  visible: detail['category'] != "sports",
                                                  child: Image.network(
                                                    detail['poster_url'],
                                                    width: width * 0.25,
                                                    height: width * 0.38,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                            ),
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
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget> [
                                                  Row(
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
                                                  LikeButton(
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
                                                        color: like ? Colors.red : Colors.grey,
                                                        size: 30,
                                                      );
                                                    },
                                                    isLiked: like,
                                                    onTap: onLikeButtonTapped,
                                                  )
                                                ],
                                              ),
                                              Visibility(
                                                visible: widget.bottomButtonType! == 2,
                                                child: Row(
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
                                              ),
                                              const SizedBox(height: 5),
                                              Visibility(
                                                // visible: widget.showPurchaseButton!,
                                                visible: widget.bottomButtonType! == 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.event_seat_outlined, size : 20),
                                                    SizedBox(width: width * 0.01),
                                                    Text(
                                                      "${widget.seat_class}석 ${widget.seat_No}번",
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontFamily: 'Pretendard',
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                                              border: Border.all(color: Colors.grey, width: 1),
                                              borderRadius: BorderRadius.circular(10),
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
                                              tabs: const [
                                                Tab(
                                                  text: "내용 요약",
                                                ),
                                                Tab(
                                                  text: "가격 정보",
                                                )
                                              ],
                                              onTap: (int idx) {
                                                setState(() {
                                                  tabcontroller!.index = idx;
                                                  _scrollDown();
                                                }
                                                );
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
                                                  "\n상세 설명\n",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                                Text(
                                                  detail['description'].replaceAll("...", "‡").replaceAll('\\n', '\n').replaceAll(".", ".\n\n").replaceAll("‡", "..."),
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
                                            const Text("\n좌석 별 가격",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "\n${price_description.replaceAll("\n", "\n\n")}",
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
                                  ],
                                ),
                              ),
                          ),
                      ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(width * 0.03, height * 0.01, width * 0.03, height * 0.011),
                    color: Colors.white24,
                    child: widget.bottomButtonType! == 0 ?
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.5),
                        ),
                        minimumSize: Size.fromHeight(height * 0.062),
                        primary: theme ? const Color(0xffe8e8e8) : Colors.grey[300],
                      ),
                      onPressed: () {

                      },
                      child: Text(
                        "${widget.booking_start_date!.substring(5, 10).replaceAll("-", ".")}(${widget.booking_start_day_of_the_week!}) ${widget.booking_start_date!.substring(11, 16)}에 오픈",
                        style: const TextStyle(
                          // color: theme ? const Color(0xff000000) : const Color(0xff000000),
                          color: Colors.black,
                        ),
                      ),
                    ) : widget.bottomButtonType! == 1 ?
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.5),
                        ),
                        minimumSize: Size.fromHeight(height * 0.062),
                        primary: theme ? const Color(0xffe8e8e8) : const Color(0xffEE3D43),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectTicket(
                              product_name: widget.product_name!,
                              place: widget.place!,
                              category: detail['category'],
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "예매하기",
                        style: TextStyle(
                          color: theme ? const Color(0xff000000) : const Color(0xffffffff),
                        ),
                      ),
                    ) : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.5),
                        ),
                        minimumSize: Size.fromHeight(height * 0.062),
                        primary: theme ? const Color(0xffe8e8e8) : const Color(0xffEE3D43),
                      ),
                      onPressed: () async{
                        original_price =  await load_price(widget.product_name!, widget.seat_class!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadTicket(
                              token_id: widget.token_id,
                              product_name: widget.product_name,
                              owner: widget.owner,
                              place: widget.place,
                              seat_class: widget.seat_class,
                              seat_No: widget.seat_No,
                              performance_date: widget.performance_date,
                              original_price: original_price.toString(),
                              category: detail['category'],
                              poster_url: detail['poster_url'],
                              backdrop_url: detail['backdrop_url'],
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "판매하기",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w600,
                          color: theme ? const Color(0xff000000) : const Color(0xffffffff),
                        ),
                      ),
                    ),
                    // child: Visibility(
                    //   visible: widget.bottomButtonType! > 0,
                    //   // child: widget.showPurchaseButton! ?
                    //   child: widget.bottomButtonType! == 1 ?
                    //   ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 0,
                    //       shadowColor: Colors.transparent,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(9.5),
                    //       ),
                    //       minimumSize: Size.fromHeight(height * 0.062),
                    //       primary: theme ? const Color(0xffe8e8e8) : const Color(0xffEE3D43),
                    //     ),
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => SelectTicket(
                    //             product_name: widget.product_name!,
                    //             place: widget.place!,
                    //             category: detail['category'],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     child: Text(
                    //       "예매하기",
                    //       style: TextStyle(
                    //         color: theme ? const Color(0xff000000) : const Color(0xffffffff),
                    //       ),
                    //     ),
                    //   ) :
                    //   ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 0,
                    //       shadowColor: Colors.transparent,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(9.5),
                    //       ),
                    //       minimumSize: Size.fromHeight(height * 0.062),
                    //       primary: theme ? const Color(0xffe8e8e8) : const Color(0xffEE3D43),
                    //     ),
                    //     onPressed: () async{
                    //       original_price =  await load_price(widget.product_name!, widget.seat_class!);
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => UploadTicket(
                    //             token_id: widget.token_id,
                    //             product_name: widget.product_name,
                    //             owner: widget.owner,
                    //             place: widget.place,
                    //             seat_class: widget.seat_class,
                    //             seat_No: widget.seat_No,
                    //             performance_date: widget.performance_date,
                    //             original_price: original_price.toString(),
                    //             category: detail['category'],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     child: Text(
                    //       "판매하기",
                    //       style: TextStyle(
                    //         fontSize: 15,
                    //         fontFamily: 'NotoSans',
                    //         fontWeight: FontWeight.w600,
                    //         color: theme ? const Color(0xff000000) : const Color(0xffffffff),
                    //       ),
                    //     ),
                    //   ),
                    // ),
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

