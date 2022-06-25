import "package:flutter/material.dart";
import "Home.dart";
import "Market.dart";
import "More.dart";
import "Ticketing.dart";

class Tabb extends StatefulWidget{
const Tabb({Key? key}) : super(key: key);

State<StatefulWidget> createState() => _Tab();

}

class _Tab extends State<Tabb>
  with SingleTickerProviderStateMixin{
  TabController? controller;//Tab 관리하는 컨트롤러
  //int selectedidx = 0;
  initState(){
    super.initState();
    controller = TabController(length : 4, vsync:this);//관리하는 Tab 개수만큼 length에 입력
  }
  dispose(){//Do it flutter에서 dispose 해줘야지 불필요한 리소스 낭비 방지한다고 함.
    controller!.dispose();
    super.dispose();
  }
  Widget build(BuildContext context){
    return Scaffold(
      body : TabBarView(
        controller: controller,
        children : <Widget>[Home(), Ticketing(), Market(), More()]//Home, Ticketing, Market, More을 탭으로 묶음
      ),
    bottomNavigationBar ://화면 하단에 네이게이션 바 설정
    Container(
      color : Colors.deepPurpleAccent,//네이게이션 바 색깔 설정
        child : TabBar(
      controller: controller,
    labelColor: Colors.white,//각각 label의 글자 색깔 설정
    indicatorColor: Colors.white,//지금 나타내고 있는 탭 표시하는 색깔 설정
    tabs : <Tab>[//탭 추가한 차례대로 탭 이름 설정
    Tab(icon : Text("Home")),
    Tab(icon : Text("Ticketing")),
    Tab(icon : Text("Market")),
    Tab(icon : Text("More")),
    ]
    )
    )
    );
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