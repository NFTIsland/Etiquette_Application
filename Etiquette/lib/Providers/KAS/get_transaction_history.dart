import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

Future<Map<String, dynamic>> getTransactionHistory(String kas_address, String type, String period) async {
  const url = "$SERVER_IP/kas/wallet/transactionHistory";
  try {
    final res = await http.post(Uri.parse(url), body: {
      "address": kas_address,
      "type": type,
      "period": period,
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