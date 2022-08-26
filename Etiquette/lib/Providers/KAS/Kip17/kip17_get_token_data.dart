import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';

Future<Map<String, dynamic>> kip17GetTokenData(String alias, String token_id) async {
  const url = "$SERVER_IP/kas/kip17/getTokenData";
  try {
    var res = await http.post(Uri.parse(url), body: {
      "alias": alias,
      "token_id": token_id
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