import 'package:flutter/material.dart';
import 'Wallet.dart';
import 'Bid.dart';
import 'Interest.dart';
import 'Selling.dart';
import 'Hold.dart';
import 'Used.dart';
import 'Search.dart';
import 'SellTicket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Market extends StatefulWidget{
  State createState() =>_Market();
}

class _Market extends State<Market>{
  bool ala = true;
  late bool theme;
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
    getTheme();
  }
  getTheme() async{
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }
  Widget build(BuildContext context){
    return FutureBuilder(
      future : getTheme(),
      builder : (context, snapshot){
        if(snapshot.hasError){
          return Center(
            child:Text('Error'),
          );
        }
        if(snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text("Auction"),
                backgroundColor: Colors.white24,
                //Appbar title이 화면 마다 달라서 각자 이름만 다른 appbar 설정
                foregroundColor: Colors.black,
                elevation: 0,
                //떠있는 느낌 삭제
                actions: <Widget>[
                  Container(
                      child: IconButton(
                        icon: img,
                        onPressed: () {
                          if (ala == true) {
                            ala = false;
                            setState(() {
                              img = Icon(Icons.notifications_none);
                            });
                            _setData(ala);
                          }
                          else {
                            ala = true;
                            setState(() {
                              img = Icon(Icons.notifications);
                            });
                            _setData(ala);
                          }
                        },
                      )),
                  IconButton( //검색 버튼
                    icon: Icon(Icons.search,),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Search()));
                    },
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
                  accountName: Text(
                    'guest1', style: TextStyle(color: Colors.black),),
                  accountEmail: Text(
                    'a1234@naver.com', style: TextStyle(color: Colors.black),),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                  ),
                ),
                ListTile(
                  title: Text('Wallet'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Wallet())); // 네비게이션 필요
                  },
                  //trailing: Icon(Icons.add),
                ),
                ListTile(
                  title: Text('List of holding tickets'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Hold())); // 네비게이션 필요
                  },
                  //trailing: Icon(Icons.add),
                ),
                ListTile(
                  title: Text('Interest Tickets'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Interest()));
                  },
                  //trailing: Icon(Icons.add),
                ),
                ListTile(
                  title: Text('Bid Tickets'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Bid()));
                  },
                  //trailing: Icon(Icons.add),
                ),
                ListTile(
                  title: Text('Selling Tickets'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Selling()));
                  },
                  //trailing: Icon(Icons.add),
                ),
                ListTile(
                  title: Text('List of used tickets'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Used()));
                  },
                  //trailing: Icon(Icons.add),
                ),
              ]),
            ),
            body: SingleChildScrollView(
            child :   Column(
                        children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 18), //좌측 여백 설정
                                    width : double.infinity,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Column( //Best Selling Tickets을 위한 공간
                                              children: <Widget>[
                                                SizedBox(height: 30),
                                                Text("Best Selling Tickets",
                                                    style: TextStyle(fontSize: 20,
                                                        fontWeight: FontWeight.bold)),
                                                SizedBox(height: 300),
                                                // 내용이 없어서 적당히 공간 설정
                                              ]
                                          ),
                                          Column( //Deadline Imminent를 위한 공간 설정
                                              children: <Widget>[
                                                Text("Deadline Imminent",
                                                    style: TextStyle(fontSize: 20,
                                                        fontWeight: FontWeight.bold)),
                                                SizedBox(height: 300),
                                                // 내용이 업성서 적당히 공간 설정
                                              ]
                                          ),
                                          Column( //Ranking을 위한 공간 설정
                                              children: <Widget>[
                                                Text("Ranking", style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold)),
                                                SizedBox(height: 300),
                                                // 내용이 업성서 적당히 공간 설정
                                              ]
                                          ),
                                        ]
                                    ),

                          ),
                        ]
                      )
                    ),
                    floatingActionButton: FloatingActionButton.extended(
                      onPressed: () {
                        print("Floating Action Test");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SellTicket()));
                      },
                      backgroundColor: (theme ? const Color(0xffe8e8e8) : const Color(
                          0xffffdddd)),
                      label: const Text("티켓 판매"),
                      icon: const Icon(Icons.add_card),
                    ),
          );
        }
        return Center(
          child : CircularProgressIndicator(),
        );
      }
    );
  }
}