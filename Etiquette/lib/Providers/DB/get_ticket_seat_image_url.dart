import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

Future<Map<String, dynamic>> getTicketSeatImageUrl(String product_name, String place) async {
  try {
    final url = "$SERVER_IP/ticket/ticketSeatImageUrl/$product_name/$place";
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