import 'package:flutter/material.dart';
import 'Login.dart';
import 'Register.dart';
import 'TabController.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  Widget build(BuildContext context){
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title : 'Etiquette',//앱 이름 etiquette으로 설정
        home : Login()// 최초 페이지로 Login()실행
    );
  }
}
