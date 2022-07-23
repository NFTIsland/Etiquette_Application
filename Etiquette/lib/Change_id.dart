import 'package:flutter/material.dart';

class ChangeID extends StatefulWidget {
  State createState() => _ChangeID();
}

class _ChangeID extends State<ChangeID> {
  Color act = Colors.grey;
  String name = "Guest1";
  String nick = "";
  late  bool chk = false;
  final _formkey_nick = GlobalKey<FormState>();
  final changeNick = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changeNick.text = name;
  }

  void acti(){
    _formkey_nick.currentState!.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("아이디 변경", style : TextStyle(fontWeight: FontWeight.bold)),
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
                child: Text("저장", style: TextStyle(color: act, fontSize: 20)),
                onPressed: () {
                  chk ? acti() : null;
                },
                style : TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory
                )
              //splashColor: Colors.transparent,
              //highlightColor: Colors.transparent,
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(height: 20),
          Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Text("현재 아이디는 ", style: TextStyle(fontSize: 20)),
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text("입니다.", style: TextStyle(fontSize: 20)),
            ]),
            SizedBox(height: 20),
            Text("아래에 새로운 아이디를 입력하세요.", style: TextStyle(fontSize: 17)),
            SizedBox(height: 10),
          ]),
          Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formkey_nick,
                      child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.text,
                          controller: changeNick,
                          //기본으로 자판 모양의 키보드 호출되도록 설정
                          decoration: InputDecoration(
                              //icon: const Text("ID:"),
                              //labelText: "ID", //입력칸에 ID 표시되도록
                              border: OutlineInputBorder()),
                          onSaved: (text) {
                            setState(() {
                              nick = text as String; //텍스트 필드가 변할 때 마다 그 값을 저장하도록 설정
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter NickName";
                            }
                              return null;

                          },
                      onChanged: (text){
                            if(_formkey_nick.currentState!.validate()){
                              setState(() {
                                chk = true;
                                act = Colors.black;
                              });
                            }
                            else{
                              setState(() {
                                chk = false;
                                act = Colors.grey;
                              });
                            }
                      },
                      ),
                    ),
                  ]))
        ])));
  }
}
