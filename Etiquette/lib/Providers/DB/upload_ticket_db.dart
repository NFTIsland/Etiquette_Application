import 'package:dio/dio.dart';
import 'package:Etiquette/Models/url.dart';

Future<void> uploadTicketDB(Map<String, dynamic> ticketInfo) async { // DB에 티켓 업로드
  var dio = Dio();
  dio.options.connectTimeout = 5000; // 5 seconds
  dio.options.receiveTimeout = 3000;

  var res = await dio.post(dbServerBaseurl + "upload_ticket", data: {
    "alias": ticketInfo["alias"],
    "token_id": ticketInfo["token_id"],
    "owner_address": ticketInfo["owner_address"],
    "ticket_name": ticketInfo["ticket_name"],
    "type": ticketInfo["type"],
    "price": ticketInfo["price"],
    "tel": ticketInfo["tel"],
    "start_date": ticketInfo["start_date"],
    "end_date": ticketInfo["end_date"],
    "token_uri": ticketInfo["token_uri"],
    "other_info": ticketInfo["other_info"],
  });

  var data = res.data;
  print(data["msg"]);

  /*
  if (res.statusCode == 200) {
    var data = res.data;
    if (data["result"]) {
      print(data["msg"]);
    } else {
      print(data["msg"]);
    }
  } else {
    var data = res.data;
    print(data["msg"]);
  }
  */
}