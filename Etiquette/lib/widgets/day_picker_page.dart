import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/utils.dart';
import 'package:Etiquette/widgets/event.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
/// Page with [dp.DayPicker].
class DayPickerPage extends StatefulWidget {
  /// Custom events.
  final List<Event> events;

  ///
  const DayPickerPage({
    Key? key,
    this.events = const [],
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  DateTime _selectedDate = DateTime.now();
  List notday = [];//되는 날짜 받기
  final DateTime _firstDate = DateTime.now();
  final DateTime _lastDate = DateTime.now().add(Duration(days: 45));//마지막으로 되는 날짜가 언제까지인지. DateTime.now()가 아니라 DateTime형식으로 직접 날짜 지정해줘도 됨.

  Color selectedDateStyleColor = Colors.blue;
  Color selectedSingleDateDecorationColor = Color(0xffFD6059);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    selectedDateStyleColor = Theme.of(context).colorScheme.onSecondary;
    //selectedSingleDateDecorationColor = Theme.of(context).colorScheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    // add selected colors to default settings
    dp.DatePickerRangeStyles styles = dp.DatePickerRangeStyles(
      selectedDateStyle: Theme.of(context)
          .textTheme
          .bodyText1
          ?.copyWith(color: selectedDateStyleColor),
      selectedSingleDateDecoration: BoxDecoration(
        color: selectedSingleDateDecorationColor,
        shape: BoxShape.circle,
      ),

      dayHeaderStyle: DayHeaderStyle(
        textStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      dayHeaderTitleBuilder: _dayHeaderTitleBuilder,
    );

    return Flex(
      mainAxisSize: MainAxisSize.max,
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: dp.DayPicker.single(
            selectedDate: _selectedDate,
            onChanged: _onSelectedDateChanged,//누르면 실행되는 함수
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
            datePickerLayoutSettings: dp.DatePickerLayoutSettings(

              maxDayPickerRowCount: 6,
              showPrevMonthEnd: false,
              showNextMonthStart: false,
            ),
            selectableDayPredicate: _isSelectableCustom,
            eventDecorationBuilder: _eventDecorationBuilder,
          ),
        ),


      ],
    );
  }


  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  // ignore: prefer_expression_function_bodies
  bool _isSelectableCustom(DateTime day) {
    return !DatePickerUtils.sameDate(day, DateTime.now());//현재 날짜 안되게 설정

    return day.weekday < 6; // 조건문 참이면 되는날짜 아니면 안되는 날짜 -> 리스트에 없는 day.week, day.day 를 되는날만 받아온 리스트의 week,day랑 비교해서 같을 떄만 true되도록 코드 설정해야 함, 현재는 주말이 disable되도록 설정
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