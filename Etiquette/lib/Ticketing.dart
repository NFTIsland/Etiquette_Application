import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Account.dart';
import 'Bid.dart';
import 'Hold.dart';
import 'Interest.dart';
import 'Search.dart';
import 'Selling.dart';
import 'Used.dart';
import 'Wallet.dart';

class Ticketing extends StatefulWidget {
  State createState() => _Ticketing();
}

class _Ticketing extends State<Ticketing> {
  bool ala = true;
  late bool theme;
  var img = Icon(Icons.notifications);
  List? high;
  Map<String, dynamic> ex1 = {
    'name': '티켓1',
    'category': '영화',
    'price': 16000,
    'img':
        'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex2 = {
    'name': '티켓2',
    'category': '콘서트',
    'price': 150000,
    'img':
        'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex3 = {
    'name': '티켓3',
    'category': '스포츠',
    'price': 66000,
    'img':
        'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex4 = {
    'name': '티켓4',
    'category': '뮤지컬',
    'price': 130000,
    'img':
        'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };
  Map<String, dynamic> ex5 = {
    'name': '티켓5',
    'category': '공연',
    'price': 100000,
    'img':
        'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg'
  };

  void _setData(bool value) async {
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  void _loadData() async {
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      var value = pref.getBool(key);
      if (value != null) {
        ala = value;
        if (ala == true) {
          img = Icon(Icons.notifications);
        } else {
          img = Icon(Icons.notifications_none);
        }
      }
    });
  }

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  void initState() {
    super.initState();
    _loadData();
    getTheme();
    high = new List.empty(growable: true);
    high!.add(ex1);
    high!.add(ex2);
    high!.add(ex3);
    high!.add(ex4);
    high!.add(ex5);
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTheme(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                    title: Text("Ticketing"),
                    backgroundColor: Colors.white24,
                    //티켓팅이 title인 appbar 생성
                    foregroundColor: Colors.black,
                    elevation: 0,
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
                          } else {
                            ala = true;
                            setState(() {
                              img = Icon(Icons.notifications);
                            });
                            _setData(ala);
                          }
                        },
                      )),
                      IconButton(
                        icon: Icon(
                          Icons.search,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Search()));
                        },
                      )
                    ]),
                // 왼쪽 위 부가 메뉴버튼을 단순 ListView에서 Drawer 사용하여 슬라이드로
                drawer: SafeArea(
                  child: Drawer(
                    child: ListView(children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Account()));
                        },
                        child: UserAccountsDrawerHeader(
                          currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.white24,
                            backgroundImage:
                                AssetImage('assets/image/mainlogo.png'),
                          ),
                          accountName: Text(
                            'guest1',
                            style: TextStyle(color: Colors.black),
                          ),
                          accountEmail: Text(
                            'a1234@naver.com',
                            style: TextStyle(color: Colors.black),
                          ),
                          decoration: BoxDecoration(
                              color: (theme
                                  ? const Color(0xffe8e8e8)
                                  : const Color(0xff7b9acc)),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              )),
                        ),
                      ),
                      ListTile(
                        title: Text('Wallet'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Wallet())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('List of holding tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Hold())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('Interest Tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Interest())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('Bid Tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Bid())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('Selling Tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Selling())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text('List of used tickets'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Used())); // 네비게이션 필요
                        },
                        //trailing: Icon(Icons.add),
                      ),
                    ]),
                  ),
                ),
                body: Column(children: <Widget>[
                  Expanded(
                      //기억이 안남..
                      child: SingleChildScrollView(
                          //스크롤 되도록
                          child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(left: 18),
                              //좌측 여백 공간 설정
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  //왼쪽에 딱 붙도록 설정
                                  children: <Widget>[
                                    Column(children: <Widget>[
                                      SizedBox(height: 15),
                                      Text("Hot Pick",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      //SizedBox(height : 300),//아직 내용이 없어서 대충 공간 설정
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: high!.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                                child: Container(
                                                    width: double.infinity,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child:
                                                                Image.network(
                                                                    high![index]
                                                                        ['img'],
                                                                    width: 50,
                                                                    height: 50),
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                Text(high![
                                                                        index]
                                                                    ['name']),
                                                                Text(high![
                                                                        index][
                                                                    'category']),
                                                                Text(high![index]
                                                                        [
                                                                        'price']
                                                                    .toString()),
                                                              ]))
                                                        ])));
                                          }),
                                    ]),
                                    Column(children: <Widget>[
                                      Text("Deadline Imminent",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      //SizedBox(height : 300),//아직 내용이 없어서 대충 공간 설정
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: high!.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                                child: Container(
                                                    width: double.infinity,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child:
                                                                Image.network(
                                                                    high![index]
                                                                        ['img'],
                                                                    width: 50,
                                                                    height: 50),
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                Text(high![
                                                                        index]
                                                                    ['name']),
                                                                Text(high![
                                                                        index][
                                                                    'category']),
                                                                Text(high![index]
                                                                        [
                                                                        'price']
                                                                    .toString()),
                                                              ]))
                                                        ])));
                                          }),
                                    ]),
                                    Column(children: <Widget>[
                                      Text("Ranking",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      //SizedBox(height : 300),//아직 내용이 없어서 대충 공간 설정
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: high!.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                                child: Container(
                                                    width: double.infinity,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child:
                                                                Image.network(
                                                                    high![index]
                                                                        ['img'],
                                                                    width: 50,
                                                                    height: 50),
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                Text(high![
                                                                        index]
                                                                    ['name']),
                                                                Text(high![
                                                                        index][
                                                                    'category']),
                                                                Text(high![index]
                                                                        [
                                                                        'price']
                                                                    .toString()),
                                                              ]))
                                                        ])));
                                          }),
                                    ])
                                  ])))),
                ]));
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
