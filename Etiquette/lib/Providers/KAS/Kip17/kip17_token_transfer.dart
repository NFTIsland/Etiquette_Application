import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

// 토큰 전송
Future<Map<String, dynamic>> kip17TokenTransfer(String alias, String token_id, String sender, String owner, String to) async {
  const url = "$SERVER_IP/kas/kip17/tokenTransfer";
  try {
    final res = await http.post(Uri.parse(url), body: {
      "alias": alias,
      "token_id": token_id,
      "sender": sender,
      "owner": owner,
      "to": to,
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