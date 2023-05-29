import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/utils.dart';
import 'package:Etiquette/widgets/event.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/widgets/time_picker_page.dart';

/// Page with [dp.DayPicker].
class DayPickerPage extends StatefulWidget {
  /// Custom events.
  final List<Event> events;
  String? product_name;
  String? place;
  String? category;
  ///
  DayPickerPage({
    Key? key,
    this.events = const [],
    required this.product_name,
    required this.place,
    required this.category
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  DateTime _selectedDate = DateTime.now().subtract(Duration(days: 1));
  List notday = [];//되는 날짜 받기
  final DateTime _firstDate = DateTime.now();
  DateTime? _lastDate;//마지막으로 되는 날짜가 언제까지인지. DateTime.now()가 아니라 DateTime형식으로 직접 날짜 지정해줘도 됨.

  Color selectedDateStyleColor = Colors.blue;
  Color selectedSingleDateDecorationColor = Color(0xffFD6059);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    selectedDateStyleColor = Theme.of(context).colorScheme.onSecondary;
    //selectedSingleDateDecorationColor = Theme.of(context).colorScheme.secondary;
  }

  late Future myFuture;
  @override
  Widget build(BuildContext context) {
    // add selected colors to default settings
    dp.DatePickerRangeStyles styles = dp.DatePickerRangeStyles(
      selectedDateStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
        color: selectedDateStyleColor,
      ),
      selectedSingleDateDecoration: BoxDecoration(
        color: selectedSingleDateDecorationColor,
        shape: BoxShape.circle,
      ),
      dayHeaderStyle: const DayHeaderStyle(
        textStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      dayHeaderTitleBuilder: _dayHeaderTitleBuilder,
    );

    return FutureBuilder(
      future : myFuture,
      builder: (context, snapshot){
        if (snapshot.hasError) {
          return const Text("통신 에러가 발생했습니다.");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Flex(
            mainAxisSize: MainAxisSize.max,
            direction: MediaQuery.of(context).orientation == Orientation.portrait
                ? Axis.vertical
                : Axis.horizontal,
            children: <Widget>[
              Container(
                //decoration: BoxDecoration(border: Border(bottom : BorderSide(width: 1, color: Color(0xffC4C4C4))),),
                height : MediaQuery.of(context).size.height/2 - MediaQuery.of(context).size.height*0.02,
                width: MediaQuery.of(context).size.width,
                child: dp.DayPicker.single(
                  selectedDate: _selectedDate,
                  onChanged: _onSelectedDateChanged,//누르면 실행되는 함수
                  firstDate: _firstDate,
                  lastDate: _lastDate!,
                  datePickerStyles: styles,
                  datePickerLayoutSettings: const dp.DatePickerLayoutSettings(
                    maxDayPickerRowCount: 6,
                    showPrevMonthEnd: false,
                    showNextMonthStart: false,
                  ),
                  selectableDayPredicate: _isSelectableCustom,
                  eventDecorationBuilder: _eventDecorationBuilder,
                ),
              ),
              Expanded(
                  child : flag == 0 ?
                  const Center(
                    child : Text(
                      "날짜를 선택해 주세요.",
                    ),
                  ) : flag == 1 ?
                  const Text("티켓을 불러오고 있습니다!") :
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _totalinfo.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                //height : 200,
                                width: MediaQuery.of(context).size.width,
                                  child : Column(
                                      children : <Widget>[
                                        Container(height : MediaQuery.of(context).size.height*0.01,decoration: BoxDecoration(
                                            border: const Border(
                                                top: BorderSide(
                                                    width : 1,
                                                    color: Color(0xffC4C4C4)
                                                )
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26.withOpacity(0.1),
                                                spreadRadius: 0,
                                                blurRadius: 0,
                                                offset: const Offset(0, 0), // changes position of shadow
                                              ),
                                            ]),
                                        ),
                                        Container(
                                          padding : const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                          color : Colors.white,
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children : <Widget>[
                                                Text(
                                                  "${_performanceTime[index]}",
                                                  style: const TextStyle(
                                                    color: Color(0xffF6635B),
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => TimePickerPage(
                                                          category: widget.category!,
                                                          place: widget.place!,
                                                          date:_selectedDate.toString().substring(0,10)/*날:일:월*/,
                                                          product_name: widget.product_name!,
                                                          time: _totalinfo[index][0],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    primary: const Color(0xffFD6059),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(40),
                                                    ),
                                                    minimumSize: const Size(90, 32),
                                                  ),
                                                  child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children : const <Widget> [
                                                        Text(
                                                          "선택",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.keyboard_arrow_right_outlined,
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ]
                                          ),
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                width: 0.5 ,
                                                color: Colors.red,
                                              ),
                                            ),
                                            color: Color(0xffF2f2f2),
                                          ),
                                          margin : const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                          padding : const EdgeInsets.fromLTRB(0, 10, 0, 5),
                                          child : GridView.builder(
                                            shrinkWrap: true,
                                            itemCount : _totalinfo[index][1].length,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2, // 1 개의 행에 보여줄 item 개수
                                            childAspectRatio: 6 / 1, // item 의 가로 1, 세로 2 의 비율
                                            mainAxisSpacing: 15, // 수평 Padding
                                            crossAxisSpacing: 5, // 수직 Padding
                                          ), itemBuilder: (BuildContext context, int idx) {
                                            return Container(
                                              height: 50,
                                              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    width : 1,
                                                    color: Color(0xffDADADA),
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget> [
                                                  Text(
                                                    "${_totalinfo[index][1][idx][0]} 석",
                                                    style: const TextStyle(
                                                      color: Color(0xff595959),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${_totalinfo[index][1][idx][1]} 석",
                                                    style: const TextStyle(
                                                      color: Color(0xffEE7E7B),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ]
                                  )
                              );
                            }
                        ),
                      ],
                    ),
                  )
              )
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );


  }
  List _totalinfo = new List.empty(growable: true);
  List _timeseatClass = new List.empty(growable: true);
  List _seatClass = new List.empty(growable: true);
  List _seatNo = new List.empty(growable: true);

  Future<void> load_seat_class(String date_value, String time_value) async {

    final url = "$SERVER_IP/ticket/ticketSeatClass/${widget.product_name!}/${widget.place!}/${date_value}/${time_value}";
    try {
      _seatClass = new List.empty(growable: true);
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        _seatClass = data["data"];
        Set set_seatClass = {};
        for (Map<String, dynamic> item in _seatClass) {
          set_seatClass.add(item["seat_class"]);
          await load_seat_no(date_value, time_value, item["seat_class"]);
        }
      } else {
        _seatClass = [];
      }
    } catch (ex) {
      print("좌석 등급 선택 --> ${ex.toString()}");
    }
  }

  Future<void> load_seat_no(String date_value, String time_value, String seat_class_value) async {
      final url = "$SERVER_IP/ticket/ticketSeatNo/${widget.product_name!}/${widget.place!}/${date_value}/${time_value}/${seat_class_value}";
      try {
        _seatNo = new List.empty(growable: true);
        var res = await http.get(Uri.parse(url));
        Map<String, dynamic> data = json.decode(res.body);
        if (res.statusCode == 200) {
          _seatNo = data["data"];
          _timeseatClass.add([seat_class_value, _seatNo.length]);
        } else {
          _seatNo = [];
        }
      } catch (ex) {
        print("좌석 번호 선택 --> ${ex.toString()}");
      }
  }

  int flag = 0;//0이면 선택해주세요, 1이면 기다려주세요 2면 출력
  List _performanceTime = new List.empty(growable: true);

  Future<void> load_performance_time(String date_value) async {
    final url = "$SERVER_IP/ticket/ticketPerformanceTime/${widget.product_name!}/${widget.place!}/${date_value}";
    try {
      flag = 1;
      _performanceTime = new List.empty(growable: true);
      _totalinfo = new List.empty(growable: true);
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        _performanceTime = data["data"];
        Set set_performanceTime = {};
        int idx = 0;
        for (Map<String, dynamic> item in _performanceTime) {
          _timeseatClass = new List.empty(growable: true);
          set_performanceTime.add(item["time"]);
          await load_seat_class(date_value.substring(0,10), item["time"]);
          _totalinfo.add([item["time"], _timeseatClass]);

        }
        List list_performanceTime = set_performanceTime.toList();
        _performanceTime = new List.empty(growable: true);
        for (String item in list_performanceTime) {
          int hour = int.parse(item.substring(0, 2));
          _performanceTime.add(hour >= 12 ? (hour == 12 ? "오후 ${item.substring(0, 5)}" : "오후 ${hour-12}${item.substring(2,5)}") : "오전 ${item.substring(0, 5)}");
        }

        flag = 2 ;
      } else {
        _performanceTime = [];
      }
    } catch (ex) {
      print("예매 일자 선택 --> ${ex.toString()}");
    }
  }

  List _performanceDate = new List.empty(growable: true);
  List _compareDate = new List.empty(growable: true);
  int max_year = 0;
  int max_month = 0;
  int max_day = 0;
  DateTime _max = DateTime.utc(0,0,0,0);
  void initState(){
    myFuture = init_PerformanceDate();

  }
  Future<void> init_PerformanceDate() async {
    final url = "$SERVER_IP/ticket/ticketPerformanceDate/${widget.product_name!}/${widget.place!}";
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
          _compareDate.add(DateTime.utc(int.parse(item.substring(0,4)), int.parse(item.substring(5,7)), int.parse(item.substring(8,10))));
          if(_max.year <= int.parse(item.substring(0,4)))
          {
            if(_max.year == int.parse(item.substring(0,4)) && _max.month <= int.parse(item.substring(5,7))) {
              if(_max.month == int.parse(item.substring(5,7)) && _max.day < int.parse(item.substring(8,10))){
                max_day = int.parse(item.substring(8,10));
                _max = DateTime.utc(int.parse(item.substring(0,4)), int.parse(item.substring(5,7)), int.parse(item.substring(8,10)));
              }
              else if(_max.month < int.parse(item.substring(5,7))){
                max_month = int.parse(item.substring(5,7));
                max_day = int.parse(item.substring(8,10));
                _max = DateTime.utc(int.parse(item.substring(0,4)), int.parse(item.substring(5,7)), int.parse(item.substring(8,10)));
              }

            }
            else if( _max.year < int.parse(item.substring(0,4))){
              _max = DateTime.utc(int.parse(item.substring(0,4)), int.parse(item.substring(5,7)), int.parse(item.substring(8,10)));
              max_year = int.parse(item.substring(0,4));
              max_month = int.parse(item.substring(5,7));
              max_day = int.parse(item.substring(8,10));
            }
          }

        }
        _lastDate = _max;
      } else {
        _compareDate = [];
      }
    } catch (ex) {
      print("티켓 선택 --> ${ex.toString()}");
    }
  }


  void _onSelectedDateChanged(DateTime newDate) {
    String date = newDate.toString();
    load_performance_time(date);
    setState(() {
      _selectedDate = newDate;
    });
  }

  // ignore: prefer_expression_function_bodies
  bool _isSelectableCustom(DateTime day) {
    for(var item in _compareDate){
      if((DatePickerUtils.sameDate(day, item))){
        return true;
      }
    }
    return false;
    //return !DatePickerUtils.sameDate(day, DateTime.now());//현재 날짜 안되게 설정

    //return day.weekday < 6; // 조건문 참이면 되는날짜 아니면 안되는 날짜 -> 리스트에 없는 day.week, day.day 를 되는날만 받아온 리스트의 week,day랑 비교해서 같을 떄만 true되도록 코드 설정해야 함, 현재는 주말이 disable되도록 설정
  }

  dp.EventDecoration? _eventDecorationBuilder(DateTime date) {
    List<DateTime> eventsDates =
    widget.events.map<DateTime>((e) => e.date).toList();

    bool isEventDate = eventsDates.any((d) =>
    date.year == d.year && date.month == d.month && d.day == date.day);

    BoxDecoration roundedBorder = BoxDecoration(

        border: Border.all(
          color: Colors.deepOrange
        ),
        borderRadius: BorderRadius.all(Radius.circular(3.0)));

    return isEventDate
        ? dp.EventDecoration(boxDecoration: roundedBorder,)
        : null;
  }
}

String _dayHeaderTitleBuilder(
    int dayOfTheWeek, List<String> localizedHeaders) =>
    localizedHeaders[dayOfTheWeek].substring(0, 1);

