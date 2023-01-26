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
class Login extends StatefulWidget {//화면이 동적으로 변하므로 Stateful Widget으로 생성
  const Login({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _Login();
}

class _Login extends State<Login> {
  final idController = TextEditingController();//아이디를 받는 텍스트 폼 필드에 입력된 값을 관리할 컨트롤러
  final pwController = TextEditingController();//패스워드를 받는 텍스트 폼 필드에 입력된 값을 관리할 컨트롤러

  Future<String> attemptLogIn(String id, String pw) async {
    try {
      final res = await http.post(Uri.parse("$SERVER_IP/auth/login"), body: {
        "id": id,
        "pw": pw
      }); //입력된 아이디와 패스워드로 접속 요청
      if (res.statusCode == 200) { //로그인이 됐으면
        final data = jsonDecode(res.body);
        return data['token'] + ":" + data['nickname']; // token과 닉네임을 "token:nickname" 꼴로 반환
      }
      return "";//로그인 실패
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
    return GestureDetector(//사용자의 각종 제스쳐 종류 인식하는 위젯
        onTap: () => FocusScope.of(context).unfocus(), // 만약 키보드 밖을 선택하면 키보드 사라지게 설정
        child: Scaffold(
            body: Center(
                child: SingleChildScrollView( // 스크롤 가능하게 설정 -> 만약 한 화면 내에 안담기더라도 스크롤 해서 볼 수 있음
                    child: Column(//세로로 위젯을 배치
                        children: <Widget> [
                          Padding(
                              padding: const EdgeInsets.only(left: 80), // 좌측 공간 확보
                              child: Row( // 가로로 Login, Signup 글씨 배치
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
                                    TextFormField(//값 입력받는 위젯
                                        maxLines: 1,//최대 입력 받을 수 있는 줄 개수 -> 최대 1줄만 받을 수 있음
                                        maxLength: 11,//최대 입력 받을 수 있는 글자 개수 -> 최대 11글자까지 받을 수 있음
                                        autovalidateMode: AutovalidateMode.onUserInteraction,//입력한 값이 변화할 때마다 유효성 검사 실행
                                        keyboardType: TextInputType.number, // 기본으로 숫자 모양의 키보드 호출되도록 설정
                                        controller: idController,//아이디를 입력하는 텍스트 폼 필드에 입력된 값을 관리할 컨트롤러
                                        decoration: const InputDecoration(
                                          labelText: "HP(ID)", // ID를 입력하는 공간임을 표시
                                          hintText: "Please Enter Your HP(ID)",//아무것도 입력하지 않았을 때 나타나는 문구
                                          counterText: "",//maxLength를 지정하면 아래에 현재 입력 수 , 최대 입력 수 표시되는 걸 숨김
                                        ),
                                        validator: (value) {//유효성 검사
                                          if (value == null || value.isEmpty) {//만약 안에 입력 된 값이 없거나 Null이면 Null이라는 메세치 출력
                                            return "ID is null now";
                                          }
                                          return null;//정상적으로 입력됐을 땐 출력 문구 없음
                                        }
                                    ),
                                    TextFormField(//값 입력받는 위젯
                                        maxLines: 1,
                                        maxLength: 20,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,//입력한 값이 변화할 때마다 유효성 검사 실행
                                        keyboardType: TextInputType.text, // 기본으로 자판 모양의 키보드 호출되도록 설정
                                        obscureText: true, // 비밀번호 안보이도록 설정
                                        controller: pwController,//패스워드를 입력하는 텍스트 폼 필드에 입력된 값을 관리할 컨트롤러
                                        decoration: const InputDecoration(
                                          labelText: "Password", // 패스워드를 입력하는 공간임을 표시
                                          hintText: "Please Enter Your Password",//아무것도 입력하지 않았을 때 나타나는 문구
                                          counterText: "",//maxLength를 지정하면 아래에 현재 입력 수 , 최대 입력 수 표시되는 걸 숨김
                                        ),
                                        validator: (value) {//유효성 검사
                                          if (value == null || value.isEmpty) {//만약 안에 입력 된 값이 없거나 Null이면 Null이라는 메세치 출력
                                            return "Password is null now";
                                          }
                                          return null;//정상적으로 입력됐을 땐 출력 문구 없음
                                        }
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 20), // 비밀번호 입력하는 칸과 공간 확보
                                        child: Column( // 로그인, 회원가입 버튼 세로로 배치
                                            children: <Widget>[ // 로그인 버튼
                                              ElevatedButton(//버튼 위젯
                                                  onPressed: () async {//로그인 버튼을 눌렀을 때 동작하는 코드
                                                    var _id = idController.text; //입력받은 아이디 값을 _id에 저장
                                                    var _pw = pwController.text; //입력받은 패스워드 값을 _pw에 저장
                                                    var jwt = await attemptLogIn(_id, _pw); // 입력받은 id와 pw로 로그인을 시도한 결과를 jwt 변수에 반환
                                                    if (jwt == "") {// 만약 결과가 없으면 -> 아이디와 패스워드가 일치하지 않아 로그인에 실패했다면
                                                      displayDialog_checkonly(context, "계정 정보 없음", "해당 계정이 존재하지 않습니다.\n다시 확인 후 입력해주십시오."); // 실패 메세지 출력
                                                    } else if (jwt == "SocketException") { // 서버가 오프라인이거나 통신이 원활하지 않아 에러 생긴 경우 출력할 메세지
                                                      displayDialog_checkonly(context, "에러 발생", "서버와의 통신이 원활하지 않습니다.\n다시 시도해 주십시오."); // 알림용 팝업 메세지 출력하는 위젯
                                                    } else if (jwt == "Unknown Error Occurred") { // 이외의 에러 생긴 경우 출력할 메세지
                                                      displayDialog_checkonly(context, "에러 발생", "알 수 없는 에러가 발생했습니다.\n다시 시도해 주십시오."); // 알림용 팝업 메세지 출력하는 위젯
                                                    } else { // 로그인에 성공했다면
                                                      var _JWT = jwt.split(':')[0]; // 돌려받은 jwt 내용에서 :를 기준으로 나눈 것 중 첫번째 값 -> jwt 토큰 값
                                                      var _nickname = jwt.split(':')[1];// 돌려받은 jwt 내용에서 :를 기준으로 나눈 것 중 두번째 값 -> 닉네임 정보
                                                      //내부 안전한 저장소에 로그인 정보 저장
                                                      storage.write(key: "jwt", value: _JWT); // 저장소에 _jwt 값 저장
                                                      storage.write(key: "nickname", value: _nickname);// 저장소에 닉네임 값 저장
                                                      Get.off(Tabb(idx:0));//0번 탭 -> Home 화면으로 넘어감
                                                      ScaffoldMessenger.of(context).showSnackBar(//아래에 환영 메세지 띄움
                                                          SnackBar(content: Text(_nickname + "님 접속을 환영합니다."),)
                                                      );
                                                    }
                                                  },
                                                  child: const Text("로그인"), // 버튼에 로그인 텍스트를 집어 넣어 로그인 버튼임을 표시
                                                  style: ElevatedButton.styleFrom( // 버튼을 둥글게 꾸미고 색 설정
                                                      primary: const Color(0xff7795FF), // primary는 버튼 색 꾸미는 속성
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12)
                                                      ) //둥글게 설정
                                                  )
                                              ),
                                              // 회원가입 버튼
                                              ElevatedButton(
                                                  onPressed: () { // 눌렀을 때 동작하는 코드
                                                    Get.to(const Register()); // 회원가입 페이지로 넘어감
                                                  },
                                                  child: const Text("회원가입"), // 회원가입 버튼
                                                  style: ElevatedButton.styleFrom( // 버튼 꾸미기
                                                      primary: Colors.purpleAccent.shade100, // primary는 버튼 색 꾸미는 속성
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12)
                                                      ) // 둥글게 설정
                                                  )
                                              ),

                                              const Padding(
                                                padding: EdgeInsets.only(top: 50), // 회원가입 버튼과 여백 설정
                                                child: Text("만약 기억나지 않는다면",
                                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),

                                              Row( // 가로로 배치
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 가로로 배치되는 위젯들의 양옆 공간을 모두 균일하게 배치
                                                children: [
                                                  ElevatedButton(//아이디 찾는 버튼 위젯
                                                      onPressed: () {// 눌렀을 때 동작하는 코드
                                                        displayDialog_checkonly(context, "아이디 찾기", "ID는 회원님의 휴대전화 번호입니다.");
                                                      },
                                                      child: const Text("ID 찾기"), //버튼이 아이디 찾는 버튼임을 표시
                                                      style: ElevatedButton.styleFrom( // 버튼 꾸미기
                                                          primary: Colors.black, // primary는 버튼 색 꾸미는 속성
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12)
                                                          ) // 둥글게 설정
                                                      )
                                                  ),
                                                  ElevatedButton( // 비밀번호 찾는 위젯
                                                      onPressed: () { // 눌렀을 때 pw를 찾는 페이지로 넘어감
                                                        Get.to(const FindPW());
                                                      },
                                                      child: const Text("PW 찾기"), // pw 찾는 버튼임을 표시
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