import 'dart:ui';

import 'package:flutter/material.dart';
import 'Login.dart';

class Register extends StatefulWidget{//회원가입 화면
  const Register({Key? key}) : super(key: key);

  State<StatefulWidget> createState()=>_Register();
}

class _Register extends State<Register>{
   final _formkey_ph = GlobalKey<FormState>();
   final _formkey_au = GlobalKey<FormState>();
   final _formkey_pw = GlobalKey<FormState>();
   final _formkey_repw = GlobalKey<FormState>();
   final _formkey_name = GlobalKey<FormState>();
   final idController = TextEditingController();
   final pwController = TextEditingController();
   final repwController = TextEditingController();
   String id = "";//입력한 아이디 받는 변수
   String pw = "";//입력한 패스워드 받는 변수
   String id_auth = "";//id 인증 번호 받는 변수
   String pw_auth  = "";//똑같은 비밀번호 입력했는지 확인하기 위한 변수
   String name = "";//이름

    Widget build(BuildContext context){
      return GestureDetector(
            onTap :() {FocusScope.of(context).unfocus();},//다른 곳 클릭하면 키보드 사라지도록 설정
          child :Scaffold(
              appBar : AppBar(centerTitle: true, elevation : 0, backgroundColor: Colors.white24,//Appbar 설정, 글씨는 검정으로 설정
                foregroundColor: Colors.black,),
              body: Center(//가운데 배치
                  child : SingleChildScrollView(//스크롤 가능하도록 설정 만약 키보드가 나와서 화면이 길어질 떄 필요함
                    child :Column(//각종 입력 받을 텍스트 필드를 담을 공간
                    children:<Widget>[
                     Padding(
                       padding : EdgeInsets.only(left : 80),//좌측 여백 설정
                     child :Row//가로로 글자 배치
                     (children : <Widget>[Text("Sign up",style : TextStyle(fontSize : 30)), Text("/Login",style : TextStyle(fontSize : 20, color : Colors.grey,),)])
                     )
                     ,
                     Column(
                        children : <Widget>[
                          SizedBox(height : 30),
                          Padding(
                            padding : EdgeInsets.fromLTRB(80, 0, 80, 0),
                              child : Row(
                                children : <Widget>[
                                  Flexible(
                                    child :Form(
                                            key : _formkey_ph,
                                            child : TextFormField(
                                              controller: idController,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              keyboardType: TextInputType.text,//기본으로 자판 모양의 키보드가 호출되도록 설정
                                              decoration: InputDecoration(
                                              //icon: const Text("ID:"),
                                              labelText : "HP(ID)",//id 입력하는 공간
                                              //border : OutlineInputBorder()
                                              ),
                                                onSaved : (text){setState((){id = text as String; idController.text = text;});},//바뀔 때마다 id를 입력되어 있는 값으로 변경
                                                validator: (value){
                                                    if(value == null || value.isEmpty){
                                                    return "Please enter HP";
                                                    }
                                                    return null;
                                                },
                                              )
                                          )
                                  ),
                                  Container(
                                    padding : EdgeInsets.only(left : 10),//텍스트 필드와 약간의 여백 생성
                                    child :
                                  ElevatedButton(onPressed: (){
                                    if(_formkey_ph.currentState!.validate()){
                                      _formkey_ph.currentState!.save();

                                    }
                                  },//인증받기 위해 누르는 버튼, 아직 기능 구현 안함
                                  child : Text("인증"),
                                  style : ElevatedButton.styleFrom(
                                      primary : Colors.deepPurpleAccent//버튼 색깔 설정
                                  )),
                                  )
                            ]
                              )
                          ),
                          Padding(//인증번호를 위한 공간
                              padding : EdgeInsets.fromLTRB(80, 20, 80, 0), //ID 입력 칸과 여백 및, 좌우 공간 여백 설정
                              child : Row(
                                  children : <Widget>[
                                    Flexible(
                                        child :Form(
                                            key : _formkey_au,
                                            child : TextFormField(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                keyboardType: TextInputType.number,//기본으로 숫자 모양의 키보드가 호출되도록 설정
                                                decoration: InputDecoration(
                                              //icon: const Text("ID:"),
                                                labelText : "인증번호",//인증번호 입력하는 공간
                                                //border : OutlineInputBorder()
                                                ),
                                                onSaved : (text){setState(() {//바뀔때마다 저장
                                                id_auth = text as String;
                                                });},
                                                validator: (value){
                                                  if(value == null || value.isEmpty){
                                                    return "Please enter AUTH";
                                                  }
                                                  return null;
                                                },
                                                )
                                        )
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left : 10),//텍스트 필드와 약간의 여백 생성
                                      child :
                                      ElevatedButton(onPressed: (){
                                        if(_formkey_au.currentState!.validate()){
                                          _formkey_au.currentState!.save();
                                        }
                                      },//인증 확인 버튼, 아직 기능 구현 안함
                                          child : Text("확인"),//
                                          style : ElevatedButton.styleFrom(
                                          primary : Colors.deepPurpleAccent//버튼 색깔 설정
                                      )
                                      ),
                                    )
                                  ]
                              )
                          ),
                          Padding(
                              padding : EdgeInsets.fromLTRB(80, 20, 80, 0),//인증번호 입력 칸과 여백 및, 좌우 공간 여백 설정
                              child : Form(
                                key : _formkey_pw,
                                child : TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller : repwController,
                                    obscureText : true, keyboardType: TextInputType.text,//기본으로 자판 모양의 키보드가 호출되도록 설정, pw 안보이도록 가림
                                    decoration: InputDecoration(
                                        //icon: const Text("PW:"),
                                        labelText : "Password",//PW 입력하는 공간
                                        //border : OutlineInputBorder()
                                    ),
                                    onSaved : (text){setState(() {
                                      pw = text as String;//바뀔 때마다 저장
                                    });},
                                    validator: (value){
                                      if(value == null || value.isEmpty){
                                        return "Please enter PW";
                                      }
                                      return null;
                                    },
                                )
                              )
                          ),
                          Padding(
                              padding : EdgeInsets.fromLTRB(80, 20, 80, 0),//비밀번호 입력 칸과 여백 및, 좌우 공간 여백 설정
                              child :Form(
                                key : _formkey_repw,
                                child : TextFormField(
                                  controller : pwController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.text, obscureText: true,//기본으로 자판 모양의 키보드가 호출되도록 설정, pw 안보이도록 가림
                                  decoration: InputDecoration(
                                      //icon: const Text("재확인:"),
                                      labelText : "재확인",//PW 다시 입력하는 공간
                                      //border : OutlineInputBorder()
                                  ),
                                  onSaved : (text){setState(() {
                                    pw_auth = text as String;//바뀔 떄마다 저장
                                  });},
                                  validator: (value){
                                    if(value == null || value.isEmpty){
                                      return "Please enter PW for check";
                                    }
                                    if(pwController.text != repwController.text){
                                      return "비밀번호가 일치하지 않습니다!";
                                    }
                                    return null;
                                  },
                                )
                              )
                          ),
                          Padding(
                              padding : EdgeInsets.fromLTRB(80, 20, 80, 0),//재확인 입력 칸과 여백 및, 좌우 공간 여백 설정
                              child : Form(
                                key : _formkey_name,
                                child : TextFormField(
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          keyboardType: TextInputType.text,//기본으로 자판 모양의 키보드가 호출되도록 설정, pw 안보이도록 가림
                                          decoration: InputDecoration(
                                              //icon: const Text("이름:"),
                                              labelText : "Name",//이름 입력하는 공간
                                              //border : OutlineInputBorder()
                                          ),
                                          onSaved: (text){setState(() {
                                            name = text as String;//바뀔 떄마다 저장
                                          });},
                                          validator: (value){
                                            if(value == null || value.isEmpty){
                                              return "Please enter Name";
                                            }
                                            return null;
                                          },
                                        )
                                      )
                          ),
                          Padding(
                              padding : EdgeInsets.fromLTRB(0, 20, 0, 0),//이름 입력 칸과 여백 및, 좌우 공간 여백 설정 버튼은 필요한 만큼만 쓰기 때문에 좌우 여백 지정할 필요 없음
                              child :
                              Column(
                                  children : <Widget> [
                                    ElevatedButton(onPressed : (){},child : const Text("Klaytn Linkage"), style : ElevatedButton.styleFrom(primary: Colors.red,//클레이튼 연동 버튼, 버튼 색깔 설정 및 둥글게 설정
                                    shape: RoundedRectangleBorder(	borderRadius: BorderRadius.circular(12)),)),
                                    ElevatedButton(onPressed : (){
                                      if(_formkey_ph.currentState!.validate() && _formkey_au.currentState!.validate() && _formkey_pw.currentState!.validate() && _formkey_repw.currentState!.validate() && _formkey_name.currentState!.validate()){
                                            _formkey_ph.currentState!.save();
                                            _formkey_name.currentState!.save();
                                            Navigator.push(
                                            //눌렸을 떄 Register 클래스 실행되도록 -> Register 창 실행되도록 설정
                                            context,
                                            MaterialPageRoute(
                                            builder: (context) => Login()));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("가입처리 완료되었습니다."),),
                                            );
                                      }
                                    },child : const Text("가입"), style : ElevatedButton.styleFrom(primary : Colors.purpleAccent.shade100, shape: RoundedRectangleBorder(	borderRadius: BorderRadius.circular(12))),)])
                                    //가입 버튼, 버튼 색깔 설정 및 둥글게 설정
                          )
                        ]
                      )
                  ])
                  )
                  )
                )
              );
    }
}