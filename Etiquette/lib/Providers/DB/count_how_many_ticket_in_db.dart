import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:Etiquette/Models/url.dart';

Future<int> countHowManyTicketInDB() async {
  var dio = Dio();
  dio.options.connectTimeout = 5000; // 5 seconds
  dio.options.receiveTimeout = 3000;

  var res = await dio.get(dbServerBaseurl + "count_tickets");

  if (res.statusCode == 200) {
    Map<String, dynamic> data = res.data;
    int count = data["count"][0]["count(*)"];
    return count;
  } else {
    return -1;
  }
}