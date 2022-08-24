import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:Etiquette/Screens/Home.dart";
import "package:Etiquette/Screens/Ticketing/Ticketing.dart";
import 'package:Etiquette/Screens/Market/Market.dart';
import 'package:Etiquette/Screens/More.dart';

class Tabb extends StatefulWidget {
  int idx = 0;

  Tabb({this.idx = 0});

  State<StatefulWidget> createState() => _Tab(idx: idx);
}

class _Tab extends State<Tabb> with SingleTickerProviderStateMixin {
  int idx = 0;
  late bool theme;

  _Tab({this.idx = 0});

  TabController? controller; //Tab 관리하는 컨트롤러
  //int selectedidx = 0;
  initState() {
    super.initState();
    // getTheme();
    controller = TabController(
        length: 4, vsync: this, initialIndex: idx); //관리하는 Tab 개수만큼 length에 입력
  }

  dispose() {
    //Do it flutter에서 dispose 해줘야지 불필요한 리소스 낭비 방지한다고 함.
    controller!.dispose();
    super.dispose();
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
                body: TabBarView(controller: controller, children: <Widget>[
                  Home(),
                  Ticketing(),
                  Market(),
                  More()
                ] //Home, Ticketing, Market, More을 탭으로 묶음
                    ),
                bottomNavigationBar: //화면 하단에 네이게이션 바 설정
                    Container(
                        color: (theme
                            ? const Color(0xffe8e8e8)
                            : const Color(0xff7b9acc)), //네이게이션 바 색깔 설정
                        child: TabBar(
                            controller: controller,
                            labelColor: (theme
                                ? const Color(0xff000000)
                                : const Color(0xffFCF6F5)), //각각 label의 글자 색깔 설정
                            indicatorColor:
                                Colors.white, //지금 나타내고 있는 탭 표시하는 색깔 설정
                            tabs: <Tab>[
                              //탭 추가한 차례대로 탭 이름 설정
                              Tab(icon: Text("Home")),
                              Tab(icon: Text("Ticketing")),
                              Tab(icon: Text("Market")),
                              Tab(icon: Text("More")),
                            ])));
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }
/*
  void _onTap(int idx){
    setState((){
      selectedidx = idx;
    }
    );
  }
   */
}
