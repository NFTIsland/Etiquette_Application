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
// 화면이 동적으로 변하는 Stateful Widget으로 생성
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _Login();
}

class _Login extends State<Login> {
  final idController = TextEditingController(); // 아이디를 입력받는 텍스트 폼 컨트롤러
  final pwController = TextEditingController(); // 패스워드를 입력받는 텍스트 폼 컨트롤러

  // 입력받은 ID와 PW가 DB와 일치하는지 확인
  Future<String> attemptLogIn(String id, String pw) async {
    try {
      final res = await http.post(Uri.parse("$SERVER_IP/auth/login"), body: {
        "id": id,
        "pw": pw
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['token'] + ":" + data['nickname']; // token과 닉네임을 "token:nickname" 꼴로 반환
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
    return GestureDetector(// 사용자의 각종 제스쳐 종류 인식하는 위젯
        onTap: () => FocusScope.of(context).unfocus(), // 만약 키보드 밖을 선택하면 키보드 사라지게 설정
        child: Scaffold(
            body: Center(
              // 스크롤 가능하게 설정 -> 만약 한 화면 내에 담기지 않더라도 스크롤 해서 볼 수 있음
                child: SingleChildScrollView(
                    child: Column(
                        children: <Widget> [
                          Padding(
                              padding: const EdgeInsets.only(left: 80),
                              // 가로로 Login, Signup 글씨 배치
                              child: Row(
                                  children: const <Widget> [
                                    Text("Login", style: TextStyle(fontSize: 30)),
                                    Text("/Sign up", style: TextStyle(fontSize: 20, color: Colors.grey),)
                                  ]
                              )
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
                              child: Column(
                                  children: <Widget> [
                                    const SizedBox(height: 30), // Login/Sign up과 공간 확보를 위한 위젯
                                    TextFormField(
                                        maxLines: 1, // 최대 입력받을 수 있는 줄 개수
                                        maxLength: 11, // 최대 입력받을 수 있는 글자 개수
                                        autovalidateMode: AutovalidateMode.onUserInteraction, // 입력한 값이 변화할 때마다 유효성 검사 실행
                                        keyboardType: TextInputType.number, // 기본으로 숫자 모양의 키보드 호출되도록 설정
                                        controller: idController,
                                        decoration: const InputDecoration(
                                          labelText: "HP(ID)",
                                          hintText: "Please Enter Your HP(ID)", // 아무것도 입력하지 않았을 때 나타나는 문구
                                          counterText: "", // maxLength를 지정하면 아래에 현재 입력 수, 최대 입력 수 표시되는 걸 숨김
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "ID is null now"; // 만약 입력된 값이 없거나 Null이면 메시지 출력
                                          }
                                          return null;
                                        }
                                    ),
                                    TextFormField(
                                        maxLines: 1,
                                        maxLength: 20,
                                        autovalidateMode: AutovalidateMode.onUserInteraction, // 입력한 값이 변화할 때마다 유효성 검사 실행
                                        keyboardType: TextInputType.text, // 기본으로 자판 모양의 키보드 호출되도록 설정
                                        obscureText: true, // 비밀번호 안보이도록 설정
                                        controller: pwController,
                                        decoration: const InputDecoration(
                                          labelText: "Password",
                                          hintText: "Please Enter Your Password",
                                          counterText: "", // maxLength를 지정하면 아래에 현재 입력 수, 최대 입력 수 표시되는 걸 숨김
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Password is null now"; // 만약 입력된 값이 없거나 Null이면 메시지 출력
                                          }
                                          return null;
                                        }
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 20), // 비밀번호 입력하는 칸과 공간 확보
                                        child: Column(
                                            children: <Widget>[
                                              // 로그인 버튼
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    var _id = idController.text; // 입력받은 아이디 값을 _id에 저장
                                                    var _pw = pwController.text; // 입력받은 패스워드 값을 _pw에 저장
                                                    var jwt = await attemptLogIn(_id, _pw); // 입력받은 id와 pw로 로그인을 시도한 결과를 jwt 변수에 저장
                                                    if (jwt == "") {// 만약 결과가 없으면 -> 아이디와 패스워드가 일치하지 않아 로그인에 실패했다면
                                                      displayDialog_checkonly(context, "계정 정보 없음", "해당 계정이 존재하지 않습니다.\n다시 확인 후 입력해주십시오.");
                                                    } else if (jwt == "SocketException") { // 서버가 오프라인이거나 통신이 원활하지 않아 에러 생긴 경우 출력할 메세지
                                                      displayDialog_checkonly(context, "에러 발생", "서버와의 통신이 원활하지 않습니다.\n다시 시도해 주십시오.");
                                                    } else if (jwt == "Unknown Error Occurred") { // 이외의 에러 생긴 경우 출력할 메세지
                                                      displayDialog_checkonly(context, "에러 발생", "알 수 없는 에러가 발생했습니다.\n다시 시도해 주십시오.");
                                                    } else { // 로그인에 성공했다면
                                                      var _JWT = jwt.split(':')[0]; // 돌려받은 jwt 내용에서 :를 기준으로 나눈 것 중 첫번째 값 -> jwt 토큰 값
                                                      var _nickname = jwt.split(':')[1]; // 돌려받은 jwt 내용에서 :를 기준으로 나눈 것 중 두번째 값 -> 닉네임 정보
                                                      //내부 안전한 저장소에 로그인 정보 저장
                                                      storage.write(key: "jwt", value: _JWT); // 저장소에 _jwt 값 저장
                                                      storage.write(key: "nickname", value: _nickname); // 저장소에 닉네임 값 저장
                                                      Get.off(Tabb(idx:0)); // 0번 탭 -> Home 화면으로 넘어감
                                                      ScaffoldMessenger.of(context).showSnackBar(// 아래에 환영 메세지 띄움
                                                          SnackBar(content: Text(_nickname + "님 접속을 환영합니다."),)
                                                      );
                                                    }
                                                  },
                                                  child: const Text("로그인"),
                                                  style: ElevatedButton.styleFrom( // 버튼을 둥글게 꾸미고 색 설정
                                                      primary: const Color(0xff7795FF), // primary는 버튼 색 꾸미는 속성
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12)
                                                      ) //둥글게 설정
                                                  )
                                              ),
                                              // 회원가입 버튼
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Get.to(const Register()); // 회원가입 페이지로 넘어감
                                                  },
                                                  child: const Text("회원가입"),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Colors.purpleAccent.shade100, // primary는 버튼 색 꾸미는 속성
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
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 가로로 배치되는 위젯들의 양옆 공간을 모두 균일하게 배치
                                                children: [
                                                  // ID 찾기 버튼
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        displayDialog_checkonly(context, "아이디 찾기", "ID는 회원님의 휴대전화 번호입니다.");
                                                      },
                                                      child: const Text("ID 찾기"),
                                                      style: ElevatedButton.styleFrom(
                                                          primary: Colors.black, // primary는 버튼 색 꾸미는 속성
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12)
                                                          ) // 둥글게 설정
                                                      )
                                                  ),
                                                  // PW 찾기 버튼
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(const FindPW()); // 눌렀을 때 pw를 찾는 페이지로 넘어감
                                                      },
                                                      child: const Text("PW 찾기"),
                                                      style: ElevatedButton.styleFrom( // 버튼 꾸미기
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