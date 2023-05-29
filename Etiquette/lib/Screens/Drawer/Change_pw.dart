import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Utilities/jwt_decode.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';

class ChangePW extends StatefulWidget {
  const ChangePW({Key? key}) : super(key: key);

  @override
  State createState() => _ChangePW();
}

class _ChangePW extends State<ChangePW> {
  Color chc = Colors.grey.shade200;
  Color rec = Colors.grey.shade200;
  String chpw = "";
  String repw = "";
  final _formkey_cha = GlobalKey<FormState>();
  final _formkey_re = GlobalKey<FormState>();
  final cha = TextEditingController();
  final re = TextEditingController();
  final FocusNode _chtextFieldFocus = FocusNode();
  final FocusNode _retextFieldFocus = FocusNode();
  String? id = "";
  String? nickname = "";

  Future<void> getInfo() async {
    id = await jwtDecode();
    nickname = await storage.read(key: "nickname");
  }

  Future<bool> check_curPW(String id, String pw) async {
    try {
      const url = "$SERVER_IP/auth/checkPassword";
      final res = await http.post(Uri.parse(url), body: {"id": id, "pw": pw});
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        return true;
      }
    } catch (ex) {
      return false;
    }
    return false;
  }

  Future<int> updatePW(String id, String pw) async {
    if (pw.length < 8) {
      return 1;
    } else if (await check_curPW(id, pw) == true) {
      return 2;
    } else {
      try {
        const url = "$SERVER_IP/auth/updatePassword";
        final res = await http.post(Uri.parse(url), body: {
          "id": id,
          "pw": pw,
        });
        Map<String, dynamic> data = json.decode(res.body);
        if (data['statusCode'] == 200) {
          return 0;
        }
      } catch (ex) {
        return 3;
      }
    }
    return 3;
  }

  @override
  void initState() {
    super.initState();
    getInfo();
    _chtextFieldFocus.addListener(() {
      if (_chtextFieldFocus.hasFocus) {
        setState(() {
          chc = Colors.white24;
        });
      } else {
        setState(() {
          chc = Colors.grey.shade200;
        });
      }
    });
    _retextFieldFocus.addListener(() {
      if (_retextFieldFocus.hasFocus) {
        setState(() {
          rec = Colors.white24;
        });
      } else {
        setState(() {
          rec = Colors.grey.shade200;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                  "비밀번호 변경",
                  style: TextStyle(fontWeight: FontWeight.bold)
              ),
              elevation: 0,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white24,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Get.back(); //Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
                    children: <Widget> [
                      const SizedBox(height: 20),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                const Text(
                                    "새 비밀번호",
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 10),
                                Form(
                                  key: _formkey_cha,
                                  child: TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    obscureText: true,
                                    keyboardType: TextInputType.text,
                                    controller: cha, //기본으로 자판 모양의 키보드 호출되도록 설정
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: chc,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: const BorderSide(width: 0)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              width: 2,
                                              color: Color(0xffFFB877)
                                          )
                                      ),
                                    ),
                                    focusNode: _chtextFieldFocus,
                                    onSaved: (text) {
                                      setState(() {
                                        chpw = text as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter Password for change";
                                      } else if (value.length < 8) {
                                        return "Password must be at least 8 characters long";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ]
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                const Text(
                                    "새 비밀번호 확인",
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 10),
                                Form(
                                  key: _formkey_re,
                                  child: TextFormField(
                                    autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                    obscureText: true,
                                    keyboardType: TextInputType.text,
                                    controller: re,
                                    // 기본으로 자판 모양의 키보드 호출되도록 설정
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: rec,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                            width: 0,
                                          )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              width: 2, color: Color(0xffFFB877)
                                          )
                                      ),
                                    ),
                                    focusNode: _retextFieldFocus,
                                    onSaved: (text) {
                                      setState(() {
                                        repw = text as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter PW for check";
                                      } else if (cha.text != re.text) {
                                        return "비밀번호가 일치하지 않습니다.";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ]
                          )
                      )
                    ]
                )
            ),
            bottomNavigationBar: Container(
              padding : EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, height * 0.01),
              child: ElevatedButton(
                child: const Text("비밀번호 변경"),
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(9.5)
                    ),
                    minimumSize: Size.fromHeight(height * 0.062),
                    primary: const Color(0xffEE3D43)
                ),
                onPressed: () async {
                  if (cha.value.text == re.value.text) {
                    if (await updatePW(id!, cha.value.text) == 0) {
                      displayDialog_changeIndividual(context, "비밀번호 변경 성공", "비밀번호를 성공적으로 변경했습니다.");
                    }
                    else if (await updatePW(id!, cha.value.text) == 1) {
                      displayDialog_checkonly(context, "비밀번호 변경 오류", "비밀번호는 최소 8글자 이상이어야 합니다.");
                    }
                    else if (await updatePW(id!, cha.value.text) == 2) {
                      displayDialog_checkonly(context, "기존 비밀번호 재사용", "기존과 같은 비밀번호로는 변경할 수 없습니다.\n다시 시도해주십시오.");
                    }
                    else if (await updatePW(id!, cha.value.text) == 3) {
                      displayDialog_checkonly(context, "비밀번호 변경 오류", "오류로 인하여 비밀번호 변경에 실패했습니다.\n다시 시도해주십시오.");
                    }
                  } else {
                    displayDialog_checkonly(context, "새 비밀번호 확인 오류", "새 비밀번호 확인을 위해 다시 한번 입력해주십시오.");
                  }
                },
              ),
            )
        )
    );
  }
}
