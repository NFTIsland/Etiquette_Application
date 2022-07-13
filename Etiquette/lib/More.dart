import 'dart:ui';
import 'package:flutter/material.dart';
import 'Wallet.dart';
import 'Bid.dart';
import 'Interest.dart';
import 'Selling.dart';
import 'Hold.dart';
import 'Used.dart';
import 'Setting.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class More extends StatefulWidget{//More에서 구현할 화면
  State createState() =>_More();
}

class _More extends State<More>{
  List <String> Option = ['Application Guide', 'Notice', '1:1 Customer Service', 'FAQ', 'Setting'];
  bool ala = true;
  var img = Icon(Icons.notifications);

  void _setData(bool value) async{
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }
  void _loadData() async{
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState((){
      var value = pref.getBool(key);
      if(value != null){
        ala = value;
        if(ala == true){
          img = Icon(Icons.notifications);
        }
        else{
          img = Icon(Icons.notifications_none);
        }
      }
    });
  }

  void initState(){
    super.initState();
    _loadData();
  }

  Widget build(BuildContext context){
    return Scaffold(
        appBar : AppBar(title : Text("More"), backgroundColor : Colors.white24, foregroundColor: Colors.black, elevation : 0,
          actions: <Widget>[
            Container(
                child : IconButton(
                  icon: img,
                  onPressed: () {
                    if(ala == true){
                      ala = false;
                      setState(() {
                        img = Icon(Icons.notifications_none);
                      });
                      _setData(ala);
                    }
                    else{
                      ala = true;
                      setState(() {
                        img = Icon(Icons.notifications);
                      });
                      _setData(ala);
                    }
                  },
                )),
           IconButton(icon : Icon(Icons.search), onPressed : (){Navigator.push(context, MaterialPageRoute(builder : (context) => Search()));})
         ],
        ),
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
                Navigator.push(context, MaterialPageRoute(builder : (context) => Interest())); // 네비게이션 필요
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('Bid Tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Bid())); // 네비게이션 필요
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('Selling Tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Selling())); // 네비게이션 필요
              },
              //trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('List of used tickets'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder : (context) => Used())); // 네비게이션 필요
              },
              //trailing: Icon(Icons.add),
            ),
          ]),
        ),
        body : ListView(
            padding : EdgeInsets.only(left : 10),
            children : <Widget>[

              ListTile(
                  title : Text("Application Guide", style : TextStyle(fontSize: 20)),
                  onTap : (){

                  }
              ),
              ListTile(
                  title : Text("Notice", style : TextStyle(fontSize: 20)),
                  onTap : (){

                  }
              ),
              ListTile(
                  title : Text("1:1 Customer Service", style : TextStyle(fontSize: 20)),
                  onTap : (){

                  }
              ),
              ListTile(
                  title : Text("FAQ", style : TextStyle(fontSize: 20)),
                  onTap : (){

                  }
              ),
              ListTile(
                  title : Text("Setting", style : TextStyle(fontSize: 20)),
                  onTap : (){
                    Navigator.push(context, MaterialPageRoute(builder : (context) => Setting()));
                  }
              ),
            ]
        )
    );
  }
}