import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';

class Guide extends StatefulWidget{
  createState() => _Guide();
}

class _Guide extends State<Guide>{
  bool theme = false;

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height =  MediaQuery.of(context).size.height;
    return FutureBuilder(
      future : getTheme(),
      builder : (context, snapshot){
        if(snapshot.hasError){
          return Scaffold(
            appBar: appbarWithArrowBackButton("Home", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if(snapshot.connectionState == ConnectionState.done){
            return Scaffold(
              appBar: AppBar( title : Text("Application Guide"),
                backgroundColor: Colors.white24,
                foregroundColor: Colors.black,
                elevation: 0,),
              body : SingleChildScrollView(
                child : Padding(
                  padding : EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                  child : Column(
                    children : <Widget>[
                      Text("1. Ticketing 하는 법", style: TextStyle(
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: (theme
                          ? const Color(0xff000000)
                          : const Color(0xff000000)),
                      overflow: TextOverflow.ellipsis)),
                      Text("Ticketing 탭에서 우측 상단에 돋보기 모양 검색 버튼 터치\n -> 티켓 이름을 입력 -> 돋보기 모양 검색 버튼 터지 후 원하는 티켓 터치\n ->"
                          "예매하기 터치 후 원하는 날짜 터치\n예매하기 터치 후 원하는 좌석 등급, 좌석 번호 선택 후 결제 터치해서 결제하기",
                          style: TextStyle(
                              fontFamily: "NotoSans",
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: (theme ? const Color(0xff000000) : const Color(0xff000000))
                          )
                      )
                    ]
                  )
                )

              )
            );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}