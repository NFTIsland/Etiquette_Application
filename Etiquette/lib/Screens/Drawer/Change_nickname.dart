import 'dart:convert';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Utilities/jwt_decode.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeNickname extends StatefulWidget {
  State createState() => _ChangeNickname();
}

class _ChangeNickname extends State<ChangeNickname> {
  Color chc = Colors.grey.shade200;
  String nick = "";
  late Future future;
  late bool theme;
  final _formkey_cha = GlobalKey<FormState>();
  final cha = TextEditingController();
  FocusNode _chtextFieldFocus = FocusNode();
  String? id = "";
  String? nickname = "";
  bool? checkNickduplicate = false;

  Future<void> getInfo() async {
    id = await jwtDecode();
    nickname = await storage.read(key: "nickname");
    checkNickduplicate = false;
  }

  Future<int> check_Nickname(String nickname) async {
    if (nickname.length == 0) {
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
              appBar: appbarWithArrowBackButton("????????? ??????", theme),
              body: const Center(
                child: Text("?????? ????????? ??????????????????."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                      color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
                  title: Text("????????? ??????", style: TextStyle(color: (theme ? const Color(0xffe8e8e8) : Colors.black))),
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
                            const Text("?????? ??????????????? ????????????",
                                style: TextStyle(fontSize: 20)),
                            Text("$nickname", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
                            const Text("?????????.", style: TextStyle(fontSize: 20)),
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
                                  child: Text("??? ?????????", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                        nick = text as String; //????????? ????????? ?????? ??? ?????? ??? ?????? ??????????????? ??????
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
                              displayDialog_checkonly(context, "????????? ?????? ??????", "?????? ????????? ??????????????????.");
                              setState(() {
                                checkNickduplicate = true;
                              });
                            } else if (res == 1) {
                              displayDialog_checkonly(context, "????????? ?????? ??????", "???????????? ?????????????????????.");
                              setState(() {
                                checkNickduplicate = false;
                              });
                            } else if (res == 2) {
                              displayDialog_checkonly(context, "????????? ?????? ??????", "???????????? 20????????? ?????? ??? ????????????.");
                              setState(() {
                                checkNickduplicate = false;
                              });
                            } else {
                              displayDialog_checkonly(context, "????????? ?????? ??????", "?????? ???????????? ?????? ???????????? ????????? ??? ????????????.");
                              setState(() {
                                checkNickduplicate = false;
                              });
                            }
                          },
                          child: const Text("????????????"),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: Colors.deepPurpleAccent, // ?????? ?????? ??????
                          ),
                        ),
                      ),
                    ])
                    )
                ),
                bottomNavigationBar: Container(
                  padding : EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, height * 0.01),
                  child: ElevatedButton(
                    child: const Text("????????? ??????"),
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.5)),
                        minimumSize: Size.fromHeight(height * 0.062),
                        primary: Color(0xffEE3D43)
                    ),
                    onPressed: () {
                      if (checkNickduplicate == true) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("????????? ??????"),
                            content: const Text("???????????? ??????????????? ?????? ?????????????????????????"),
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
                                    displayDialog_changeIndividual(context, "????????? ?????? ??????", "???????????? ??????????????? ?????????????????????.");
                                  } else {
                                    displayDialog_checkonly_directNN(context, "????????? ?????? ??????", "????????? ????????? ????????? ????????? ??????????????????.\n?????? ?????????????????????.");
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        displayDialog_checkonly(context, "????????? ?????? ??????", "??????????????? ?????? ???????????? ????????????.");
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
