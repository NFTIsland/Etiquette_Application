import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';
import 'package:Etiquette/Models/serverset.dart';

// KLAY 트랜젝션 수행
Future<Map<String, dynamic>> klayTransaction(String from, String value, String to) async {
  Dio dio = getBasicDio();

  try {
    final res = await dio.post("$SERVER_IP/kas/wallet/klayTransaction", data: {
      "from": from,
      "value": value,
      "to": to,
    }); // 트랜젝션 수행 시 송신자에게 0.00525 KLAY의 수수료 발생
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