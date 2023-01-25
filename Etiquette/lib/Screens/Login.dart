import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Etiquette/Screens/Register.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/widgets/AlertDialogWidget.dart';
import 'package:Etiquette/Screens/TabController.dart';
import 'package:Etiquette/Screens/Find_PW.dart';

// 로그인 화면
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _Login();
}

class _Login extends State<Login> {
  final idController = TextEditingController();
  final pwController = TextEditingController();

  Future<String> attemptLogIn(String id, String pw) async {
    try {
      final res = await http.post(Uri.parse("$SERVER_IP/auth/login"), body: {
        "id": id,
        "pw": pw
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['token'] + ":" + data['nickname'];
      }
      return "";
    } catch (e) {
      if (e is SocketException) { // 서버가 오프라인 상태인 경우
        return "SocketException";
      } else {
        return "Unknown Error Occurred";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 만약 화면 영역 밖을 선택하면 키보드 사라지게 설정
        child: Scaffold(
            body: Center(
                child: SingleChildScrollView( // 스크롤 가능하게 설정 -> 만약 한 화면 내에 안담기더라도 스크롤 해서 볼 수 있음
                    child: Column(
                        children: <Widget> [
                          Padding(
                              padding: const EdgeInsets.only(left: 80), // 좌측 공간 확보
                              child: Row( // 가로로 Login, Signup 배치
                                  children: const <Widget> [
                                    Text("Login", style: TextStyle(fontSize: 30)),
                                    Text("/Sign up", style: TextStyle(fontSize: 20, color: Colors.grey),)
                                  ]
                              ) //사이즈, 컬러 설정 및 텍스트 입력
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(80, 0, 80, 0), // 좌우 여백 확보.
                              child: Column( // 텍스트 필드, 버튼 세로로 배치
                                  children: <Widget> [
                                    const SizedBox(height: 30), // Login/Sign up과 공간 확보를 위한 위젯
                                    TextFormField(
                                        maxLines: 1,
                                        maxLength: 11,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        keyboardType: TextInputType.number, // 기본으로 숫자 모양의 키보드 호출되도록 설정
                                        controller: idController,
                                        decoration: const InputDecoration(
                                          labelText: "HP(ID)", // 입력칸에 ID 표시되도록
                                          hintText: "Please Enter Your HP(ID)",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "ID is null now";
                                          }
                                          return null;
                                        }
                                    ),
                                    TextFormField(
                                        maxLines: 1,
                                        maxLength: 20,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        keyboardType: TextInputType.text, // 기본으로 자판 모양의 키보드 호출되도록 설정
                                        obscureText: true, // 비밀번호 안보이도록 설정
                                        controller: pwController,
                                        decoration: const InputDecoration(
                                          labelText: "Password", // 입력칸에 PW 표시되도록
                                          hintText: "Please Enter Your Password",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Password is null now";
                                          }
                                          return null;
                                        }
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 20), // 비밀번호 입력하는 칸과 공간 확보
                                        child: Column( // 로그인, 회원가입 버튼 세로로 배치
                                            children: <Widget>[ // 로그인 버튼
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    var _id = idController.text;
                                                    var _pw = pwController.text;
                                                    var jwt = await attemptLogIn(_id, _pw);
                                                    if (jwt == "") {
                                                      displayDialog_checkonly(context, "계정 정보 없음", "해당 계정이 존재하지 않습니다.\n다시 확인 후 입력해주십시오.");
                                                    } else if (jwt == "SocketException") {
                                                      displayDialog_checkonly(context, "에러 발생", "서버와의 통신이 원활하지 않습니다.\n다시 시도해 주십시오.");
                                                    } else if (jwt == "Unknown Error Occurred") {
                                                      displayDialog_checkonly(context, "에러 발생", "알 수 없는 에러가 발생했습니다.\n다시 시도해 주십시오.");
                                                    } else {
                                                      var _JWT = jwt.split(':')[0];
                                                      var _nickname = jwt.split(':')[1];
                                                      storage.write(key: "jwt", value: _JWT);
                                                      storage.write(key: "nickname", value: _nickname);
                                                      Get.off(Tabb(idx:0));
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text(_nickname + "님 접속을 환영합니다."),)
                                                      );
                                                    }
                                                  },
                                                  child: const Text("로그인"),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: const Color(0xff7795FF),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12)
                                                      ) //둥글게 설정
                                                  )
                                              ),
                                              // 회원가입 버튼
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Get.to(const Register());
                                                  },
                                                  child: const Text("회원가입"), // 회원가입 버튼
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Colors.purpleAccent.shade100,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12)
                                                      ) // 둥글게 설정
                                                  )
                                              ),

                                              const Padding(
                                                padding: EdgeInsets.only(top: 50),
                                                child: Text("만약 기억나지 않는다면",
                                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),

                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        displayDialog_checkonly(context, "아이디 찾기", "ID는 회원님의 휴대전화 번호입니다.");
                                                      },
                                                      child: const Text("ID 찾기"),
                                                      style: ElevatedButton.styleFrom(
                                                          primary: Colors.black,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12)
                                                          ) // 둥글게 설정
                                                      )
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(const FindPW());
                                                      },
                                                      child: const Text("PW 찾기"),
                                                      style: ElevatedButton.styleFrom(
                                                          primary: Colors.black,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12)
                                                          ) // 둥글게 설정
                                                      )
                                                  )
                                                ],
                                              ),
                                            ]
                                        )
                                    ),
                                  ]
                              )
                          )
                        ]
                    )
                )
            )
        )
    );
  }
}