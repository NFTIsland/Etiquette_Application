import 'dart:ui';
import 'package:flutter/material.dart';
import 'Wallet.dart';
import 'Bid.dart';
import 'Interest.dart';
import 'Selling.dart';
import 'Hold.dart';
import 'Used.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  State createState() => _Home();
}

class _Home extends State<Home> {
  bool ala = true;
  var img = Icon(Icons.notifications);
  List? high;
  Map<String, dynamic> ex1 = {
    'name' : '티켓1',
    'category' : '영화',
    'price' : 16000,
    'img' : 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex2 = {
    'name' : '티켓2',
    'category' : '콘서트',
    'price' : 150000,
    'img' : 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex3 = {
    'name' : '티켓3',
    'category' : '스포츠',
    'price' : 66000,
    'img' : 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex4 = {
    'name' : '티켓4',
    'category' : '뮤지컬',
    'price' : 130000,
    'img' : 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex5 = {
    'name' : '티켓5',
    'category' : '공연',
    'price' : 100000,
    'img' : 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
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
    high = new List.empty(growable : true);
    high!.add(ex1);
    high!.add(ex2);
    high!.add(ex3);
    high!.add(ex4);
    high!.add(ex5);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Etiquette"),
            backgroundColor: Colors.white24,
            foregroundColor: Colors.black,
            elevation: 0,
            //elevation은 떠보이는 느낌 설정하는 것, 0이면 뜨는 느낌 없음, foreground는 글자 색 변경
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
        body: SingleChildScrollView(
                  //만약 화면에 다 표현할 수 없으면 스크롤 할 수 있게 설정
                  child:Container(
                  width : double.infinity,
                      child: Column(//세로로 배치
                          children: <Widget>[
                            SizedBox(height : 30),
            Column(//Ticekts with high bidders를 위한 공간
                children: <Widget>[
              Text("Ticekts with high bidders",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              //글자 강조 설정
              //SizedBox(height: 300),
              //아직 뭘 가져올 수가 없어서 그냥 300정도의 공간 설정
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: high!.length,
                    itemBuilder:(context, index){
                      return Card(
                          child : Container(
                              width : double.infinity,
                              child : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children : <Widget>[
                                Expanded(child:
                                Image.network(high![index]['img'],width : 50, height : 50),
                                ),
                                Expanded(child:
                                Column(
                                  children : <Widget>[
                                    Text(high![index]['name']),
                                    Text(high![index]['category']),
                                    Text(high![index]['price'].toString()),
                                  ]
                                )
                                )
                              ]
                            )
                          )
                      );
                    }
                  )
            ,
            //Deadline Imminent를 위한 공간

              Text("Deadline Imminent",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              //글자 강조 설정
              //SizedBox(height: 300),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: high!.length,
                      itemBuilder:(context, index){
                        return Card(
                            child : Container(
                                width : double.infinity,
                                child : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children : <Widget>[
                                      Expanded(child:
                                      Image.network(high![index]['img'],width : 50, height : 50),
                                      ),
                                      Expanded(child:
                                      Column(
                                          children : <Widget>[
                                            Text(high![index]['name']),
                                            Text(high![index]['category']),
                                            Text(high![index]['price'].toString()),
                                          ]
                                      )
                                      )
                                    ]
                                )
                            )
                        );
                      }
                  ),
            ]  //아직 뭘 가져올 수가 없어서 그냥 300정도의 공간 설정
            )
          ]
                      )
                  )
        )
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
        );
  }
}
