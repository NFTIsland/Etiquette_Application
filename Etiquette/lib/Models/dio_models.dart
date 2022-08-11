import 'package:dio/dio.dart';
Dio getBasicDio() {
  var dio = Dio();
  dio.options.connectTimeout = 5000; // 5 seconds
  dio.options.receiveTimeout = 3000; // 3 seconds
  return dio;
}