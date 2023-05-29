import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

// KLAY 트랜젝션 수행
Future<Map<String, dynamic>> klayTransaction(String from, String value, String to) async {
  try {
    const url = "$SERVER_IP/kas/wallet/klayTransaction";
    final res = await http.post(Uri.parse(url), body: {
      "from": from,
      "value": value,
      "to": to,
    }); // 트랜젝션 수행 시 송신자에게 0.00525 KLAY의 수수료 발생
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