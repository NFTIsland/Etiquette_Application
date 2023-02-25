import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/widgets/AlertDialogWidget.dart';
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
  final idController = TextEditingController(); // 휴대폰 번호(id) 입력받는 컨트롤러
  final inputOtpController = TextEditingController(); // 인증 OTP
  final pwController = TextEditingController(); // pw 입력받는 컨트롤러
  final repwController = TextEditingController(); // pw 재입력받는 컨트롤러
  final emailController = TextEditingController(); // email 입력받는 컨트롤러
  final nicknameController = TextEditingController(); // nickname 입력받는 컨트롤러
  final inputKlaytnAddressController = TextEditingController(); // KAS 주소 입력받는 컨트롤러
  bool flag_auth = false; // 인증 여부 확인
  bool email_input = false; // email 제대로 입력되었는지 확인
  bool nickname_input = false; // 닉네임 제대로 입력되었는지 확인
  bool flag_KAS = false; // KAS 연동 여부 확인
  bool allow_change_kas_address = true;

  FirebaseAuth auth = FirebaseAuth.instance; // 인증 instance
  User? user;
  String verificationID = "";

  // DB에 회원 정보 저장 시도
  Future<int> attemptSignUp(
      String id, String pw, String email, String nickname, String kas_address) async {
    var res = await http.post(Uri.parse('$SERVER_IP/auth/signup'), body: {
      "id": id,
      "pw": pw,
      "email": email,
      "nickname": nickname,
      'kas_address': kas_address
    });
    return res.statusCode;
  }

  // 핸드폰 번호를 통한 인증
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

  // 인증번호 확인
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
          displayDialog_checkonly(
              context, "인증 성공", "성공적으로 인증되었습니다.");
        } else {
          // 로그인 실패
          setState(() {
            flag_auth = false;
          });
          displayDialog_checkonly(
              context, "인증 실패", "인증에 실패하였습니다.\n다시 시도해주십시오.");
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

  // 닉네임 중복 여부 확인
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
      if (data['statusCode'] == 200){
        setState((){
          nickname_input = true;
        });
      }
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
        FocusScope.of(context).unfocus(); // 다른 곳 클릭하면 키보드 사라지도록 설정
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true, // 페이지 제목 중앙에 배치
          elevation: 0,
          backgroundColor: Colors.white24, // Appbar 설정, 글씨는 검정으로 설정
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: SingleChildScrollView(
            // 스크롤 가능하도록 설정, 만약 키보드가 나와서 화면이 길어질 때 필요함
            child: Column(
                children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(left: 80), // 좌측 여백 설정
                  child: Row(
                      children: const <Widget>[
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
                const SizedBox(height: 30),
                // ID 입력 필드
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ID를 입력해주십시오.";
                            }
                            return null;
                          },
                        ),
                      ),
                      // 인증번호 전송 요청 버튼
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
                // 인증번호 입력 필드
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            labelText: "인증번호",
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "인증번호를 입력해주십시오.";
                            }
                            return null;
                          },
                        ),
                      ),
                      // 인증번호 확인 버튼
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
                // PW 입력 필드
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                  child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        labelText: "Password (최소 8, 최대 20글자)",
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "비밀번호를 입력해주십시오.";
                        } else if (value.length < 8) {
                          return "비밀번호는 최소 8, 최대 20글자여야 합니다.";
                        }
                        return null;
                      }),
                ),
                // 비밀번호 재입력 필드
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                  child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        labelText: "재확인",
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "비밀번호를 다시 입력해주십시오.";
                        } else if (value.length < 8) {
                          return "비밀번호는 최소 8, 최대 20글자여야 합니다.";
                        } else if (pwController.text != repwController.text) {
                          return "비밀번호가 서로 다릅니다.";
                        }
                        return null;
                      }),
                ),
                // Email 주소 입력 필드
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLines: 1,
                    maxLength: 64,
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: "Email(Password 재발급 시 필요)",
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email 주소를 입력해주세요.";
                      } else if (!RegExp(
                              r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                          .hasMatch(value)) {
                        return "유효하지 않은 Email입니다.";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (text) {
                      if (!RegExp(
                              r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                          .hasMatch(text)) {
                        setState(() {
                          email_input = false;
                        });
                      } else {
                        setState(() {
                          email_input = true;
                        });
                      }
                    },
                  ),
                ),
                // 닉네임 입력 필드
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            labelText: "닉네임",
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "닉네임을 입력해주십시오.";
                            }
                            return null;
                          },
                          onChanged: (text){
                            setState((){
                              nickname_input = false;
                            });
                          },
                        ),
                      ),
                      // 닉네임 중복 확인 버튼
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            final res = await checkNicknameIsDuplicate();
                            displayDialog_checkonly(
                                context, "닉네임 중복 확인", res["msg"]);
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
                // KAS 주소 필드
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
                      fontSize: 20,
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
                        fontFamily: 'Pretendard',
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code),
                        onPressed: () async {
                          final qrCodeScanResult = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const QRCodeScanner()),
                          );
                          inputKlaytnAddressController.text = qrCodeScanResult!;
                        },
                      ),
                    ),
                  ),
                ),
                // KAS 주소 생성 버튼
                Padding(
                    padding: const EdgeInsets.fromLTRB(80, 5, 80, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                              child: const Text("생성"),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: Colors.deepPurpleAccent,
                              ),
                              onPressed: () async {
                                await createKlaytnAddress();
                                setState(() {});
                              }),
                          // KAS 주소 확인 버튼
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
                        ])),
              ]),
            ]),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
              width * 0.03, height * 0.01, width * 0.03, height * 0.011),
          child: ElevatedButton(
            onPressed: () async {
              var _id = idController.text;
              var _pw = pwController.text;
              var _repw = repwController.text;
              var _email = emailController.text;
              var _nickname = nicknameController.text;
              var _address = inputKlaytnAddressController.text;
              if (!flag_auth) {
                displayDialog_checkonly(context, "인증되지 않음",
                    "아직 인증 절차를 진행하지 않았습니다.\n인증 절차를 진행해주십시오.");
              } else if (_pw.length < 8) {
                displayDialog_checkonly(
                    context, "패스워드 확인", "패스워드는 최소 8글자 이상이어야 합니다.");
              } else if (_pw != _repw) {
                displayDialog_checkonly(
                    context, "패스워드 확인", "재입력된 패스워드가 다릅니다.\n다시 확인해주십시오.");
              } else if (!email_input) {
                displayDialog_checkonly(
                    context, "Email 확인", "Email 주소를 다시 확인해주십시오.");
              } else if (!nickname_input) {
                displayDialog_checkonly(context, "닉네임 확인",
                    "닉네임 중복확인이 되지 않았습니다.\n확인 절차를 진행해주십시오.");
              } else if (!flag_KAS) {
                displayDialog_checkonly(context, "KAS Address 연결되지 않음",
                    "KAS Address가 아직 연결되지 않았습니다.\n연결 절차를 진행해주십시오.");
              } else {
                var res = await attemptSignUp(_id, _pw, _email, _nickname, _address);
                if (res == 201) {
                  await displayDialog_checkonly(
                      context, "회원가입", "회원가입이 완료되었습니다.");
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                      (route) => false);
                } else if (res == 409) {
                  displayDialog_checkonly(context, "사용자 정보 존재",
                      "해당 정보가 이미 존재합니다.\n새 정보를 입력하여 회원가입하시거나\n이미 회원이신 경우 로그인해주십시오.");
                } else {
                  displayDialog_checkonly(
                      context, "Error", "알 수 없는 error가 발생했습니다.\n다시 시도해주십시오.");
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
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
                  borderRadius: BorderRadius.circular(9.5)),
              minimumSize: Size.fromHeight(height * 0.062),
              primary: Colors.cyan,
            ),
          ),
        ),
      ),
    );
  }
}
