import 'dart:convert';
import 'package:Etiquette/widgets/AlertDialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';

// PW 찾기 화면
class FindPW extends StatefulWidget {
  const FindPW({Key? key}) : super(key: key);
  @override
  State<FindPW> createState() => _FindPW();
}

class _FindPW extends State<FindPW> {
  final findPWController = TextEditingController(); // PW를 찾기 위한 key인 ID를 입력받는 컨트롤러

  String email = ""; // email 주소를 저장하는 변수

  // 임시 비밀번호를 받을 회원의 email 주소 받아오는 함수
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

  // getEmail 함수를 통해 받은 email 주소로 임시 비밀번호를 생성하여 메일 전송
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
      appBar: AppBar(
        centerTitle: true, // 페이지 제목을 중앙에 배치
        title: const Text("비밀번호 찾기",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white24,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Get.back(); // 이전 화면으로 이동
          },
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Text("본인 확인을 위하여 다시 한번 입력해주세요.",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              // 본인 확인을 위해 id 다시 입력
              padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
              child: TextFormField(
                  maxLines: 1,
                  maxLength: 11,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number, // 기본으로 숫자 모양의 키보드 호출되도록 설정
                  controller: findPWController,
                  decoration: const InputDecoration(
                    labelText: "HP(ID)",
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
            // 확인 버튼
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                  onPressed: () async {
                    var _id = findPWController.text; // 본인 확인용 id를 입력받을 변수
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
            ),
          ],
        ),
      ),
    );
  }
}