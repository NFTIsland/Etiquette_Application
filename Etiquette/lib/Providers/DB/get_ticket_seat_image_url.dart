import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

Future<Map<String, dynamic>> getTicketSeatImageUrl(String product_name, String place) async {
  try {
    const url = "$SERVER_IP/ticket/ticketSeatImageUrl";
    final res = await http.post(Uri.parse(url), body: {
      "product_name": product_name,
      "place": place
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