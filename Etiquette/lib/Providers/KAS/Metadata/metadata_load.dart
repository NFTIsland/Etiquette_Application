import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';

// 메타데이터 읽어오기
Future<Map<String, dynamic>> loadMetadata(String uri) async {
  Dio dio = getBasicDio();
  try {
    final json = await dio.get(uri);
    Map<String, dynamic> data = {
      "statusCode": 200,
      "json": json,
    };
    return data;
  } on DioError catch (e) {
    final handleError = e.response?.data;

    Map<String, dynamic> data = {
      "statusCode": e.response?.statusCode,
      "msg": "",
    };
    if (handleError == null) {
      data["msg"] = "존재하지 않는 메타데이터 uri 입니다.";
    } else {
      data["msg"] = e.response?.data;
    }
    return data;
  } catch (ex) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "msg": ex.toString()
    };
    return data;
  }
}
