import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Utilities/jwt_decode.dart';

// 개인의 Kas 주소를 불러오는 함수
Future<Map<String, dynamic>> getKasAddress() async {
  try {
    String id = await jwtDecode();
    const url = "$SERVER_IP/auth/kas_address";
    final res = await http.post(Uri.parse(url), body: {
      "id": id,
    });
    Map<String, dynamic> data = json.decode(res.body);
    return data;
  } catch (ex) {
    Map<String, dynamic> data = {
      "statusCode": 400,
      "msg": ex.toString()
    };
    return data;
  }
}