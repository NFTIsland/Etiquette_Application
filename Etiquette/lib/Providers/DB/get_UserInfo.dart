import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Utilities/jwt_decode.dart';

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