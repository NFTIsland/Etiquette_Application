import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Screens/Ticketing/ticket_details.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Screens/Market/ticket_details_with_no_purchase_button.dart';
import 'package:Etiquette/Providers/DB/get_ticket_seat_image_url.dart';

class SelectMarketTicket extends StatefulWidget {
  String? product_name;
  String? place;
  SelectMarketTicket({Key? key, this.product_name, this.place}) : super(key: key);

  @override
  State createState() => _SelectMarketTicket();
}

class _SelectMarketTicket extends State<SelectMarketTicket> {
  List list = [];
  String image_url = "";
  late final Future future;

  bool isNormalTradeMethod = true;
  bool isAuctionTradeMethod = false;
  late List<bool> isSelected;

  String _price = "";
  String _payInfo = "";
  String _klayInfo = "";
  // String image_url = "https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/seat_image%2Fseoul_a_theater.jpg?alt=media&token=9e93c0ac-960c-4853-916f-731218502647";

  double klayCurrency = 0.0;

  Future<void> loadTicketSeatImage() async {
    Map<String, dynamic> data = await getTicketSeatImageUrl(widget.product_name!, widget.place!);
    if (data["statusCode"] == 200) {
      setState(() {
        image_url = data['data'][0]['seat_image_url'];
      });
    } else {
      setState(() {
        image_url = "";
      });
    }
  }

  void toggleSelect(value) {
    init_performanceDateItems();
    init_performanceTimeItems();
    init_seatClassItems();
    init_seatNoItems();
    if (value == 0) {
      isNormalTradeMethod = true;
      isAuctionTradeMethod = false;
      init_general_PerformanceDate();
    } else {
      isNormalTradeMethod = false;
      isAuctionTradeMethod = true;
    }
    setState(() {
      isSelected = [isNormalTradeMethod, isAuctionTradeMethod];
    });
  }

  List _performanceDate = new List.empty(growable: true);
  String date_value = "예매 일자 선택";
  List<DropdownMenuItem<String>> _performanceDateItems = [
    DropdownMenuItem(
      child: const Text("예매 일자 선택"),
      value: "예매 일자 선택",
    )
  ];

  Future<void> init_performanceDateItems() async {
    _performanceDate = new List.empty(growable: true);
    date_value = "예매 일자 선택";
    _performanceDateItems = [
      DropdownMenuItem(
        child: const Text("예매 일자 선택"),
        value: "예매 일자 선택",
      )
    ];
  }

  List _performanceTime = new List.empty(growable: true);
  String time_value = "예매 시각 선택";
  List<DropdownMenuItem<String>> _performanceTimeItems = [
    DropdownMenuItem(
      child: const Text("예매 시각 선택"),
      value: "예매 시각 선택",
    )
  ];

  Future<void> init_performanceTimeItems() async {
    _performanceTime = new List.empty(growable: true);
    time_value = "예매 시각 선택";
    _performanceTimeItems = [
      DropdownMenuItem(
        child: const Text("예매 시각 선택"),
        value: "예매 시각 선택",
      )
    ];
  }

  List _seatClass = new List.empty(growable: true);
  String seat_class_value = "좌석 등급 선택";
  List<DropdownMenuItem<String>> _seatClassItems = [
    DropdownMenuItem(
      child: const Text("좌석 등급 선택"),
      value: "좌석 등급 선택",
    )
  ];

  Future<void> init_seatClassItems() async {
    _seatClass = new List.empty(growable: true);
    seat_class_value = "좌석 등급 선택";
    _seatClassItems = [
      DropdownMenuItem(
        child: const Text("좌석 등급 선택"),
        value: "좌석 등급 선택",
      )
    ];
  }

  List _seatNo = new List.empty(growable: true);
  String seat_no_value = "좌석 번호 선택";
  List<DropdownMenuItem<String>> _seatNoItems = [
    DropdownMenuItem(
      child: const Text("좌석 번호 선택"),
      value: "좌석 번호 선택",
    )
  ];

  Future<void> init_seatNoItems() async {
    _seatNo = new List.empty(growable: true);
    seat_no_value = "좌석 번호 선택";
    _seatNoItems = [
      DropdownMenuItem(
        child: const Text("좌석 번호 선택"),
        value: "좌석 번호 선택",
      )
    ];
  }

