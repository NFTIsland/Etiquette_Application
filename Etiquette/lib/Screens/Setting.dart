import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'TabController.dart';

class Setting extends StatefulWidget {
  State<StatefulWidget> createState() => _Setting();
}

class _Setting extends State<Setting> {
  bool ala = true;
  bool theme = false;

  void initState() {
    super.initState();
    getAlarm();
    getTheme();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: (theme ? const Color(0xffe8e8e8) : Colors.black)),
              title: Text("Setting", style : TextStyle(color: (theme ? const Color(0xffe8e8e8) : Colors.black))),
              backgroundColor: Colors.white24,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Get.off(Tabb(idx : 3));
                  /*
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Tabb(idx: 3)));
              */
                },
              ),
            ),
            body: Container(
                child: Column(children: <Widget>[
                  ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(left: 15),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("알람 수신", style: TextStyle(fontSize: 15)),
                          Switch(
                            value: ala,
                            onChanged: (value) {
                              setState(() {
                                ala = value;
                                setAlarm(value);
                                if(value == true){
                                  _getToken();
                                }
                                else{
                                  _delToken();
                                  print("Token 삭제");
                                }
                              });
                            },
                            activeColor: Color(0xffFFB877),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("다크 모드", style: TextStyle(fontSize: 15)),
                          Switch(
                            value: theme,
                            onChanged: (value) {
                              setState(() {
                                theme = value;
                                if (theme == true) {
                                  print("다크모드");
                                  Get.changeTheme(ThemeData.dark());
                                  setTheme(true);
                                } else {
                                  print("라이트모드");
                                  Get.changeTheme(ThemeData.light());
                                  setTheme(false);
                                }
                              });
                            },
                            activeColor: Color(0xffFFB877),
                          ),
                        ],
                      )
                    ],
                  )
                ]))),
        onWillPop: () async{
          return await Get.to(Tabb(idx : 3));
        }
    );
  }

  getAlarm() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool value = pref.getBool("ala")!;
    setState(() {
      ala = value;
    });
  }

  setAlarm(bool value) async {
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
  }

  setTheme(bool value) async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }
}

/*
Scaffold(
        appBar : AppBar(title : Text("Setting", style : TextStyle()), backgroundColor: Colors.white24,foregroundColor: Colors.black,elevation: 0,centerTitle: true, automaticallyImplyLeading: false),
        body : Container(
            child : Column(
                children : <Widget>[
                  ListView(
                    shrinkWrap: true,
                    padding : EdgeInsets.only(left : 15),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("알람 수신", style : TextStyle(fontSize: 15)),
                          Switch(
                            value : ala,
                            onChanged:(value){
                              setState((){
                                ala = value;
                                setAlarm(value);
                              });
                            },
                            activeColor: Color(0xffFFB877),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("다크 모드", style : TextStyle(fontSize: 15)),
                          Switch(
                            value : the,
                            onChanged:(value){
                              setState((){
                                the = value;
                                ThemeData theme = Theme.of(context);
                                if(the == true){
                                  theme = ThemeData.dark();

                                }
                                else{
                                  theme = ThemeData.light();
                                }
                              });
                            },
                            activeColor: Color(0xffFFB877),
                          ),
                        ],
                      )
                    ],
                  )
                ]
            )
        )

    );
 */

/*
FutureBuilder(
      future: getAlarm(),
      builder : (context, snapshot){
        return Scaffold(
        appBar : AppBar(title : Text("Setting", style : TextStyle()), backgroundColor: Colors.white24,foregroundColor: Colors.black,elevation: 0,centerTitle: true, automaticallyImplyLeading: false),
        body : Container(
        child : Column(
        children : <Widget>[
        ListView(
        shrinkWrap: true,
        padding : EdgeInsets.only(left : 15),
        children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        Text("알람 수신", style : TextStyle(fontSize: 15)),
    Switch(
    value : ala,
    onChanged:(value){
    setState((){
    ala = value;
    setAlarm(value);
    });
    },
    activeColor: Color(0xffFFB877),
    ),
    ],
    ),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
    Text("다크 모드", style : TextStyle(fontSize: 15)),
    Switch(
    value : the,
    onChanged:(value){
    setState((){
    the = value;
    ThemeData theme = Theme.of(context);
    if(the == true){
    theme = ThemeData.dark();

    }
    else{
    theme = ThemeData.light();
    }
    });
    },
    activeColor: Color(0xffFFB877),
    ),
    ],
    )
    ],
    )
    ]
    )
    )

    );
      }
    );
 */
_getToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  print("messaging.getToken(), ${await messaging.getToken()}");
}

_delToken() async{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.deleteToken();
  print("deleting token");
}