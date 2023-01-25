import 'dart:convert';
import 'package:Etiquette/widgets/AlertDialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

class FindPW extends StatefulWidget {
  const FindPW({Key? key}) : super(key: key);
  @override
  State<FindPW> createState() => _FindPW();
}

class _FindPW extends State<FindPW> {
  final findPWController = TextEditingController();

  String email = "";

  Future<void> getEmail(String id) async {
    try {
      final res = await http.post(Uri.parse("$SERVER_IP/individual/getEmail"),
          body: {
            "id": id
          });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState((){
          email = data['email'];
        });
      }
    } catch (ex) {
      displayDialog_checkonly(context, "오류 발생", "Email을 불러오는 데에 실패했습니다.\n다시 시도해주십시오.");
    }
  }

  Future<void> SendRandomPW(String id, String email) async {
    try {
      final res = await http.post(Uri.parse("$SERVER_IP/auth/sendRandomPW"), body: {
        "id": id,
        "email": email,
      });
      if (res.statusCode == 200) {
        displayDialog_checkonly(context, "메일 확인 요망", "회원가입 시 입력하신 메일로 임시 비밀번호가 전송되었습니다.\n로그인 후 새 비밀번호로 변경해주십시오.");
      }
    } catch (ex) {
      displayDialog_checkonly(context, "오류 발생", "알 수 없는 오류가 발생하였습니다.\n다시 시도해주십시오.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text("본인 확인을 위하여 다시 한번 입력해주세요.",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                  maxLines: 1,
                  maxLength: 11,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number, // 기본으로 숫자 모양의 키보드 호출되도록 설정
                  controller: findPWController,
                  decoration: const InputDecoration(
                    labelText: "HP(ID)", // 입력칸에 ID 표시되도록
                    hintText: "Please Enter Your HP(ID) Again",
                    counterText: "",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "ID is null now";
                    }
                    return null;
                  }
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  var _id = findPWController.text;
                  await getEmail(_id);
                  await SendRandomPW(_id, email);
                },
                child: const Text("확인"),
                style: ElevatedButton.styleFrom(
                    primary: Colors.purpleAccent.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    ) // 둥글게 설정
                )
            ),
          ],
        ),
      ),
    );
  }
}