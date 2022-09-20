import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';

Future<Map<String, dynamic>> getTransactionHistory(String kas_address, int size) async {
  // final url = 'https://th-api.klaytnapi.com/v2/transfer/account/$kas_address?kind=klay,nft&size=$size&exclude-zero-klay=true';
  const url = "$SERVER_IP/kas/wallet/transactionHistory";
  try {
    final res = await http.post(Uri.parse(url), body: {
      "address": kas_address,
      "size": size.toString(),
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