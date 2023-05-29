import 'dart:convert';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Utilities/jwt_decode.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeNickname extends StatefulWidget {
  const ChangeNickname({Key? key}) : super(key: key);

  @override
  State createState() => _ChangeNickname();
}

class _ChangeNickname extends State<ChangeNickname> {
  Color chc = Colors.grey.shade200;
  String nick = "";
  late Future future;
  late bool theme;
  final _formkey_cha = GlobalKey<FormState>();
  final cha = TextEditingController();
  final FocusNode _chtextFieldFocus = FocusNode();
  String? id = "";
  String? nickname = "";
  bool? checkNickduplicate = false;

  Future<void> getInfo() async {
    id = await jwtDecode();
    nickname = await storage.read(key: "nickname");
    checkNickduplicate = false;
  }

  Future<int> check_Nickname(String nickname) async {
    if (nickname.isEmpty) {
      return 1;
    } else if (nickname.length > 20) {
      return 2;
    } else {
      try {
        const url = "$SERVER_IP/auth/checkNickname";
        final res = await http.post(Uri.parse(url), body: {
          "nickname": nickname,
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

  Future<bool> updateNickname(String id, String nickname) async {
    try {
      const url = "$SERVER_IP/auth/updateNickname";
      final res = await http.post(Uri.parse(url), body: {
        "id": id,
        "nickname": nickname,
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        storage.write(key: "nickname", value: nickname);
        return true;
      }
    } catch (ex) {
      return false;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getInfo();
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
  }

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("닉네임 변경", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                      color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
                  title: Text("닉네임 변경", style: TextStyle(color: (theme ? const Color(0xffe8e8e8) : Colors.black))),
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text("현재 사용하시는 닉네임은",
                                style: TextStyle(fontSize: 20)),
                            Text("$nickname", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
                            const Text("입니다.", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text("새 닉네임", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Form(
                                  key: _formkey_cha,
                                  child: TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    obscureText: false,
                                    keyboardType: TextInputType.text,
                                    controller: cha,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: chc,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),
                                          borderSide: const BorderSide(width: 0,)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: const BorderSide(width: 2, color: Color(0xffFFB877))),
                                    ),
                                    focusNode: _chtextFieldFocus,
                                    onSaved: (text) {
                                      setState(() {
                                        nick = text as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter Nickname for change";
                                      } else if (value.length > 20) {
                                        return "Nickname must not be more than 20 characters long";
                                      }
                                      return null;
                                    },
                                    onChanged: (text) {
                                      setState((){
                                        checkNickduplicate = false;
                                      });
                                    }
                                  ),
                                ),
                              ])),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            int res = await check_Nickname(cha.value.text);
                            if (res == 0) {
                              displayDialog_checkonly(context, "닉네임 중복 확인", "사용 가능한 닉네임입니다.");
                              setState(() {
                                checkNickduplicate = true;
                              });
                            } else if (res == 1) {
                              displayDialog_checkonly(context, "닉네임 변경 오류", "닉네임을 입력해주십시오.");
                              setState(() {
                                checkNickduplicate = false;
                              });
                            } else if (res == 2) {
                              displayDialog_checkonly(context, "닉네임 변경 오류", "닉네임은 20글자를 넘길 수 없습니다.");
                              setState(() {
                                checkNickduplicate = false;
                              });
                            } else {
                              displayDialog_checkonly(context, "닉네임 중복 오류", "해당 닉네임은 이미 존재하여 사용할 수 없습니다.");
                              setState(() {
                                checkNickduplicate = false;
                              });
                            }
                          },
                          child: const Text("중복확인"),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: Colors.deepPurpleAccent, // 버튼 색깔 설정
                          ),
                        ),
                      ),
                    ])
                    )
                ),
                bottomNavigationBar: Container(
                  padding : EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, height * 0.01),
                  child: ElevatedButton(
                    child: const Text("닉네임 변경"),
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.5)),
                        minimumSize: Size.fromHeight(height * 0.062),
                        primary: const Color(0xffEE3D43)
                    ),
                    onPressed: () {
                      if (checkNickduplicate == true) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("닉네임 변경"),
                            content: const Text("입력하신 닉네임으로 정말 변경하시겠습니까?"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () =>
                                    Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () async {
                                  if (await updateNickname(id!, cha.value.text) == true) {
                                    displayDialog_changeIndividual(context, "닉네임 변경 성공", "닉네임을 성공적으로 변경하였습니다.");
                                  } else {
                                    displayDialog_checkonly_directNN(context, "닉네임 변경 오류", "오류로 인하여 닉네임 변경에 실패했습니다.\n다시 시도해주십시오.");
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        displayDialog_checkonly(context, "닉네임 변경 오류", "중복확인을 먼저 해주시기 바랍니다.");
                      }
                    },
                  ),
                )

            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
