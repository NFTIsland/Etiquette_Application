import 'dart:convert';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Utilities/jwt_decode.dart';
import 'package:Etiquette/Screens/Drawer/Change_pw.dart';

class checkcurPW extends StatefulWidget {
  State createState() => _checkcurPW();
}

class _checkcurPW extends State<checkcurPW> {
  Color pwc = Colors.grey.shade200;
  bool check = false;
  String curpw = "";
  final _formkey_cur = GlobalKey<FormState>();
  final cur = TextEditingController();
  FocusNode _pwtextFieldFocus = FocusNode();
  String? id = "";
  String? nickname = "";

  Future<void> getInfo() async {
    id = await jwtDecode();
    nickname = await storage.read(key: "nickname");
  }

  Future<bool> check_curPW(String id, String pw) async{
    try {
      const url = "$SERVER_IP/auth/checkPassword";
      final res = await http.post(Uri.parse(url), body: {
        "id": id,
        "pw": pw
      });
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200){
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
    getInfo();
    _pwtextFieldFocus.addListener(() {
      if (_pwtextFieldFocus.hasFocus) {
        setState(() {
          pwc = Colors.white24;
        });
      } else {
        setState(() {
          pwc = Colors.grey.shade200;
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
              title: const Text("비밀번호 변경",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              elevation: 0,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white24,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            body: SingleChildScrollView(
                child: Column(children: <Widget>[
                  const SizedBox(height: 20),
                  Column(children: <Widget>[
                    const Text("현재 비밀번호 ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Center(
                                child: Text("인증을 위하여 현재 비밀번호를 다시 한번 입력해주세요.",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 10),
                              Form(
                                key: _formkey_cur,
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  controller: cur, //기본으로 자판 모양의 키보드 호출되도록 설정
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: pwc,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(width: 0,)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                            width: 2, color: Color(0xffFFB877))),
                                  ),
                                  focusNode: _pwtextFieldFocus,
                                  onSaved: (text) {
                                    setState(() {
                                      curpw = text as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter Current Password";
                                    }
                                    return null;
                                  },
                                  onChanged: (text) {
                                    if (_formkey_cur.currentState!.validate()) {
                                      setState((){
                                        check = true;
                                      });
                                    } else {
                                      setState(() {
                                        check = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ])
                    ),
                            ])
                ])
            ),
                    bottomNavigationBar: Container(
                      padding : EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, height * 0.01),
                      child: ElevatedButton(
                        child: const Text("다음"),
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.5)),
                            minimumSize: Size.fromHeight(height * 0.062),
                            primary: Color(0xffEE3D43)
                        ),
                        onPressed: () async {
                          if (check == true){
                            if (await check_curPW(id!, cur.value.text) == true){
                              Get.to(() => ChangePW(),);
                            }
                            else{
                              displayDialog_checkonly(context, "비밀번호 오류", "비밀번호를 잘못 입력하셨습니다.\n다시 시도해주십시오.");
                            }
                          }
                          else{
                            displayDialog_checkonly(context, "비밀번호 오류", "비밀번호를 입력해주십시오.");
                          }
                          },
                      ),
                    )
        )
    );
  }
}
