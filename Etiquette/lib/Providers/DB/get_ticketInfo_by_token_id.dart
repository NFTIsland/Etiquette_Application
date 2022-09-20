import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';

Future<Map<String, dynamic>> getTicketInfoByTokenId(String token_id) async {
  try {
    final url = "$SERVER_IP/ticket/ticketInfoByTokenId/${token_id}";
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