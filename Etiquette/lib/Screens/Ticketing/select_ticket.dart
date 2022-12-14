import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/Providers/Coinone/get_klay_currency.dart';
import 'package:Etiquette/Providers/DB/get_ticket_seat_image_url.dart';
import 'package:Etiquette/widgets/event.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/Providers/DB/update_ticket_owner.dart';
import 'package:Etiquette/Providers/KAS/Kip17/kip17_token_transfer.dart';
import 'package:Etiquette/Providers/KAS/Wallet/klay_transaction.dart';
import 'package:Etiquette/widgets/day_picker_page.dart';


class SelectTicket extends StatefulWidget {
  String? product_name;
  String? place;
  String? category;
  final List<Event> events;

  SelectTicket({Key? key, this.product_name, this.place, this.category, this.events = const []}) : super(key: key);

  @override
  State createState() => _SelectTicket();
}

class _SelectTicket extends State<SelectTicket> {
  late bool theme;
  late double width;
  late double height;
  String? remain;
  late final Future future;

  String _price = "";
  String _payInfo = "";
  String _klayInfo = "";

  // String image_url = "https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/seat_image%2Fseoul_a_theater.jpg?alt=media&token=9e93c0ac-960c-4853-916f-731218502647";
  String image_url = "";

  double _klayCurrency = 0.0;

