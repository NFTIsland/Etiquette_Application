import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'TabController.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SellTicket extends StatefulWidget {
  State createState() => _SellTicket();
}

class _SellTicket extends State<SellTicket> {
  List<String> filter = ['영화', '콘서트', '뮤지컬', '공연', '스포츠'];//카테고리 리스트
  String _selected = '영화';//리스트 중 선택된 것 가르키는 변수
  late String name;//티켓 이름 저장할 변수
  var ticketImage;//티켓 이미지 파일화로 저장할 변수
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("티켓 판매 등록"),
            centerTitle: true,
            backgroundColor: Colors.white24,
            foregroundColor: Colors.black,
            elevation: 0,
            //elevation은 떠보이는 느낌 설정하는 것, 0이면 뜨는 느낌 없음, foreground는 글자 색 변경
            automaticallyImplyLeading: false, leading : IconButton(
            icon : const Icon(Icons.arrow_back_ios_new_rounded),//뒤로가기 버튼
              onPressed: (){
                Navigator.pop(context);//원래 있던 곳으로 돌아가게 함
              },
            )
            ),
        body: Column(children: <Widget>[
          Expanded(
              child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
              child : SingleChildScrollView(
                //만약 화면에 다 표현할 수 없으면 스크롤 할 수 있게 설정
                  child: Center(
                      child: Column(//세로로 배치
                          children: <Widget>[
                            Padding(
                                padding : EdgeInsets.fromLTRB(40, 30, 40, 0),
                                child : Row(
                                    children : <Widget>[
                                      const Text("카테고리 : "),
                                      Container(
                                          width : 150,
                                          height : 60,
                                          child : DropdownButtonFormField(//드랍다운 버튼 생성
                                            //style : TextStyle(fontSize : 15),
                                            icon : Icon(Icons.expand_more),
                                            decoration: InputDecoration(
                                              //filled : true,
                                              //fillColor: Hexcolor('#ecedec'),
                                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(width : 1, color : Colors.grey)),
                                                labelStyle: TextStyle(color : Colors.grey),
                                                //labelText: 'Filter',
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                                            ),
                                            value : _selected,
                                            items : filter.map(
                                                    (value){
                                                  return DropdownMenuItem(
                                                    value : value,
                                                    child : Text(value, style : TextStyle(fontSize : 15)),
                                                  );
                                                }
                                            ).toList(),
                                            onChanged : (dynamic value){
                                              setState(() {
                                                _selected = value;
                                              });
                                            },
                                          )
                                      )
                                    ]
                                )
                            ),
                            Padding(
                                padding : EdgeInsets.fromLTRB(40, 30, 40, 0),
                                child : Row(
                                    children : <Widget>[
                                      const Text("티켓 이름 : "),
                                      Flexible(//티켓 이름 입력하는 곳
                                          child :
                                          TextField( keyboardType: TextInputType.text,//기본으로 자판 모양의 키보드가 호출되도록 설정
                                              onChanged : (text){setState((){name = text;});}//바뀔 때마다 id를 입력되어 있는 값으로 변경
                                          )
                                      ),
                                    ]
                                )
                            ),
                            Padding(
                                padding : EdgeInsets.fromLTRB(40, 30, 40, 0),
                                child : Row(
                                    children : <Widget>[
                                      const Text("가격 : "),
                                      Flexible(
                                          child ://가격 입력하는 곳인데 filter로 숫자만 입력하게 설정해놓음
                                          TextField( keyboardType: TextInputType.number,//기본으로 자판 모양의 키보드가 호출되도록 설정
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              onChanged : (text){setState((){name = text;});}//바뀔 때마다 id를 입력되어 있는 값으로 변경
                                          )
                                      ),
                                      const Text("원"),
                                    ]
                                )
                            ),
                            Padding(
                                padding : EdgeInsets.fromLTRB(40, 30, 40, 0),
                                child : Row(
                                    children : <Widget>[
                                      //Expanded(child: child)
                                      const Text("티켓 이미지 : "),
                                      //SizedBox(width : 10),
                                      ticketImage  == null ? const Icon(Icons.add_photo_alternate_outlined, size: 50,) : Image.file(ticketImage, width : 50, height : 50),//선택된 게 없으면 사진 이미지가, 선택된게 있으면 선택된 것의 이미지가 출력되도록 함
                                      ElevatedButton(//이미지 고르는 버튼
                                          onPressed: () async {
                                              var picker  = ImagePicker();
                                              var image = await picker.pickImage(source:ImageSource.gallery);//갤러리에서 고름
                                              if(image != null) {//골랐으면
                                                setState(() {
                                                  ticketImage = File(image.path);//파일화해서 저장
                                                });
                                              }
                                          },
                                          child: const Text("업로드"),
                                          //로그인 버튼
                                          style: ElevatedButton.styleFrom(
                                              primary: const Color(0xff7795FF),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12)) //둥글게 설정
                                          ))
                                    ]
                                )
                            ),
                            Padding(
                              padding : EdgeInsets.fromLTRB(40, 30, 40, 0),
                              child : ElevatedButton(//이미지 고르는 버튼
                                  onPressed: ()  {//데이터베이스랑 연동하는 코드 추가하는 곳
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder : (context) => Tabb(idx : 2)));
                                  },
                                  child: const Text("판매하기"),
                                  //로그인 버튼
                                  style: ElevatedButton.styleFrom(
                                      primary: const Color(0xffffb877),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)) //둥글게 설정
                                  ))
                            )
                          ]
                      )
                  )
              )
            )
          ),
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
        ]));
  }
}
