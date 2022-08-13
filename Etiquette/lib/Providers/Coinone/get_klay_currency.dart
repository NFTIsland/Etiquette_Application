import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';

// 실시간 KLAY 시세 정보
Future<Map<String, dynamic>> getKlayCurrency() async {
  Dio dio = getBasicDio();
  try {
    final res = await dio.get("https://api.coinone.co.kr/public/v2/ticker_new/KRW/KLAY");
    Map<String, dynamic> data = res.data;
    if (res.statusCode == 200) {
      var lastCurrency = data["tickers"][0]["last"];
      data.addEntries([
        MapEntry("statusCode", res.statusCode),
        MapEntry("lastCurrency", lastCurrency),
      ]);
    } else {
      data.addEntries([
        MapEntry("statusCode", res.statusCode),
      ]);
    }
    return data;
  } on DioError catch (e) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "message": e.message
    };
    return data;
  } catch (ex) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "message": ex.toString()
    };
    return data;
  }
}