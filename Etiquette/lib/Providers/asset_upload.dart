import 'package:dio/dio.dart';
import 'package:Etiquette/Models/config.dart';

Future<Map<String, dynamic>> assetUpload(String filePath) async { // 에셋 업로드
  var dio = Dio();
  dio.options.headers['Content-Type'] = "multipart/form-data";
  dio.options.headers['x-chain-id'] = x_chain_id;
  dio.options.headers['Authorization'] = authorization;
  dio.options.headers['content-type'] = "multipart/form-data; boundary=---011000010111000001101001";

  var formData = FormData.fromMap({
    'file' : await MultipartFile.fromFile(filePath)
  });

  final res = await dio.post('https://metadata-api.klaytnapi.com/v1/metadata/asset', data: formData);
  // {
  //    "contentType":"application/octet-stream",
  //    "filename": "04a9234a-6c3e-3bd3-61f3-b3cdb3b336ba.png",
  //    "uri": "https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/04a9234a-6c3e-3bd3-61f3-b3cdb3b336ba.png"
  // }

  if (res.statusCode == 200) {
    Map<String, dynamic> data = res.data;
    data.addEntries([
      const MapEntry("statusCode", 200)]
    );
    return data;
  } else {
    Map<String, dynamic> data = res.data;
    data.addEntries([
      const MapEntry("statusCode", 400)]
    );
    return data;
  }
}