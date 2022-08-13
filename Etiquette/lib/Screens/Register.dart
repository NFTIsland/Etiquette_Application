import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Screens/qr_code_scanner.dart';
import 'package:Etiquette/Providers/KAS/Wallet/check_KAS_address.dart';
import 'package:Etiquette/Providers/KAS/Wallet/create_KAS_account.dart';

// 회원가입 화면
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Register();
}

class _Register extends State<Register> {
  Future<int> attemptSignUp(String id, String pw, String nickname, String kas_address) async {
    var res = await http.post(Uri.parse('$SERVER_IP/signup'), body: {
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
      displayDialog_checkonly(
          context, "KAS(Klaytn Api Service) 주소 확인", availableKasAddressMsg);
      flag_KAS = true;
    } else {
      final notAvailableKasAddressMsg = data["msg"] +
          "\n\n" +
          notAvailableKasAddressMsg1 +
          notAvailableKasAddressMsg2 +
          notAvailableKasAddressMsg3;
      displayDialog_checkonly(
          context, "KAS(Klaytn Api Service) 주소 확인", notAvailableKasAddressMsg);
      flag_KAS = false;
    }
  }

  // KAS 계정 생성
  Future<void> createKlaytnAddress() async {
    Map<String, dynamic> address = await createKasAccount();
    if (address['statusCode'] == 200) {
      inputKlaytnAddressController.text = address['data'];
      flag_KAS = true;
      displayDialog_checkonly(context, "Successfully Created",
          "The KAS account is successfully created");
    } else {
      displayDialog_checkonly(context, "Failed", address['msg']);
    }
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
                child: SingleChildScrollView( // 스크롤 가능하도록 설정 만약 키보드가 나와서 화면이 길어질 떄 필요함
                    child: Column( // 각종 입력 받을 텍스트 필드를 담을 공간
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(left: 80),
                              // 좌측 여백 설정
                              child: Row( //가로로 글자 배치
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
                              children: <Widget>[
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: TextField(
                                          controller: idController,
                                          keyboardType: TextInputType.number,
                                          // 기본으로 숫자 모양의 키보드가 호출되도록 설정
                                          decoration: const InputDecoration(
                                            labelText: "HP(ID)",
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 10), // 텍스트 필드와 약간의 여백 생성
                                        child: ElevatedButton(
                                          onPressed: () {
                                            loginWithPhone();
                                          },
                                          child: const Text("인증"),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.deepPurpleAccent // 버튼 색깔 설정
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding( // 인증번호를 위한 공간
                                    padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                                    child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                // 기본으로 숫자 모양의 키보드가 호출되도록 설정
                                                controller: inputOtpController,
                                                decoration: const InputDecoration(
                                                  labelText: "인증번호", // 인증번호 입력하는 공간
                                                ),
                                              )
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  verifyOTP();
                                                }, // OTP 인증
                                                child: const Text("확인"),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.deepPurpleAccent //버튼 색깔 설정
                                                )
                                            ),
                                          )
                                        ]
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                                    child: TextField(
                                      controller: pwController,
                                      obscureText: true,
                                      // pw 안보이도록 가림
                                      keyboardType: TextInputType.text,
                                      // 기본으로 자판 모양의 키보드가 호출되도록 설정
                                      decoration: const InputDecoration(
                                        labelText: "Password (최소 8글자)", // PW 입력하는 공간
                                      ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                                    child: TextField(
                                      controller: repwController,
                                      keyboardType: TextInputType.text,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: "재확인", //PW 다시 입력하는 공간
                                      ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                                    child: TextFormField(
                                      controller: nicknameController,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        labelText: "Name", // 이름 입력하는 공간
                                      ),
                                    )
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                                  child: TextField(
                                    keyboardType: TextInputType.text,
                                    controller: inputKlaytnAddressController,
                                    decoration: const InputDecoration(
                                      labelText: "KAS 주소",
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          ElevatedButton(
                                            child: const Icon(Icons.qr_code),
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.deepPurpleAccent
                                            ),
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
                                          ElevatedButton(
                                            child: const Text("생성"),
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.deepPurpleAccent
                                            ),
                                            onPressed: () async {
                                              createKlaytnAddress();
                                            }
                                          ),
                                          ElevatedButton(
                                            child: const Text("확인"),
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.deepPurpleAccent),
                                            onPressed: () {
                                              checkKlaytnAddress();
                                            },
                                          ),
                                        ]
                                    )
                                ),
                                ElevatedButton(
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
                                        displayDialog_register(context, "Success", "The user was created. Log in now.");
                                      } else if (res == 409) {
                                        displayDialog(context, "That user is already registered", "Please try to sign up using another id or log in if you already have an account.");
                                      } else {
                                        displayDialog(context, "Error", "An unknown error occurred.");
                                      }
                                    }
                                  },
                                  child: const Text("가입"),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.purpleAccent.shade100,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)
                                      )
                                  ),
                                )
                              ]
                          )
                        ]
                    )
                )
            )
        )
    );
  }
}