  Future<void> init_general_PerformanceDate() async {
    final url = "$SERVER_IP/market/general/ticketPerformanceDate/${widget.product_name!}/${widget.place!}";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        _performanceDate = data["data"];
        Set set_performanceDate = {};
        for (Map<String, dynamic> item in _performanceDate) {
          set_performanceDate.add(item["date"]);
        }
        List list_performanceDate = set_performanceDate.toList();
        for (var item in list_performanceDate) {
          _performanceDateItems.add(DropdownMenuItem(
            value: item,
            child: Text(item),
          ));
        }
      } else {
        _performanceDate = [];
      }
      setState(() {});
    } catch (ex) {
      print("예매 일자 선택 --> ${ex.toString()}");
    }
  }

  Future<void> load_general_performance_time(String date_value) async {
    if (date_value != "예매 일자 선택") {
      final url = "$SERVER_IP/market/general/ticketPerformanceTime/${widget.product_name!}/${widget.place!}/${date_value}";
      try {
        await init_performanceTimeItems();
        var res = await http.get(Uri.parse(url));
        Map<String, dynamic> data = json.decode(res.body);
        if (res.statusCode == 200) {
          _performanceTime = data["data"];
          Set set_performanceTime = {};
          for (Map<String, dynamic> item in _performanceTime) {
            set_performanceTime.add(item["time"]);
          }
          List list_performanceTime = set_performanceTime.toList();
          for (var item in list_performanceTime) {
            _performanceTimeItems.add(DropdownMenuItem(
              value: item,
              child: Text(item),
            ));
          }
        } else {
          _performanceTime = [];
        }
      } catch (ex) {
        print("예매 시각 선택 --> ${ex.toString()}");
      }
    }
  }

  @override
  void initState(){
    super.initState();
    isSelected = [isNormalTradeMethod, isAuctionTradeMethod];
    loadTicketSeatImage();
    getTheme();
    future = init_general_PerformanceDate();
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
              body: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 18, right: 18),
                    child: Column(
                      children: <Widget> [
                        Column(
                          children: <Widget> [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                              child: ElevatedButton(
                                child: const Text(
                                  "티켓 상세 정보",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  fixedSize: const Size(180, 45),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => TicketDetailsWithNoPurchaseButton(
                                            product_name: widget.product_name!,
                                            place: widget.place!,
                                          )
                                      )
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: 300.0,
                              height: 150.0,
                              child: image_url != "" ?
                              Image.network(
                                image_url,
                                width: 250,
                                height: 250,
                              ) : const Center(
                                child: Text(
                                  "등록된 좌석 이미지가 없습니다.",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            ToggleButtons(
                              children: const <Widget> [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  child: Text(
                                    '일반 거래',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  child: Text(
                                    '경매 거래',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                              isSelected: isSelected,
                              onPressed: toggleSelect,
                            ),
                            const SizedBox(height: 20),
                            Visibility(
                              visible: _performanceDate.isNotEmpty,
                              child: Table(
                                border: TableBorder.all(),
                                columnWidths: const {
                                  0: FixedColumnWidth(140.0),
                                },
                                children: <TableRow> [
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
                                                  style: const TextStyle(
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
                                          margin: const EdgeInsets.all(12.0),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "예매 일자",
                                            style: TextStyle(
                                              fontFamily: 'FiraBold',
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Container(
                                          margin: const EdgeInsets.all(12.0),
                                          alignment: Alignment.center,
                                          child: DropdownButtonFormField(
                                            value: date_value,
                                            icon: const Icon(Icons.expand_more),
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              labelStyle: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            items: _performanceDateItems,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                date_value = newValue!;
                                                load_general_performance_time(date_value);
                                                init_seatClassItems();
                                                init_seatNoItems();
                                                _price = "";
                                                _payInfo = "";
                                                _klayInfo = "";
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Visibility(
                              visible: _performanceDate.isEmpty,
                              child: const Text(
                                "현재 판매 중인 티켓이 없습니다.",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isNormalTradeMethod && _performanceDate.isNotEmpty,
                              child: SizedBox(
                                width: 150,
                                child: Center(
                                  child: ElevatedButton(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const <Widget> [
                                        Icon(Icons.credit_card),
                                        Text(
                                          " 구매하기",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(10.0),
                                      backgroundColor: Colors.greenAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                    ),
                                    onPressed: () {

                                    },
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isAuctionTradeMethod && _performanceDate.isNotEmpty,
                              child: SizedBox(
                                width: 150,
                                child: Center(
                                  child: ElevatedButton(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const <Widget> [
                                        Icon(Icons.credit_card),
                                        Text(
                                          " 입찰하기",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(10.0),
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                    ),
                                    onPressed: () {

                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
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