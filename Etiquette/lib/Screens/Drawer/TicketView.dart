import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:get/get.dart';

class TicketView extends StatefulWidget {
  String? category;
  String? product_name;
  String? place;
  String? seat_class;
  String? seat_No;
  String? performance_date;
  String? tokenUri;
  String? nickname;
  TicketView({
    Key? key,
    this.category,
    this.product_name,
    this.place,
    this.seat_class,
    this.seat_No,
    this.performance_date,
    this.tokenUri,
    this.nickname,
  }) : super(key: key);

  @override
  State createState() => _TicketView();
}

class _TicketView extends State<TicketView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text(
          "모바일 티켓",
          style: TextStyle(
              color: Color(0xffe8e8e8),
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard',
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.indigo,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
                Icons.arrow_back_ios_new_rounded
            )
        ),
      ),
      body: Center(
        child: TicketWidget(
          width: 350,
          height: widget.product_name!.length >= 16 ? 650 : 600,
          isCornerRounded: true,
          padding: const EdgeInsets.all(20),
          child: ticketData(
            width,
            height,
            widget.category!,
            widget.product_name!,
            widget.place!,
            widget.seat_class!,
            widget.seat_No!,
            widget.performance_date!,
            widget.tokenUri!,
            widget.nickname!,
          ),
        ),
      ),
    );
  }
}

Widget ticketData(
    double width,
    double height,
    String category,
    String product_name,
    String place,
    String seat_class,
    String seat_No,
    String performance_date,
    String tokenUri,
    String nickname) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Container(
          width: 120.0,
          height: 25.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(width: 1.0, color: Colors.green),
          ),
          child: Center(
            child: Text(
              category,
              style: const TextStyle(
                  color: Colors.green
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 15.0),
        child: Text(
          product_name,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard'
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 10.0, top: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget> [
            const Icon(
              Icons.location_on_outlined,
              size: 18
            ),
            const SizedBox(width: 7),
            Text(
              place,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Pretendard'
              ),
            ),
          ],
        )
      ),
      Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 25.0),
        child: Container(
          height: 180,
          padding: const EdgeInsets.only(right: 5.0),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: (height * 0.7) / width,
            children: <Widget> [
              ticketDetailsWidget('날짜', performance_date.substring(0, 10).replaceAll("-", ".")),
              ticketDetailsWidget('시간', performance_date.substring(11, 16)),
              ticketDetailsWidget('좌석 정보', "$seat_class석 $seat_No번"),
              ticketDetailsWidget('이름', nickname),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 15.0),
        child: Text(
          "입장 전 아래 QR 코드를 제시해 주시기 바랍니다.",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Center(
            child: SizedBox(
              width: 200.0,
              height: 200.0,
              child: QrImage(
                errorStateBuilder: (context, error) => Text(error.toString()),
                data: tokenUri,
                size: 200,
                backgroundColor: Colors.white,
              ),
            )
        ),
      )
    ],
  );
}

Widget ticketDetailsWidget(String firstTitle, String firstDesc) {
  return Padding(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          firstTitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            firstDesc,
            style: TextStyle(
                color: const Color(0xff00008b),
                fontSize: firstDesc.length >= 11 ? 18 : 20,
                fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    ),
  );
}