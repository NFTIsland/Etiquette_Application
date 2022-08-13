import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';
import 'package:Etiquette/Models/serverset.dart';

// kip17 토큰 발행
Future<Map<String, dynamic>> kip17TokenMinting(String category, String to, String token_id, String metadata_uri) async {
  Dio dio = getBasicDio();
  String url = "$SERVER_IP/kas/kip17/tokenMinting";
  try {
    final res = await dio.post(url, data: {
      "category": category,
      "to": to,
      "token_id": token_id,
      "metadata_uri": metadata_uri,
    });
    Map<String, dynamic> data = res.data;
    return data;
  } on DioError catch (e) {
    final handleError = e.response?.data;
    if (handleError == null) {
      Map<String, dynamic> data = {
        "statusCode": 400,
        "msg": "서버와의 연결이 원활하지 않습니다.",
      };
      return data;
    } else {
      Map<String, dynamic> data = {
        "statusCode": e.response?.statusCode,
        "msg": handleError["msg"],
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