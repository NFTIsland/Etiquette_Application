import 'dart:io';

import 'package:Etiquette/Models/testvalues.dart';
import 'package:Etiquette/Providers/DB/upload_ticket_db.dart';
import 'package:Etiquette/Providers/asset_upload.dart';
import 'package:Etiquette/Providers/KAS/Kip17/kip17_token_minting.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


class SellTicket extends StatefulWidget {
  @override
  State createState() => _SellTicket();
}

class _SellTicket extends State<SellTicket> {
  List<String> filter = ['영화', '콘서트', '뮤지컬', '공연', '스포츠']; // 카테고리 리스트
  String _selected = '영화'; // 리스트 중 선택된 것 가르키는 변수
  late String name; // 티켓 이름 저장할 변수
  var ticketImage; // 티켓 이미지 파일화로 저장할 변수

  TextEditingController inputPriceController = TextEditingController();

  void oneButtonDialog(String msg) {
    // 확인 버튼만 있는 다이얼로그
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('티켓 판매 등록'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(msg),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
              ),
            ],
          );
        });
  }

  void selectionDialog() {
    // 취소, 확인 버튼이 있는 다이얼로그
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('티켓 판매 등록'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text("티켓 업로드를 진행하시겠습니까?"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("취소"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  uploadFile();
                },
                child: const Text("확인"),
              ),
            ],
          );
        });
  }

  Future<void> checkValidUploadFile() async {
    // 티켓 업로드 이전에 모든 입력된 정보가 유효할 지 확인
    if (name != "") {
      var price = int.tryParse(inputPriceController.text);

      if (price != null) {
        if (price > 0) {
          if (ticketImage != null) {
            selectionDialog();
          } else {
            // 티켓을 선택하지 않음
            oneButtonDialog("업로드 할 티켓을 선택해 주세요.");
          }
        } else {
          // 가격을 0원으로 입력
          oneButtonDialog("가격은 0원 보다 커야 합니다.");
        }
      } else {
        // 가격을 입력하지 않음
        oneButtonDialog("티켓 가격을 입력해 주세요.");
      }
    } else {
      // 티켓 이름을 입력하지 않음
      oneButtonDialog("티켓 이름을 입력해 주세요.");
    }
  }

  Future<void> uploadFile() async {
    // 티켓 업로드
    var price = int.tryParse(inputPriceController.text);

    String fileName = ticketImage!.path.split('/').last;
    final path = 'images/' + fileName;

    Map<String, dynamic> assetUploadRes =
        await assetUpload(ticketImage!.path!); // 에셋 업로드 진행

    if (assetUploadRes["statusCode"] == 200) {
      // 에셋 업로드 완료
      Map<String, dynamic> kip17res = await kip17TokenMinting(
          _selected, testAddress1, assetUploadRes["uri"]); // 토큰 생성

      if (kip17res["statusCode"] == 200) {
        // 토큰 생성 성공
        final ref = FirebaseStorage.instance.ref().child(path);
        ref.putFile(ticketImage);

        Map<String, dynamic> ticketInfo = {
          "alias": kip17res["alias"], // alias
          "token_id": kip17res["token_id"],
          "owner_address": null,
          "ticket_name": name,
          "type": kip17res["alias"], // type
          "price": price,
          "tel": '01012345678', // tel
          "start_date": null,
          "end_date": null,
          "token_uri": assetUploadRes["uri"],
          "other_info": null
        };

        await uploadTicketDB(ticketInfo); // DB에 티켓 저장

        // 입력된 티켓 이름, 가격, 이미지 초기화
        name = "";
        inputPriceController.text = "";
        ticketImage = null;

        oneButtonDialog("티켓 업로드가 완료되었습니다.");
      } else {
        // 토큰 생성 실패
        oneButtonDialog("토큰 생성에 실패했습니다. 잠시 후 다시 시도해주세요.");
      }
    } else {
      oneButtonDialog("티켓 업로드 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("티켓 판매 등록"),
            centerTitle: true,
            backgroundColor: Colors.white24,
            foregroundColor: Colors.black,
            elevation: 0,
            // elevation은 떠보이는 느낌 설정하는 것, 0이면 뜨는 느낌 없음, foreground는 글자 색 변경
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded), //뒤로가기 버튼
              onPressed: () {
                Navigator.pop(context); //원래 있던 곳으로 돌아가게 함
              },
            )),
        body: Column(children: <Widget>[
          Expanded(
              child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                      //만약 화면에 다 표현할 수 없으면 스크롤 할 수 있게 설정
                      child: Center(
                          child: Column(//세로로 배치
                              children: <Widget>[
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 30, 40, 0),
                        child: Row(children: <Widget>[
                          const Text("카테고리 : "),
                          Container(
                              width: 150,
                              height: 60,
                              child: DropdownButtonFormField(
                                //드랍다운 버튼 생성
                                //style : TextStyle(fontSize : 15),
                                icon: Icon(Icons.expand_more),
                                decoration: InputDecoration(
                                    //filled : true,
                                    //fillColor: Hexcolor('#ecedec'),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.grey)),
                                    labelStyle: TextStyle(color: Colors.grey),
                                    //labelText: 'Filter',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                value: _selected,
                                items: filter.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(fontSize: 15)),
                                  );
                                }).toList(),
                                onChanged: (dynamic value) {
                                  setState(() {
                                    _selected = value;
                                  });
                                },
                              ))
                        ])),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 30, 40, 0),
                        child: Row(children: <Widget>[
                          const Text("티켓 이름 : "),
                          Flexible(
                              //티켓 이름 입력하는 곳
                              child: TextField(
                                  keyboardType: TextInputType.text,
                                  //기본으로 자판 모양의 키보드가 호출되도록 설정
                                  onChanged: (text) {
                                    setState(() {
                                      name = text;
                                    });
                                  } //바뀔 때마다 id를 입력되어 있는 값으로 변경
                                  )),
                        ])),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 30, 40, 0),
                        child: Row(children: <Widget>[
                          const Text("가격 : "),
                          Flexible(
                              child: //가격 입력하는 곳인데 filter로 숫자만 입력하게 설정해놓음
                                  TextField(
                            keyboardType: TextInputType.number,
                            //기본으로 자판 모양의 키보드가 호출되도록 설정
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: inputPriceController,
                            // onChanged : (text){setState((){name = text;});}//바뀔 때마다 id를 입력되어 있는 값으로 변경
                          )),
                          const Text("원"),
                        ])),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 30, 40, 0),
                        child: Row(children: <Widget>[
                          //Expanded(child: child)
                          const Text("티켓 이미지 : "),
                          //SizedBox(width : 10),
                          ticketImage == null
                              ? const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 50,
                                )
                              : Image.file(ticketImage, width: 50, height: 50),
                          //선택된 게 없으면 사진 이미지가, 선택된게 있으면 선택된 것의 이미지가 출력되도록 함
                          ElevatedButton(
                              //이미지 고르는 버튼
                              onPressed: () async {
                                var picker = ImagePicker();
                                var image = await picker.pickImage(
                                    source: ImageSource.gallery); //갤러리에서 고름
                                if (image != null) {
                                  //골랐으면
                                  setState(() {
                                    ticketImage = File(image.path); //파일화해서 저장
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
                        ])),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 30, 40, 0),
                        child: ElevatedButton(
                            onPressed: () {
                              //데이터베이스랑 연동하는 코드 추가하는 곳
                              checkValidUploadFile();
                            },
                            child: const Text("판매하기"),
                            //로그인 버튼
                            style: ElevatedButton.styleFrom(
                                primary: const Color(0xffffb877),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)) //둥글게 설정
                                )))
                  ]))))),
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
