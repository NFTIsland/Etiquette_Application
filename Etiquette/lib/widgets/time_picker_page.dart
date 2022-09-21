import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/utils.dart';
import 'package:Etiquette/widgets/event.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:Etiquette/Models/serverset.dart';


class TimePickerPage extends StatefulWidget{
  String? product_name;
  String? place;
  String? category;
  String? date;
  String? time;
  TimePickerPage({
    Key? key,
    required this.product_name,
    required this.place,
    required this.date,
    required this.time,
    this.category
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TimePickerPage();
}

class _TimePickerPage extends State<TimePickerPage>{

  Widget build(context){
    return Text("넘어감 완료!");
  }
}