  List _performanceDate = new List.empty(growable: true);
  String date_value = "예매 일자 선택";
  List<DropdownMenuItem<String>> _performanceDateItems = [
    DropdownMenuItem(
      child: const Text("예매 일자 선택"),
      value: "예매 일자 선택",
    )
  ];

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

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> init_PerformanceDate() async {
    final url = "$SERVER_IP/ticket/ticketPerformanceDate/${widget
        .product_name!}/${widget.place!}";
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
        for (String item in list_performanceDate) {
          _performanceDateItems.add(DropdownMenuItem(
            value: item,
            child: Text(item.replaceAll("-", ".")),
          ));
        }
      } else {
        _performanceDate = [];
      }
    } catch (ex) {
      print("티켓 선택 --> ${ex.toString()}");
    }
  }

  Future<void> load_performance_time(String date_value) async {
    if (date_value != "예매 일자 선택") {
      final url = "$SERVER_IP/ticket/ticketPerformanceTime/${widget
          .product_name!}/${widget.place!}/${date_value}";
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
          for (String item in list_performanceTime) {
            _performanceTimeItems.add(DropdownMenuItem(
              value: item,
              child: Text(item.substring(0, 5)),
            ));
          }
        } else {
          _performanceTime = [];
        }
      } catch (ex) {
        print("예매 일자 선택 --> ${ex.toString()}");
      }
    }
  }

  Future<void> load_seat_class(String date_value, String time_value) async {
    if (time_value != "예매 시각 선택") {
      final url = "$SERVER_IP/ticket/ticketSeatClass/${widget
          .product_name!}/${widget.place!}/${date_value}/${time_value}";
      try {
        await init_seatClassItems();
        var res = await http.get(Uri.parse(url));
        Map<String, dynamic> data = json.decode(res.body);
        if (res.statusCode == 200) {
          _seatClass = data["data"];
          Set set_seatClass = {};
          for (Map<String, dynamic> item in _seatClass) {
            set_seatClass.add(item["seat_class"]);
          }
          List list_seatClass = set_seatClass.toList();
          for (var item in list_seatClass) {
            _seatClassItems.add(DropdownMenuItem(
              value: item,
              child: Text(item),
            ));
          }
        } else {
          _seatClass = [];
        }
      } catch (ex) {
        print("좌석 등급 선택 --> ${ex.toString()}");
      }
    }
  }

  Future<void> load_seat_no(String date_value, String time_value,
      String seat_class_value) async {
    if (seat_class_value != "좌석 등급 선택") {
      final url = "$SERVER_IP/ticket/ticketSeatNo/${widget
          .product_name!}/${widget
          .place!}/${date_value}/${time_value}/${seat_class_value}";
      try {
        await init_seatNoItems();
        var res = await http.get(Uri.parse(url));
        Map<String, dynamic> data = json.decode(res.body);
        if (res.statusCode == 200) {
          _seatNo = data["data"];
          Set set_seatNo = {};
          for (Map<String, dynamic> item in _seatNo) {
            set_seatNo.add(item["seat_No"]);
          }
          List list_seatNo = set_seatNo.toList();
          for (var item in list_seatNo) {
            _seatNoItems.add(DropdownMenuItem(
              value: item,
              child: Text(item),
            ));
          }
        } else {
          _seatNo = [];
        }
      } catch (ex) {
        print("좌석 번호 선택 --> ${ex.toString()}");
      }
    }
  }

  Future<void> load_price() async {
    if (date_value != "예매 일자 선택" && time_value != "예매 시각 선택" &&
        seat_class_value != "좌석 등급 선택") {
      final url = "$SERVER_IP/ticket/ticketPrice/${widget
          .product_name!}/${seat_class_value}";
      try {
        var res = await http.get(Uri.parse(url));
        Map<String, dynamic> data = json.decode(res.body);
        if (res.statusCode == 200) {
          int ticket_price = data["data"][0]["price"];
          setState(() {
            _price = ticket_price.toString();
          });
          _payInfo = "최종 결제 금액: ${_price.replaceAllMapped(reg, mathFunc)}원";
          _klayInfo = "(약 ${klayRound(ticket_price / _klayCurrency)} KLAY)";
        } else {
          setState(() {
            _price = "";
          });
        }
      } catch (ex) {
        print("가격 가져오기 --> ${ex.toString()}");
      }
    }
  }

  Future<void> loadKlayCurrency() async {
    Map<String,
        dynamic> data = await getKlayCurrency(); // 현재 KLAY 시세 정보를 API를 통해 가져옴
    if (data["statusCode"] == 200) { // 현재 KLAY 시세 정보를 정상적으로 가져옴
      String klayCurrency = data['lastCurrency'];
      _klayCurrency = double.parse(klayCurrency);
    } else {
      _klayCurrency = 0.0;
    }
  }

  String klayRound(double klay) {
    return roundDouble(klay, 2).toString().replaceAllMapped(reg, mathFunc);
  }

  Future<void> loadTicketSeatImage() async {
    Map<String, dynamic> data = await getTicketSeatImageUrl(
        widget.product_name!, widget.place!);
    if (data["statusCode"] == 200) {
      image_url = data['data'][0]['seat_image_url'];
    } else {
      image_url = "";
    }
  }

  Future<Map<String, dynamic>> loadTicketTokenIdAndOwner(String date_value,
      String time_value, String seat_class_value, String seat_no_value) async {
    final url = "$SERVER_IP/ticket/ticketTokenIdAndOwner/${widget
        .product_name!}/${widget
        .place!}/${date_value}/${time_value}/${seat_class_value}/${seat_no_value}";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        return {
          "token_id": data['data'][0]['token_id'],
          "owner": data['data'][0]['owner']
        };
      } else {
        return {
          "token_id": "",
          "owner": "",
        };
      }
    } catch (ex) {
      print("티켓 소유자 가져오기 --> ${ex.toString()}");
      return {
        "token_id": "",
        "owner": "",
      };
    }
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    getTheme();
    loadKlayCurrency();
    loadTicketSeatImage();
    timer = Timer.periodic(
      const Duration(seconds: 3), // 3초 마다 자동 갱신
          (timer) {
        setState(() {
          loadKlayCurrency();
        });
      },
    );
    future = init_PerformanceDate();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    width = MediaQuery
        .of(context)
        .size
        .width;
    height = MediaQuery
        .of(context)
        .size
        .height;

    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("Error")
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: defaultAppbar("티켓 선택"),
              body: Container(

                          height : height,
                          alignment: Alignment.center,
                            child :
                        DayPickerPage(
                          events: events,
                          product_name: widget.product_name,
                          place: widget.place,
                          category: widget.category,
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

  final List<Event> events = [
  /*
    Event(DateTime.now(), "Today event"),

    Event(DateTime.now().subtract(Duration(days: 3)), "Ev1"),
    Event(DateTime.now().subtract(Duration(days: 13)), "Ev2"),
    Event(DateTime.now().subtract(Duration(days: 30)), "Ev3"),
    Event(DateTime.now().add(Duration(days: 3)), "Ev4"),
    Event(DateTime.now().add(Duration(days: 13)), "Ev5"),
    Event(DateTime.now().add(Duration(days: 30)), "Ev6"),

     */
  ];
}
/*
Padding(
                  padding : const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget> [
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                                          load_performance_time(date_value);
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
                            TableRow(
                              children: <Widget> [
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Container(
                                    margin: const EdgeInsets.all(12.0),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "예매 시각",
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
                                      value: time_value,
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
                                      items: _performanceTimeItems,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          time_value = newValue!;
                                          load_seat_class(date_value, time_value);
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
                            TableRow(
                                children: <Widget>[
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      margin: const EdgeInsets.all(12.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                          "좌석 등급",
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
                                        margin: const EdgeInsets.all(12.0),
                                        alignment: Alignment.center,
                                        child: DropdownButtonFormField(
                                          value: seat_class_value,
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
                                          items: _seatClassItems,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              seat_class_value = newValue!;
                                              load_seat_no(date_value, time_value, seat_class_value);
                                              load_price();
                                            });
                                          },
                                        ),
                                      )
                                  ),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      margin: const EdgeInsets.all(12.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                          "좌석 번호",
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
                                        margin: const EdgeInsets.all(12.0),
                                        alignment: Alignment.center,
                                        child: DropdownButtonFormField(
                                          value: seat_no_value,
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
                                          items: _seatNoItems,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              seat_no_value = newValue!;
                                            });
                                          },
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
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Column(
                            children: <Widget> [
                              Text(
                                _payInfo,
                                style: const TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                _klayInfo,
                                style: const TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Center(
                          child: ElevatedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget> [
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.white,
                                ),
                                Text(
                                  " 결제",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10.0),
                              onPrimary: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)
                              ),
                            ),
                            onPressed: () async {
                              if (date_value != "예매 일자 선택"
                                  && time_value != "예매 시각 선택"
                                  && seat_class_value != "좌석 등급 선택"
                                  && seat_no_value != "좌석 번호 선택") {
                                final pay_selected = await displayDialog_YesOrNo(context, "티켓 결제", "위 옵션으로 결제하시겠습니까?");
                                if (pay_selected) { // 다이얼 로그에서 OK 누름
                                  final kas_address_data = await getKasAddress(); // jwt token으로부터 kas_address 가져오기
                                  final tokenId_and_owner = await loadTicketTokenIdAndOwner(date_value, time_value, seat_class_value, seat_no_value); // 5가지 데이터로 token_id와 owner 가져오기

                                  if (kas_address_data['statusCode'] == 200) {
                                    if (tokenId_and_owner['owner'] != "" && tokenId_and_owner['token_id'] != "") {
                                      final sender = kas_address_data['data'][0]['kas_address'];
                                      final owner = tokenId_and_owner['owner'];
                                      final token_id = tokenId_and_owner['token_id'];

                                      double? parse_price = double.tryParse(_price);
                                      if (parse_price != null) {
                                        double payment_klay = parse_price / _klayCurrency;

                                        if (payment_klay.isFinite) {
                                          Map<String, dynamic> klayTransactionData = await klayTransaction(sender, payment_klay.toString(), owner);

                                          if (klayTransactionData['statusCode'] == 200) { // 트랜잭션 성공
                                            Map<String, dynamic> kip17TokenTransferData = await kip17TokenTransfer(widget.category!, token_id, owner, owner, sender);

                                            if (kip17TokenTransferData['statusCode'] == 200) {
                                              Map<String, dynamic> updateTicketOwnerData = await updateTicketOwner(sender, token_id);

                                              if (updateTicketOwnerData['statusCode'] == 200) {
                                                displayDialog_checkonly(context, "티켓 결제", "결제가 성공적으로 완료되었습니다.");
                                              } else { // DB에 티켓 owner를 업데이트 하지 못함
                                                String errorMessage = "티켓 결제에 실패했습니다.\n\n서버와의 통신이 원활하지 않습니다.";
                                                displayDialog_checkonly(context, "티켓 결제", errorMessage);
                                              }
                                            } else { // 토큰 전송 실패
                                              String message = kip17TokenTransferData["msg"];
                                              String errorMessage = "티켓 결제에 실패했습니다.\n\n$message";
                                              displayDialog_checkonly(context, "티켓 결제", errorMessage);

                                              // 토큰 전송 실패로 인한 klay 환불 조치
                                              // 문제점 1. owner의 klay 잔액이 부족하면 환불이 진행되지 않는다.
                                              payment_klay = payment_klay + 0.000525;
                                              Map<String, dynamic> klayTransactionData = await klayTransaction(owner, payment_klay.toString(), sender);
                                              if (klayTransactionData['statusCode'] == 200) {
                                                displayDialog_checkonly(context, "티켓 결제", "알 수 없는 오류로 거래가 취소되었습니다.\n\n다시 시도해 주십시오.");
                                              } else {
                                                displayDialog_checkonly(context, "티켓 결제", "알 수 없는 오류로 거래가 취소되었습니다.\n\n서비스 센터에 문의해 주십시오.");
                                              }
                                            }
                                          } else { // 트랜잭션 실패
                                            String message = klayTransactionData["msg"];
                                            String errorMessage = "티켓 결제에 실패했습니다.\n\n$message";
                                            displayDialog_checkonly(context, "티켓 결제", errorMessage);
                                          }
                                        } else { // _klayCurrency가 0일 경우
                                          String errorMessage = "티켓 결제에 실패했습니다.\n\nKLAY 환율 정보를 받아오지 못했습니다.";
                                          displayDialog_checkonly(context, "티켓 결제", errorMessage);
                                        }
                                      } else { // _price를 숫자로 변환하지 못함
                                        String errorMessage = "티켓 결제에 실패했습니다.\n\n가격 정보를 받아오지 못했습니다.";
                                        displayDialog_checkonly(context, "티켓 결제", errorMessage);
                                      }
                                    } else { // token_id와 owner 주소를 가져오지 못함
                                      displayDialog_checkonly(context, "티켓 결제", "이미 결제가 완료된 티켓입니다.");
                                    }
                                  } else { // jwt token으로부터 kas_address를 가져오지 못했을 경우
                                    String? message = kas_address_data["msg"];
                                    String errorMessage = "잔액 정보를 가져오지 못했습니다.\n\n$message";
                                    displayDialog_checkonly(context, "통신 오류", errorMessage);
                                  }
                                }
                              } else {
                                displayDialog_checkonly(context, "티켓 선택", "옵션을 모두 선택해 주세요.");
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
 */