import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/headers.dart';
import 'package:Etiquette/Providers/DB/count_how_many_ticket_in_db.dart';

Future<Map<String, dynamic>> kip17TokenMinting(String category, String to, String uri) async { // kip17 토큰 발행
  if (category == "영화") {
    category = "movie";
  } else if (category == "콘서트") {
    category = "concert";
  } else if (category == "뮤지컬") {
    category = "musical";
  } else if (category == "공연") {
    category = "performance";
  } else if (category == "스포츠") {
    category = "sports";
  } else {
    Map<String, dynamic> temp = {"statusCode": "error Category"};
    return temp;
  }

  String alias = category; // alias(별칭) 지정
  String url = "https://kip17-api.klaytnapi.com/v2/contract/" + alias + "/token";

  // id 결정
  int count = await countHowManyTicketInDB(); // DB에 있는 티켓의 개수를 셈
  String token_id = "0x" + (count + 1).toString(); // token_id를 0x(DB에 있는 티켓의 개수 + 1)로 설정
  // 예: DB에 있는 티켓의 개수가 100개라면 다음 업로드 되는 티켓의 token_id는 0x101이 된다.

  var res = await http.post(Uri.parse(url), body: jsonEncode ({
    "to": to,
    "id": token_id,
    "uri": uri,
  }), headers: basicAuthHeaders);

  Map<String, dynamic> data = json.decode(res.body);

  if (res.statusCode == 200) { // 토큰 생성 성공
    data.addEntries([
      const MapEntry("statusCode", 200),
      MapEntry("alias", alias),
      MapEntry("token_id", token_id),
    ]);
  } else { // 토큰 생성 실패
    data.addEntries([
      MapEntry("statusCode", res.statusCode)]
    );
  }

  return data;
}