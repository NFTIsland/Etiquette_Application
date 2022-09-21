import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/utils.dart';
import 'package:Etiquette/widgets/event.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Providers/Coinone/get_klay_currency.dart';
import 'package:Etiquette/Providers/DB/get_ticket_seat_image_url.dart';

class TimePickerPage extends StatefulWidget{
  String product_name;
  String place;
  String category = "";
  String date;
  String time;
  TimePickerPage({
    Key? key,
    required this.product_name,
    required this.place,
    required this.date,
    required this.time,
    category,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TimePickerPage();
}

class _TimePickerPage extends State<TimePickerPage>{
  Timer? timer;
  void initState(){
    super.initState();
    load_seat_class(widget.date!, widget.time!);
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
  }
  Widget build(context){
    return Scaffold(
      body : SafeArea(
        child :
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children : <Widget>[
              Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FixedColumnWidth(140.0),
                  },
                  children: [
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
                                    load_seat_no(widget.date!, widget.time!, seat_class_value);
                                    load_price();
                                  });
                                },
                              ),
                            )
                        ),

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
                  )
                ]
              )
            ]
        )
      )


    );
  }

  String image_url = "";

  Future<void> loadTicketSeatImage() async {
    Map<String, dynamic> data = await getTicketSeatImageUrl(
        widget.product_name!, widget.place!);
    if (data["statusCode"] == 200) {
      image_url = data['data'][0]['seat_image_url'];
    } else {
      image_url = "";
    }
  }

  String _price = "";
  String _payInfo = "";
  String _klayInfo = "";

  String klayRound(double klay) {
    return roundDouble(klay, 2).toString().replaceAllMapped(reg, mathFunc);
  }

  double _klayCurrency = 0.0;

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

  Future<void> load_price() async {
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

  //String date_value = widget.date;
  //String time_value = widget.time;
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
}