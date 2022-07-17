import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/TabController.dart';
import 'package:get/get.dart';

class Setting extends StatefulWidget{

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
  Widget build(BuildContext context){
    return Scaffold(
        appBar : AppBar(title : Text("Setting", style : TextStyle()), backgroundColor: Colors.white24,foregroundColor: Colors.black,elevation: 0,centerTitle: true, automaticallyImplyLeading: false, leading : IconButton(
          icon : Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder : (context) => Tabb(idx : 3)));
            },
        ),),
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
                            value : theme,
                            onChanged:(value){
                              setState((){
                                theme = value;
                                if(theme == true){
                                  print("다크모드");
                                  Get.changeTheme( ThemeData.dark());
                                  setTheme(true);
                                }
                                else{
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
                ]
            )
        )

    );
  }
   getAlarm() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool value = pref.getBool("ala")!;
    setState(() {
      ala = value;
    });
  }

  setAlarm(bool value) async{
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  getTheme() async{
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
  }

  setTheme(bool value) async{
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