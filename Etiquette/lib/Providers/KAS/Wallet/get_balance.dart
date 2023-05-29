import 'package:dio/dio.dart';
import 'package:Etiquette/Models/Settings.dart';

// 잔액 조회
Future<Map<String, dynamic>> getBalance(String address) async {
  Dio dio = getBasicDio();

  try {
    final res = await dio.post("$SERVER_IP/kas/wallet/getBalance", data: {
      "address": address,
    });
    Map<String, dynamic> data = res.data;
    return data;
  } on DioError catch (e) {
    final handleError = e.response?.data; // {statusCode: 400, msg: 주소가 잘못되었습니다.}
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