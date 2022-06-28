import 'dart:ui';
import 'package:flutter/material.dart';
import 'Wallet.dart';
import 'Bid.dart';
import 'Interest.dart';
import 'Selling.dart';
import 'Hold.dart';
import 'Used.dart';
import 'Search.dart';
class Home extends StatefulWidget {
  State createState() => _Home();
}

class _Home extends State<Home> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Etiquette"),
            backgroundColor: Colors.white24,
            foregroundColor: Colors.black,
            elevation: 0,
            //elevation은 떠보이는 느낌 설정하는 것, 0이면 뜨는 느낌 없음, foreground는 글자 색 변경
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder : (context) => Search()));
                },
              )
            ]),
        // 왼쪽 위 부가 메뉴버튼을 단순 ListView에서 Drawer 사용하여 슬라이드로
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.all(10), children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white24,
                backgroundImage: AssetImage('assets/image/mainlogo.png'),
              ),
              accountName: Text('guest1', style: TextStyle(color: Colors.black),),
              accountEmail: Text('a1234@naver.com', style: TextStyle(color: Colors.black),),
              decoration: BoxDecoration(
                color: Colors.white24,
                ),
              ),
            ListTile(
              title: Text('Wallet'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Wallet())); // 네비게이션 필요
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('List of holding tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Hold())); // 네비게이션 필요
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('Interest Tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Interest()));
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('Bid Tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Bid()));
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('Selling Tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Selling()));
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('List of used tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Used()));
              },
              //trailing: Icon(Icons.add),
            ),
          ]),
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
                  //만약 화면에 다 표현할 수 없으면 스크롤 할 수 있게 설정
                  child: Center(
                      child: Column(//세로로 배치
                          children: <Widget>[
            Column(//Ticekts with high bidders를 위한 공간
                children: <Widget>[
              Text("Ticekts with high bidders",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              //글자 강조 설정
              SizedBox(height: 300),
              //아직 뭘 가져올 수가 없어서 그냥 300정도의 공간 설정
            ]),
            Column(//Deadline Imminent를 위한 공간
                children: <Widget>[
              Text("Deadline Imminent",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              //글자 강조 설정
              SizedBox(height: 300),
              //아직 뭘 가져올 수가 없어서 그냥 300정도의 공간 설정
            ])
          ])))),
          /*
          Container(
              //버튼 만들 공간 근데 이렇게 하면 왠지 버튼 가로 축 라인을 다 차지할 거 같은 느낌이...?
              alignment: Alignment.bottomRight,
              //우측 하단에 배치되도록 설정
              padding: EdgeInsets.fromLTRB(0, 0, 10, 30),
              //너무 딱 달라붙지 않게 적절히 아래, 오른쪽 여백 설정
              child: ElevatedButton(
                  onPressed: () {}, //아직 구현 안함.
                  child: Text("Market"),
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xffFFB877),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      //적당히 둥글게 설정
                      minimumSize: Size(50, 40) //최소 크기 설정
                      ))),*/
        ]));
  }
}
