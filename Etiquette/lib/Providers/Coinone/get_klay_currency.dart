import 'dart:convert';
import 'package:http/http.dart' as http;

// 실시간 KLAY 시세 정보
Future<Map<String, dynamic>> getKlayCurrency() async {
  try {
    final res = await http.get(Uri.parse("https://api.coinone.co.kr/public/v2/ticker_new/KRW/KLAY"));
    Map<String, dynamic> data = json.decode(res.body);
    if (data["result"] == "success") {
      final lastCurrency = data["tickers"][0]["last"];
      return {
        "statusCode": 200,
        "lastCurrency": lastCurrency
      };
    } else {
      return {
        "statusCode": 400,
        "msg": "KLAY 시세 정보를 불러오는데 실패했습니다."
      };
    }
  } catch (ex) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "msg": ex.toString()
    };
    return data;
  }
}