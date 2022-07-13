import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget{

  State<StatefulWidget> createState() => _Setting();
}

class _Setting extends State<Setting> {
  bool ala = true;
  bool the = false;
  void initState() {
    super.initState();
    ala = getAlarm();
    print("a;sdjfa;sldkjfas;dlfkj");
  }
  Widget build(BuildContext context){
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
   getAlarm() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool value = pref.getBool("ala")!;
    return value;
  }

  setAlarm(bool value) async{
    var key = 'ala';
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }
}