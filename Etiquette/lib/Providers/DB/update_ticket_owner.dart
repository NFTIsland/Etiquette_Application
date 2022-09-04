import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';

Future<Map<String, dynamic>> updateTicketOwner(String owner, String token_id) async {
  try {
    const url = "$SERVER_IP/ticket/updateTicketOwner";
    final res = await http.post(Uri.parse(url), body: {
      "owner": owner,
      "token_id": token_id,
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