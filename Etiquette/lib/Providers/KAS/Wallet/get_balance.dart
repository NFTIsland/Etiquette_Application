import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

// 잔액 조회
Future<Map<String, dynamic>> getBalance(String address) async {
  try {
    const url = "$SERVER_IP/kas/wallet/getBalance";
    final res = await http.post(Uri.parse(url), body: {
      "address": address,
    });
    Map<String, dynamic> data = json.decode(res.body);
    return data;
  } catch (ex) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "msg": ex.toString()
    };
    return data;
  }
}