import 'package:flutter/material.dart';

import 'Register.dart';
import 'TabController.dart';

// 로그인 화면

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Login();
}

class _Login extends State<Login> {
  final _formkey_id = GlobalKey<FormState>();
  final _formkey_pw = GlobalKey<FormState>();
  String id = ""; //입력한 아이디를 받을 변수
  String pw = ""; //입력한 패스워드를 받을 변수
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        //만약 화면 영역 밖을 선택하면 키보드 사라지게 설정
        child: Scaffold(
            body: Center(
                //가운데 정렬
                child: SingleChildScrollView(
                    //스크롤 가능하게 설정 -> 만약 한 화면 내에 안담기더라도 스크롤 해서 볼 수 있음
                    child: Column //세로로 배치
                        (children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 80), //좌측 공간 확보
              child: Row //가로로 Login, Signup 배치
                  (children: <Widget>[
                Text("Login", style: TextStyle(fontSize: 30)),
                Text(
                  "/Sign up",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                )
              ]) //사이즈, 컬러 설정 및 텍스트 입력
              ),
          Padding(
              padding: EdgeInsets.fromLTRB(80, 0, 80, 0),
              //좌우 여백 확보.
              child: Column(//텍스트 필드, 버튼 세로로 배치
                  children: <Widget>[
                SizedBox(height: 30),
                //Login/Sign up과 공간 확보를 위한 위젯
                Form(
                  key: _formkey_id,
                  child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.text,
                      //기본으로 자판 모양의 키보드 호출되도록 설정
                      decoration: InputDecoration(
                        //icon: const Text("ID:"),
                        labelText: "ID", //입력칸에 ID 표시되도록
                        //border : OutlineInputBorder()
                      ),
                      onSaved: (text) {
                        setState(() {
                          id = text as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter id";
                        }
                        return null;
                      }),
                ),
                Form(
                    key: _formkey_pw,
                    child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.text,
                        //기본으로 자판 모양의 키보드 호출되도록 설정
                        obscureText: true,
                        //비밀번호 안보이도록 설정
                        decoration: InputDecoration(
                          //icon: const Text("PW:"),
                          labelText: "Password", //입력칸에 PW 표시되도록
                          //border : OutlineInputBorder()
                        ),
                        onSaved: (text) {
                          setState(() {
                            pw = text as String; //텍스트 필드가 변할 때마다 그 값을 저장하도록 설정
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter pw";
                          }
                          return null;
                        })),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    //비밀번호 입력하는 칸과 공간 확보
                    child: Column(//로그인, 회원가입 버튼 세로로 배치
                        children: <Widget>[
                      ElevatedButton(
                          onPressed: () {
                            if (_formkey_id.currentState!.validate() &&
                                _formkey_pw.currentState!.validate()) {
                              _formkey_id.currentState!.save();
                              _formkey_pw.currentState!.save();

                              Navigator.pushReplacement(
                                  //로그인 버튼이 눌렸을 때 Tabb 클래스 실행되도록 -> Tabb 창 실행되도록 설정
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Tabb(idx: 0)));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(id + "님 접속을 환영합니다."),
                                ),
                              );
                            }
                          },
                          child: const Text("로그인"),
                          //로그인 버튼
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xff7795FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)) //둥글게 설정
                              )),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                //눌렸을 떄 Register 클래스 실행되도록 -> Register 창 실행되도록 설정
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()));
                          },
                          child: const Text("회원가입"),
                          //회원가입 버튼
                          style: ElevatedButton.styleFrom(
                              primary: Colors.purpleAccent.shade100,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)) //둥글게 설정
                              ))
                    ])),
              ]))
        ])))));
  }
}
