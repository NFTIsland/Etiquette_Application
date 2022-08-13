import 'package:dio/dio.dart';
import 'package:Etiquette/Models/dio_models.dart';
import 'package:Etiquette/Models/serverset.dart';

// 메타데이터 업로드
Future<Map<String, dynamic>> metadataUpload(Map<String, dynamic> metadata) async {
  Dio dio = getBasicDio();
  const url = "$SERVER_IP/kas/metadata/metadataUpload";
  try {
    final res = await dio.post(url, data: {
      "metadata": metadata,
    });
    Map<String, dynamic> data = res.data;
    return data;
    /*
    {
        statusCode: 200,
        data: {
            contentType: 'application/json',
            filename: 'c628a8b3-9875-1511-b781-ef9617b7e0de.json',
            uri: 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/c628a8b3-9875-1511-b781-ef9617b7e0de.json'
        }
    }
    */
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