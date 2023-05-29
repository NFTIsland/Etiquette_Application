import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

// KAS 계정 생성
Future<Map<String, dynamic>> createKasAccount() async {
  const url = "$SERVER_IP/kas/wallet/createAccount";
  try {
    final res = await http.post(Uri.parse(url));
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