import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';
import 'package:Etiquette/Models/serverset.dart';

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

    Map<String, dynamic> data = {
      "statusCode": e.response?.statusCode,
      "msg": handleError['msg'],
    };

    return data;
  } catch (ex) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "msg": ex.toString()
    };
    return data;
  }
}