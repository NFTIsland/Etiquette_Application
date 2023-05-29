import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

Future<Map<String, dynamic>> loadTicketTokenIdAndOwner(String product_name, String place, String date_value, String time_value, String seat_class_value, String seat_no_value) async {
  const url = "$SERVER_IP/ticket/ticketTokenIdAndOwner";
  try {
    var res = await http.post(Uri.parse(url), body: {
      "product_name": product_name,
      "place": place,
      "date": date_value,
      "time": time_value,
      "seat_class": seat_class_value,
      "seat_No": seat_no_value
    });
    Map<String, dynamic> data = json.decode(res.body);
    if (res.statusCode == 200) {
      return {
        "token_id": data['data'][0]['token_id'],
        "owner": data['data'][0]['owner']
      };
    } else {
      return {
        "token_id": "",
        "owner": "",
      };
    }
  } catch (ex) {
    print("티켓 소유자 가져오기 --> ${ex.toString()}");
    return {
      "token_id": "",
      "owner": "",
    };
  }
}