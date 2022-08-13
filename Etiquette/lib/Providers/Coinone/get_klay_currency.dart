import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';

// 실시간 KLAY 시세 정보
Future<Map<String, dynamic>> getKlayCurrency() async {
  Dio dio = getBasicDio();
  try {
    final res = await dio.get("https://api.coinone.co.kr/public/v2/ticker_new/KRW/KLAY");
    Map<String, dynamic> data = res.data;
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
  } on DioError catch (e) {
    final handleError = e.response?.data;
    if (handleError == null) {
      Map<String, dynamic> data = {
        "statusCode": 404,
        "msg": "서버와의 연결이 원활하지 않습니다.",
      };
      return data;
    } else {
      Map<String, dynamic> data = {
        "statusCode": e.response?.statusCode,
        "msg": handleError['msg'],
      };
      return data;
    }
  } catch (ex) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "msg": ex.toString()
    };
    return data;
  }
}