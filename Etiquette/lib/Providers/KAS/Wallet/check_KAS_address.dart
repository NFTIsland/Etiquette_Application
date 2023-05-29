import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

Future<Map<String, dynamic>> checkKasAddress(String address) async {
  String url = "$SERVER_IP/kas/wallet/checkAccount/$address";
  try {
    final res = await http.get(Uri.parse(url));
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