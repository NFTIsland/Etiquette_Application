import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';
import 'package:Etiquette/Models/serverset.dart';

// 토큰 전송
Future<Map<String, dynamic>> kip17TokenTransfer(String alias, String token_id, String sender, String owner, String to) async {
  Dio dio = getBasicDio();
  const url = "$SERVER_IP/kas/kip17/tokenTransfer";
  try {
    final res = await dio.post(url, data: {
      "alias": alias,
      "token_id": token_id,
      "sender": sender,
      "owner": owner,
      "to": to,
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