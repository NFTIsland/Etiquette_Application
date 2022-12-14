import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Providers/KAS/Wallet/check_KAS_address.dart';
import 'package:Etiquette/Providers/KAS/Wallet/create_KAS_account.dart';
import 'package:Etiquette/Screens/qr_code_scanner.dart';
import 'package:Etiquette/Screens/Login.dart';

// 회원가입 화면
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Register();
}

class _Register extends State<Register> {
  Future<int> attemptSignUp(String id, String pw, String nickname, String kas_address) async {
    var res = await http.post(Uri.parse('$SERVER_IP/auth/signup'), body: {
      "id": id,
      "pw": pw,
      "nickname": nickname,
      'kas_address': kas_address
    });
    return res.statusCode;
  }

  final idController = TextEditingController(); // 휴대폰 번호
  final pwController = TextEditingController(); //pw
  final repwController = TextEditingController(); //pw 재입력
  final nicknameController = TextEditingController(); //nickname
  final inputOtpController = TextEditingController(); // 인증 OTP
  final inputKlaytnAddressController = TextEditingController(); // KAS 주소 입력받기
  bool flag_auth = false; // 인증 여부 확인
  bool flag_KAS = false; // KAS 연동 여부 확인
  bool allow_change_kas_address = true;

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
            flag_auth = true;
          });
          displayDialog(
              context, "Authentication", "Authenticated Successfully.");
        } else {
          // 로그인 실패
          setState(() {
            flag_auth = false;
          });
          displayDialog(context, "Authentication", "Fail Authenticated.");
        }
      },
    );
  }

  final String availableKasAddressMsg = "유효한 KAS 주소입니다";
  final String notAvailableKasAddressMsg1 =
      "1. KAS 주소를 올바르게 입력했는지 확인해 주세요.\n\n";
  final String notAvailableKasAddressMsg2 =
      "2. KAS 계정이 없을 경우 회원 가입 후 KAS 계정 생성 버튼을 눌러 계성 생성을 진행해 주세요.\n\n";
  final String notAvailableKasAddressMsg3 =
      "3. Kaikas, Metamask를 사용하셨더라도 KAS 계정이 있어야 합니다. 본 어플은 KAS를 통해 KLAY 교환 및 NFT 생성이 이루어집니다.";

  // KAS 계정이 제대로 입력되었는지를 확인
  Future<void> checkKlaytnAddress() async {
    String inputAddress = inputKlaytnAddressController.text;
    Map<String, dynamic> data = await checkKasAddress(inputAddress);

    if (data["statusCode"] == 200) {
      displayDialog_checkonly(context, "KAS(Klaytn Api Service) 주소 확인", availableKasAddressMsg);
      flag_KAS = true;
    } else {
      final notAvailableKasAddressMsg = data["msg"] +
          "\n\n" +
          notAvailableKasAddressMsg1 +
          notAvailableKasAddressMsg2 +
          notAvailableKasAddressMsg3;
      displayDialog_checkonly(context, "KAS(Klaytn Api Service) 주소 확인", notAvailableKasAddressMsg);
      flag_KAS = false;
    }
  }

  // KAS 계정 생성
  Future<void> createKlaytnAddress() async {
    if (allow_change_kas_address) {
      Map<String, dynamic> address = await createKasAccount();
      if (address['statusCode'] == 200) {
        inputKlaytnAddressController.text = address['data'];
        displayDialog_checkonly(context, "KAS 계정 생성", "KAS 계정이 성공적으로 생성되었습니다.");
        flag_KAS = true;
        allow_change_kas_address = false;
      } else {
        displayDialog_checkonly(context, "Failed", address['msg']);
      }
    } else {
      displayDialog_checkonly(context, "KAS 계정 생성", "이미 KAS 계정을 생성하였습니다.");
    }
  }

  Future<Map<String, dynamic>> checkNicknameIsDuplicate() async {
    if (nicknameController.text == "") {
      return {
        "statusCode": 400,
        "msg": "사용할 닉네임을 입력해 주세요.",
      };
    }

    const url = "$SERVER_IP/auth/checkNickname";
    try {
      final res = await http.post(Uri.parse(url), body: {
        "nickname": nicknameController.text,
      });
      Map<String, dynamic> data = json.decode(res.body);
      return data;
    } catch (ex) {
      print("닉네임 중복 확인 --> ${ex.toString()}");
      return {
        "statusCode": 400,
        "msg": ex.toString(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
                child: SingleChildScrollView( // 스크롤 가능하도록 설정 만약 키보드가 나와서 화면이 길어질 떄 필요함
                    child: Column( // 각종 입력 받을 텍스트 필드를 담을 공간
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(left: 80), // 좌측 여백 설정
                              child: Row( // 가로로 글자 배치
                                  children: const <Widget>[
                                    Text(
                                        "Sign up",
                                        style: TextStyle(fontSize: 30)
                                    ),
                                    Text(
                                      "/Login",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ]
                              )
                          ),
                          Column(
                              children: <Widget> [
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                  child: Row(
                                    children: <Widget> [
                                      Flexible(
                                        child: TextField(
                                          maxLines: 1,
                                          maxLength: 11,
                                          controller: idController,
                                          keyboardType: TextInputType.number, // 기본으로 숫자 모양의 키보드가 호출되도록 설정
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: "HP(ID)",
                                            counterText: "",
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            focusColor: Colors.grey[100],
                                            hoverColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            labelStyle: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 18,
                                              fontFamily: 'Quicksand',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 10), // 텍스트 필드와 약간의 여백 생성
                                        child: ElevatedButton(
                                          onPressed: () {
                                            loginWithPhone();
                                          },
                                          child: const Text(
                                            "인증",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            primary: Colors.deepPurpleAccent, // 버튼 색깔 설정
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding( // 인증번호를 위한 공간
                                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: TextField(
                                          maxLines: 1,
                                          maxLength: 6,
                                          keyboardType: TextInputType.number, // 기본으로 숫자 모양의 키보드가 호출되도록 설정
                                          controller: inputOtpController,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: "인증번호", // 인증번호 입력하는 공간
                                            counterText: "",
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            focusColor: Colors.grey[100],
                                            hoverColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            labelStyle: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 18,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            verifyOTP();
                                          }, // OTP 인증
                                          child: const Text("확인"),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            primary: Colors.deepPurpleAccent, //버튼 색깔 설정
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                                  child: TextField(
                                    maxLines: 1,
                                    maxLength: 20,
                                    controller: pwController,
                                    obscureText: true, // pw 안보이도록 가림
                                    keyboardType: TextInputType.text, // 기본으로 자판 모양의 키보드가 호출되도록 설정
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Password (최소 8글자)", // PW 입력하는 공간
                                      counterText: "",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      focusColor: Colors.grey[100],
                                      hoverColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18,
                                        fontFamily: 'Quicksand',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                                  child: TextField(
                                    maxLines: 1,
                                    maxLength: 20,
                                    controller: repwController,
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "재확인", // PW 다시 입력하는 공간
                                      counterText: "",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      focusColor: Colors.grey[100],
                                      hoverColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18,
                                        fontFamily: 'Pretendard',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                                  child: Row(
                                    children: <Widget> [
                                      Flexible(
                                        child: TextFormField(
                                          maxLines: 1,
                                          maxLength: 20,
                                          controller: nicknameController,
                                          keyboardType: TextInputType.text,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: "닉네임", // 이름 입력하는 공간
                                            counterText: "",
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            focusColor: Colors.grey[100],
                                            hoverColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            labelStyle: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 18,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final res = await checkNicknameIsDuplicate();
                                            displayDialog_checkonly(context, "닉네임 중복 확인", res["msg"]);
                                          }, // OTP 인증
                                          child: const Text("중복확인"),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            primary: Colors.deepPurpleAccent, // 버튼 색깔 설정
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                                  child: TextField(
                                    maxLines: 1,
                                    maxLength: 42,
                                    enabled: allow_change_kas_address,
                                    keyboardType: TextInputType.text,
                                    controller: inputKlaytnAddressController,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "KAS 주소",
                                      counterText: "",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      focusColor: Colors.grey[100],
                                      hoverColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18,
                                        fontFamily: 'Quicksand',
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.qr_code),
                                        onPressed: () async {
                                          final qrCodeScanResult = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                const QRCodeScanner()
                                            ),
                                          );
                                          inputKlaytnAddressController.text = qrCodeScanResult!;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(80, 5, 80, 0),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          // ElevatedButton(
                                          //   child: const Icon(Icons.qr_code),
                                          //   style: ElevatedButton.styleFrom(
                                          //       primary: Colors.deepPurpleAccent
                                          //   ),
                                          //   onPressed: () async {
                                          //     final qrCodeScanResult = await Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //           builder: (context) =>
                                          //           const QRCodeScanner()
                                          //       ),
                                          //     );
                                          //     inputKlaytnAddressController.text = qrCodeScanResult!;
                                          //   },
                                          // ),
                                          ElevatedButton(
                                            child: const Text("생성"),
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              primary: Colors.deepPurpleAccent,
                                            ),
                                            onPressed: () async {
                                              await createKlaytnAddress();
                                              setState(() {});
                                            }
                                          ),
                                          ElevatedButton(
                                            child: const Text("확인"),
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              primary: Colors.deepPurpleAccent,
                                            ),
                                            onPressed: () async {
                                              await checkKlaytnAddress();
                                            },
                                          ),
                                        ]
                                    )
                                ),
                              ]
                          ),
                        ]
                    ),
                ),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(width * 0.03, height * 0.01, width * 0.03, height * 0.011),
            child: ElevatedButton(
              onPressed: () async {
                var _id = idController.text;
                var _pw = pwController.text;
                var _repw = repwController.text;
                var _nickname = nicknameController.text;
                var _address = inputKlaytnAddressController.text;
                if (_pw.length < 8) {
                  displayDialog(context, "Invalid Password", "The password should be at least 8 characters long");
                } else if (_pw != _repw) {
                  displayDialog(context, "Check Password", "Two Password Is Different");
                } else if (!flag_auth) {
                  displayDialog(context, "Not Authenticated", "Not Authenticated");
                } else if (!flag_KAS) {
                  displayDialog(context, "KAS Address", "The KAS account is not yet linked.");
                } else {
                  var res = await attemptSignUp(_id, _pw, _nickname, _address);
                  if (res == 201) {
                    await displayDialog_checkonly(context, "회원가입", "회원가입이 완료되었습니다.");
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ), (route) => false
                    );
                  } else if (res == 409) {
                    displayDialog(context, "That user is already registered", "Please try to sign up using another id or log in if you already have an account.");
                  } else {
                    displayDialog(context, "Error", "An unknown error occurred.");
                  }
                }
              },
              // child: const Text("가입"),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget> [
                  Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                  Text(
                    " 가입",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.5)
                ),
                minimumSize: Size.fromHeight(height * 0.062),
                primary: Colors.cyan,
              ),
              // style: ElevatedButton.styleFrom(
              //   primary: Colors.purpleAccent.shade100,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              // ),
            ),
          ),
        ),
    );
  }
}
