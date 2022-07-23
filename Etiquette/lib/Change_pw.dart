import 'package:flutter/material.dart';

class ChangePW extends StatefulWidget {
  State createState() => _ChangePW();
}

class _ChangePW extends State<ChangePW> {
  Color act = Colors.grey;
  Color pwc = Colors.grey.shade200;
  Color chc = Colors.grey.shade200;
  Color rec = Colors.grey.shade200;
  late bool chk = false;
  bool cuch = false;
  bool chch = false;
  bool rech = false;
  String chpw = "";
  String repw = "";
  final _formkey_cur = GlobalKey<FormState>();
  final _formkey_cha = GlobalKey<FormState>();
  final _formkey_re = GlobalKey<FormState>();
  final cha = TextEditingController();
  final re = TextEditingController();
  FocusNode _pwtextFieldFocus = FocusNode();
  FocusNode _chtextFieldFocus = FocusNode();
  FocusNode _retextFieldFocus = FocusNode();

  void acti() {
    _formkey_cha.currentState!.save();
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("비밀번호 변경",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              elevation: 0,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white24,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                TextButton(
                    child:
                        Text("완료", style: TextStyle(color: act, fontSize: 20)),
                    onPressed: () {
                      chk ? acti() : null;
                    },
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory)
                    //splashColor: Colors.transparent,
                    //highlightColor: Colors.transparent,
                    )
              ],
            ),
            body: SingleChildScrollView(
                child: Column(children: <Widget>[
              SizedBox(height: 20),
              Column(children: <Widget>[
                Text("현재 비밀번호 ",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("현재 비밀번호",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10,
                          ),
                          Form(
                            key: _formkey_cur,
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.text,
                              //기본으로 자판 모양의 키보드 호출되도록 설정
                              decoration: InputDecoration(
                                //icon: const Text("ID:"),
                                //labelText: "ID", //입력칸에 ID 표시되도록
                                filled: true,
                                fillColor: pwc,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                      width: 0,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        width: 2, color: Color(0xffFFB877))),
                              ),
                              focusNode: _pwtextFieldFocus,
                              onSaved: (text) {
                                setState(() {
                                  chpw = text
                                      as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
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
                                  setState(() {
                                    cuch = true;
                                    if (chch == true && rech == true) {
                                      chk = true;
                                      act = Colors.black;
                                    }
                                  });
                                } else {
                                  setState(() {
                                    cuch = false;
                                    chk = false;
                                    act = Colors.grey;
                                  });
                                }
                              },
                            ),
                          ),
                        ])),
              ]),
              Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("새 비밀번호",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 10,
                        ),
                        Form(
                          key: _formkey_cha,
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.text,
                            controller: cha,
                            //기본으로 자판 모양의 키보드 호출되도록 설정
                            decoration: InputDecoration(
                              //icon: const Text("ID:"),
                              //labelText: "ID", //입력칸에 ID 표시되도록
                              filled: true,
                              fillColor: chc,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    width: 0,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffFFB877))),
                            ),
                            focusNode: _chtextFieldFocus,
                            onSaved: (text) {
                              setState(() {
                                repw = text
                                    as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter Password for change";
                              }
                              return null;
                            },
                            onChanged: (text) {
                              if (_formkey_cha.currentState!.validate() &&
                                  _formkey_re.currentState!.validate()) {
                                setState(() {
                                  chch = true;
                                  rech = true;
                                  if (cuch == true && rech == true) {
                                    chk = true;
                                    act = Colors.black;
                                  }
                                });
                              } else {
                                setState(() {
                                  chch = false;
                                  chk = false;
                                  act = Colors.grey;
                                });
                              }
                            },
                          ),
                        ),
                      ])),
              Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("새 비밀번호 확인",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 10,
                        ),
                        Form(
                          key: _formkey_re,
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.text,
                            controller: re,
                            //기본으로 자판 모양의 키보드 호출되도록 설정
                            decoration: InputDecoration(
                              //icon: const Text("ID:"),
                              //labelText: "ID", //입력칸에 ID 표시되도록
                              filled: true,
                              fillColor: rec,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    width: 0,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffFFB877))),
                            ),
                            focusNode: _retextFieldFocus,
                            onSaved: (text) {
                              setState(() {
                                repw = text
                                    as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter PW for check";
                              }
                              if (cha.text != re.text) {
                                return "비밀번호가 일치하지 않습니다.";
                              }
                              return null;
                            },
                            onChanged: (text) {
                              if (_formkey_re.currentState!.validate() &&
                                  _formkey_cha.currentState!.validate()) {
                                setState(() {
                                  rech = true;
                                  chch = true;
                                  if (cuch == true && chch == true) {
                                    chk = true;
                                    act = Colors.black;
                                  }
                                });
                              } else {
                                setState(() {
                                  rech = false;
                                  chk = false;
                                  act = Colors.grey;
                                });
                              }
                            },
                          ),
                        ),
                      ]))
            ]))));
  }
}
