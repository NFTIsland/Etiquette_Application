import 'package:dio/dio.dart';
import 'package:Etiquette/Models/Settings.dart';

// KAS 계정 생성
Future<Map<String, dynamic>> createKasAccount() async {
  const url = "$SERVER_IP/kas/wallet/createAccount";
  Dio dio = getBasicDio();

  try {
    final res = await dio.post(url);
    Map<String, dynamic> data = res.data;
    return data;
  } on DioError catch (e) {
    final handleError = e.response?.data;
    // 네트워크 오류
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