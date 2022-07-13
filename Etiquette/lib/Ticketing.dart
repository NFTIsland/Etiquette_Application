import 'package:flutter/material.dart';
import 'Wallet.dart';
import 'Bid.dart';
import 'Interest.dart';
import 'Selling.dart';
import 'Hold.dart';
import 'Used.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ticketing extends StatefulWidget{
  State createState() =>_Ticketing();
}

class _Ticketing extends State<Ticketing>{
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
        appBar : AppBar(title : Text("Ticketing"), backgroundColor: Colors.white24,//티켓팅이 title인 appbar 생성
            foregroundColor: Colors.black, elevation: 0,
            actions : <Widget>[
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
              IconButton(
                icon : Icon(Icons.search,),
                onPressed: (){Navigator.push(context, MaterialPageRoute(builder : (context) => Search()));},
              )
            ]
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
        body : Column(
            children : <Widget>[
              Expanded(//기억이 안남..
                  child: SingleChildScrollView(//스크롤 되도록
                      child :Container(
                          padding : EdgeInsets.only(left : 18),//좌측 여백 공간 설정
                          child : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,//왼쪽에 딱 붙도록 설정
                          children : <Widget>[
                            Column(
                                children : <Widget>[
                                  Text("Hot Pick", style : TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height : 300),//아직 내용이 없어서 대충 공간 설정
                                ]
                            ),
                            Column(
                                children : <Widget>[
                                  Text("Deadline Imminent", style : TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height : 300),//아직 내용이 없어서 대충 공간 설정
                                ]
                            ),
                            Column(
                                children : <Widget>[
                                  Text("Ranking", style : TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height : 300),//아직 내용이 없어서 대충 공간 설정
                                ]
                            )
                          ]
                      )
                    )
                  )
              ),

            ]
        )
    );
  }
}