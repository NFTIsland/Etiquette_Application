import 'package:flutter/material.dart';
import 'package:get/get.dart';
class Wallet extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wallet", style: TextStyle(fontSize: 25)),
          backgroundColor: Colors.white24,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Get.back();
                //Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded)),
        ),
        body: Container(
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      //사진, 금액, 충전 버튼
                      child: Column(children: <Widget>[
                    Image.asset('assets/image/KlaytnLogo.png',
                        width: 155, height: 155),
                    SizedBox(height: 20),
                    Text('500.13 KLAY\n≈ 265,068￦',
                        style: TextStyle(
                          fontSize: 30,
                        )),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {},
                        child: Text("Charge", style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xff7795FF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            fixedSize: Size(140, 45)))
                  ])),
                  SizedBox(height: 20),
                  Container(
                      child: Column(children: <Widget>[
                    Text('History of Transaction',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Container(child: Column(//거래내역
                        children: <Widget>[]))
                  ]))
                ])));
  }
}
