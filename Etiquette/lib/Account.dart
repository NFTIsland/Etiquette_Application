import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'Change_id.dart';
import 'package:image_picker/image_picker.dart';

import 'Change_pw.dart';
class Account extends StatefulWidget {
  State createState() => _Account();
}

class _Account extends State<Account> {
  late bool theme;
  var profile;
  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future : getTheme(),
      builder : (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        if(snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: AppBar(
                title: Text("계정 정보"),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white24,
                foregroundColor: Colors.black,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                            children: <Widget>[
                              Text("대표 이미지", style: TextStyle(fontSize: 15),),
                              Container(
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.4,
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: profile == null ? Image.asset(
                                    'assets/image/mainlogo.png',
                                    fit: BoxFit.fill,
                                  ) : Image.file(profile,),
                                ),
                              ),
                              ElevatedButton(onPressed: () async {
                                var picker  = ImagePicker();
                                var image = await picker.pickImage(source:ImageSource.gallery);//갤러리에서 고름
                                if(image != null) {//골랐으면
                                  setState(() {
                                    profile = File(image.path);//파일화해서 저장
                                  });
                                }
                              }, child: Text("대표 이미지 변경", style : TextStyle(color : (theme ? const Color(0xff000000) : const Color(0xffffffff)))),
                                  style: ElevatedButton.styleFrom(
                                      primary: (theme ? const Color(0xffe8e8e8) : const Color(0xffFFB877)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)) //둥글게 설정
                                  )),
                            ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children : <Widget>[
                            Padding(
                          padding : EdgeInsets.fromLTRB(15, 0, 0, 10),
                          child :   Text("정보"),
                        ),
                        ListTile(
                          title: Text("아이디", style : TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Guest1"),
                          onTap:(){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangeID()));
                          },
                        ),
                        ListTile(
                          title: Text("비밀번호", style : TextStyle(fontWeight: FontWeight.bold)),
                          //subtitle: Text("Guest1"),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangePW()));},
                        ),
                        ]
                        )
                      ]
                  )
              )

          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}
