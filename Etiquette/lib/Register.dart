import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';

// 회원가입 화면
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Register();
}

class _Register extends State<Register> {
  Future<int> attemptSignUp(String id, String pw, String nickname) async {
    var res = await http.post(Uri.parse('$SERVER_IP/signup'), body: {"id": id, "pw": pw, "nickname": nickname});
    return res.statusCode;
  }

  final idController = TextEditingController(); // 휴대폰 번호
  final pwController = TextEditingController(); //pw
  final repwController = TextEditingController(); //pw 재입력
  final nicknameController = TextEditingController(); //nickname
  TextEditingController inputOtpController = TextEditingController(); // 인증 OTP
  bool _flag = false; // 인증 여부 확인

  FirebaseAuth auth = FirebaseAuth.instance; // 인증 instance
  User? user;
  String verificationID = "";

  void loginWithPhone() async {
    auth.verifyPhoneNumber(
      phoneNumber: "+82" + idController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          print("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationID = verificationId;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: inputOtpController.text);

    await auth.signInWithCredential(credential).then(
          (value) {
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      },
    ).whenComplete(
          () {
        if (user != null) {
          // 로그인 성공
          setState(() {
            _flag = true;
          });
          displayDialog(context, "Authentication", "Authenticated Successfully.");
        } else {
          // 로그인 실패
          setState(() {
            _flag = false;
          });
          displayDialog(context, "Authentication", "Fail Authenticated.");
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        }, //다른 곳 클릭하면 키보드 사라지도록 설정
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white24, //Appbar 설정, 글씨는 검정으로 설정
              foregroundColor: Colors.black,
            ),
            body: Center(
                child: SingleChildScrollView(
                  //스크롤 가능하도록 설정 만약 키보드가 나와서 화면이 길어질 떄 필요함
                    child: Column(//각종 입력 받을 텍스트 필드를 담을 공간
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 80), //좌측 여백 설정
                              child: Row //가로로 글자 배치
                                (children: <Widget>[
                                Text("Sign up", style: TextStyle(fontSize: 30)),
                                Text(
                                  "/Login",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                )
                              ])),
                          Column(children: <Widget>[
                            SizedBox(height: 30),
                            Padding(
                                padding: EdgeInsets.fromLTRB(80, 0, 80, 0),
                                child: Row(children: <Widget>[
                                  Flexible(
                                      child: TextField(
                                        controller: idController,
                                        keyboardType: TextInputType.number,
                                        //기본으로 숫자 모양의 키보드가 호출되도록 설정
                                        decoration: InputDecoration(
                                          labelText: "HP(ID)", //id 입력하는 공간
                                        ),
                                      )),
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    //텍스트 필드와 약간의 여백 생성
                                    child: ElevatedButton(
                                        onPressed: () {
                                          loginWithPhone();
                                        }, //인증받기 위해 누르는 버튼
                                        child: Text("인증"),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.deepPurpleAccent //버튼 색깔 설정
                                        )),
                                  )
                                ])),
                            Padding(
                              //인증번호를 위한 공간
                                padding: EdgeInsets.fromLTRB(80, 20, 80, 0),
                                //ID 입력 칸과 여백 및, 좌우 공간 여백 설정
                                child: Row(children: <Widget>[
                                  Flexible(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: inputOtpController,
                                        //기본으로 숫자 모양의 키보드가 호출되도록 설정
                                        decoration: InputDecoration(
                                          labelText: "인증번호", //인증번호 입력하는 공간
                                        ),
                                      )),
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    //텍스트 필드와 약간의 여백 생성
                                    child: ElevatedButton(
                                        onPressed: () {
                                          verifyOTP();
                                        }, // OTP 인증
                                        child: Text("확인"),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.deepPurpleAccent //버튼 색깔 설정
                                        )),
                                  )
                                ])),
                            Padding(
                                padding: EdgeInsets.fromLTRB(80, 20, 80, 0),
                                child: TextField(
                                  controller: pwController,
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  //기본으로 자판 모양의 키보드가 호출되도록 설정, pw 안보이도록 가림
                                  decoration: InputDecoration(
                                    labelText:
                                    "Password (At least 8 characters)", //PW 입력하는 공간
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.fromLTRB(80, 20, 80, 0),
                                child: TextField(
                                  controller: repwController,
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  //기본으로 자판 모양의 키보드가 호출되도록 설정, pw 안보이도록 가림
                                  decoration: InputDecoration(
                                    labelText: "재확인", //PW 다시 입력하는 공간
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.fromLTRB(80, 20, 80, 0),
                                //재확인 입력 칸과 여백 및, 좌우 공간 여백 설정
                                child: TextFormField(
                                  controller: nicknameController,
                                  keyboardType: TextInputType.text,
                                  //기본으로 자판 모양의 키보드가 호출되도록 설정, pw 안보이도록 가림
                                  decoration: InputDecoration(
                                    labelText: "Name", //이름 입력하는 공간
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                //이름 입력 칸과 여백 및, 좌우 공간 여백 설정 버튼은 필요한 만큼만 쓰기 때문에 좌우 여백 지정할 필요 없음
                                child: Column(children: <Widget>[
                                  ElevatedButton(
                                      onPressed: () {},
                                      child: const Text("Klaytn Linkage"),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                        //클레이튼 연동 버튼, 버튼 색깔 설정 및 둥글게 설정
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      )),
                                  ElevatedButton(
                                    onPressed: () async {
                                      var _id = idController.text;
                                      var _pw = pwController.text;
                                      var _repw = repwController.text;
                                      var _nickname = nicknameController.text;
                                      if (_pw.length < 8) {
                                        displayDialog(context, "Invalid Password",
                                            "The password should be at least 8 characters long");
                                      } else if (_pw != _repw) {
                                        displayDialog(context, "Check Password",
                                            "Two Password Is Different");
                                      } else if (!_flag) {
                                        displayDialog(context, "Not Authenticated",
                                            "Not Authenticated");
                                      } else {
                                        var res = await attemptSignUp(_id, _pw, _nickname);
                                        if (res == 201) {
                                          displayDialog_checkonly(context, "Success", "The user was created. Log in now.");
                                        } else if (res == 409)
                                          displayDialog(
                                              context,
                                              "That user is already registered",
                                              "Please try to sign up using another id or log in if you already have an account.");
                                        else {
                                          displayDialog(context, "Error", "An unknown error occurred.");
                                        }
                                      }
                                    },
                                    child: const Text("가입"),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.purpleAccent.shade100,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12))),
                                  )
                                ]) //가입 버튼, 버튼 색깔 설정 및 둥글게 설정
                            )
                          ])
                        ])))));
  }
}
