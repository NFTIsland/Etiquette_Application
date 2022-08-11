import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';
import 'package:Etiquette/Models/serverset.dart';

Future<Map<String, dynamic>> checkKasAddress(String address) async {
  String url = "$SERVER_IP/kas/wallet/checkAccount/$address";
  Dio dio = getBasicDio();

  try {
    final res = await dio.get(url);
    Map<String, dynamic> data = res.data;
    return data;
  } on DioError catch (e) {
    final handleError = e.response?.data; // { statusCode: 400, msg: 존재하지 않는 KAS 주소입니다. }
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