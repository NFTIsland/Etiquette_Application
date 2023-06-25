import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/Providers/Coinone/get_klay_currency.dart';
import 'package:Etiquette/Providers/DB/get_ticket_seat_image_url.dart';
import 'package:Etiquette/widgets/event.dart';
import 'package:Etiquette/widgets/day_picker_page.dart';
import 'package:Etiquette/Widgets/AlertDialogWidget.dart';

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
    const url = "$SERVER_IP/ticket/ticketPerformanceDate";
    try {
      var res = await http.post(Uri.parse(url), body: {
        "product_name": widget.product_name!,
        "place": widget.place!
      });
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
        await displayDialog_checkonly(context, "티켓 선택", "예매할 수 있는 티켓이 없습니다.");
        Navigator.of(context).pop();
      }
    } catch (ex) {
      print("티켓 선택 --> ${ex.toString()}");
    }
  }

  Future<void> load_performance_time(String date_value) async {
    if (date_value != "예매 일자 선택") {
      const url = "$SERVER_IP/ticket/ticketPerformanceTime";
      try {
        await init_performanceTimeItems();
        var res = await http.post(Uri.parse(url), body: {
          "product_name": widget.product_name!,
          "place": widget.place!,
          "date": date_value
        });
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
      const url = "$SERVER_IP/ticket/ticketSeatClass";
      try {
        await init_seatClassItems();
        var res = await http.post(Uri.parse(url), body: {
          "product_name": widget.product_name!,
          "place": widget.place!,
          "date": date_value,
          "time": time_value
        });
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

  Future<void> load_seat_no(String date_value, String time_value, String seat_class_value) async {
    if (seat_class_value != "좌석 등급 선택") {
      const url = "$SERVER_IP/ticket/ticketSeatNo";
      try {
        await init_seatNoItems();
        var res = await http.post(Uri.parse(url), body: {
          "product_name": widget.product_name!,
          "place": widget.place!,
          "date": date_value,
          "time": time_value,
          "seat_class": seat_class_value
        });
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
    if (date_value != "예매 일자 선택" && time_value != "예매 시각 선택" && seat_class_value != "좌석 등급 선택") {
      const url = "$SERVER_IP/ticket/ticketPrice";
      try {
        var res = await http.post(Uri.parse(url), body: {
          "product_name": widget.product_name!,
          "seat_class": seat_class_value
        });
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
    Map<String, dynamic> data = await getKlayCurrency(); // 현재 KLAY 시세 정보를 API를 통해 가져옴
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
    Map<String, dynamic> data = await getTicketSeatImageUrl(widget.product_name!, widget.place!);
    if (data["statusCode"] == 200) {
      image_url = data['data'][0]['seat_image_url'];
    } else {
      image_url = "";
    }
  }

  Future<Map<String, dynamic>> loadTicketTokenIdAndOwner(String date_value, String time_value, String seat_class_value, String seat_no_value) async {
    const url = "$SERVER_IP/ticket/ticketTokenIdAndOwner";
    try {
      var res = await http.post(Uri.parse(url), body: {
        "product_name": widget.product_name!,
        "place": widget.place!,
        "date": date_value,
        "time": time_value,
        "seat_class": seat_class_value,
        "seat_No": seat_no_value
      });
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
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
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
                  child : DayPickerPage(
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
  final List<Event> events = [];
}