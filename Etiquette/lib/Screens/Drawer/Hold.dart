import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Providers/KAS/Kip17/kip17_get_token_data.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Utilities/compare_strings_ignore_case.dart';
import 'package:Etiquette/Screens/Ticketing/ticket_details.dart';
import 'package:Etiquette/Screens/Drawer/TicketView.dart';

class Hold extends StatefulWidget {
  const Hold({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Hold();
}

class _Hold extends State<Hold> {
  List<String> filter = ['All', 'High', 'Low', 'Recent', 'Old'];
  String _selected = 'All';
  late final Future future;
  late bool theme;

  List<Map<String, dynamic>> holdlist = [];

  late double width;
  late double height;

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getHoldlistFromDB() async {
    const url = "$SERVER_IP/individual/holdlist";
    try {
      final kas_address_data = await getKasAddress();
      if (kas_address_data['statusCode'] == 200) {
        var res = await http.post(Uri.parse(url), body: {
          'kas_address': kas_address_data['data'][0]['kas_address'],
        });
        Map<String, dynamic> data = json.decode(res.body);
        if (res.statusCode == 200) {
          List tickets = data["data"];
          for (Map<String, dynamic> ticket in tickets) {
            Map<String, dynamic> ex = {
              'token_id': ticket['token_id'],
              'product_name': ticket['product_name'],
              'category': ticket['category'],
              'place': ticket['place'],
              'seat_class': ticket['seat_class'],
              'seat_No': ticket['seat_No'],
              'performance_date': ticket['performance_date'],
              'poster_url': ticket['poster_url'],
            };

            if (ticket['poster_url'] == null) {
              if (ticket['category'] == 'movie') {
                ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
              } else {
                ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
              }
            }

            holdlist.add(ex);
            setState(() {});
          }
        } else {
          String msg = data['msg'];
          displayDialog_checkonly(context, "보유 티켓 목록", msg);
        }
      } else {
        displayDialog_checkonly(context, "보유 티켓 목록", "보유 티켓 목록을 불러오는데 실패했습니다.");
      }
    } catch (ex) {
      print("보유 티켓 목록 --> ${ex.toString()}");
    }
  }

  void showTicketQrCodeDialog(
      String category,
      String product_name,
      String place,
      String seat_class,
      String seat_No,
      String performance_date,
      String tokenUri) { // 모바일 티켓 QR 코드를 보여주는 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final width = MediaQuery.of(context).size.width;
        return AlertDialog(
          insetPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          // title: const Text("모바일 티켓"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    "모바일 티켓",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    "캡쳐화면 사용 시 입장이 제한될 수 있습니다.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 15, 0, 0),
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
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          const Text(
                            '티켓명',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              product_name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          const Text(
                            "장소",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              place,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        width: width - 40,
                        height: 100,
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 1,
                          children: <Widget> [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                const Text(
                                  "예매 날짜",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  performance_date.substring(0, 10).replaceAll("-", "."),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                const Text(
                                  "예매 시각",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  performance_date.substring(11, 16),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                const Text(
                                  "좌석",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$seat_class석",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                const Text(
                                  "번호",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$seat_No번",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: SizedBox(
                        width: 250.0,
                        height: 250.0,
                        child: QrImage(
                          errorStateBuilder: (context, error) => Text(error.toString()),
                          data: tokenUri,
                          size: 250,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Center(
                      child: Text(
                        '입장 전 위 QR 코드를 제시해 주시기 바랍니다.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          actions: <Widget> [
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
      }
    );
  }

  Widget ticketDetailsWidget(String firstTitle, String firstDesc, String secondTitle, String secondDesc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                firstTitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  firstDesc,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                secondTitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  secondDesc,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  String translateCategory(String category) {
    if (category == "movie") {
      return "영화";
    } else if (category == "musical") {
      return "뮤지컬";
    } else if (category == "concert") {
      return "콘서트";
    } else if (category == "performance") {
      return "공연";
    } else if (category == "sports") {
      return "스포츠";
    } else {
      return "";
    }
  }

  Future<void> loading() async {
    holdlist.clear();
    await getTheme();
    await getHoldlistFromDB();
  }

  @override
  void initState() {
    super.initState();
    future = loading();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("보유 티켓 목록", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: appbarWithArrowBackButton( "보유 티켓 목록", theme),
              body: Column(
                  children: <Widget> [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: SizedBox(
                          width: 150,
                          height: 60,
                          child: DropdownButtonFormField(
                            icon: const Icon(Icons.expand_more),
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        width: 1,
                                        color: Colors.grey
                                    )
                                ),
                                labelStyle: const TextStyle(
                                    color: Colors.grey
                                ),
                                labelText: 'Filter',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)
                                )
                            ),
                            value: _selected,
                            items: filter.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(
                                    value,
                                    style: const TextStyle(
                                        fontSize: 15
                                    )
                                ),
                              );
                            }).toList(),
                            onChanged: (dynamic value) {
                              setState(() {
                                _selected = value;
                              });
                            },
                          )
                      ),
                    ),
                    Visibility(
                      visible: holdlist.isEmpty,
                        child: SizedBox(
                          height: height - 200,
                          child: const Center(
                            child: Text(
                              "현재 보유중인 티켓이 없습니다.",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: holdlist.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 0,
                                  color: Colors.white24,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    onTap: () async {
                                      final alias = holdlist[index]['category'];
                                      final token_id = holdlist[index]['token_id'];
                                      final _kip17GetTokenData = await kip17GetTokenData(alias, token_id);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TicketDetails(
                                            owner : _kip17GetTokenData['data']['owner'],
                                            token_id : holdlist[index]['token_id'],
                                            product_name: holdlist[index]['product_name'],
                                            place: holdlist[index]['place'],
                                            showPurchaseButton: false,
                                            seat_class: holdlist[index]['seat_class'],
                                            seat_No: holdlist[index]['seat_No'],
                                            performance_date : holdlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + holdlist[index]['performance_date'].substring(11, 16),
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget> [
                                          const SizedBox(width: 10),
                                          Center(
                                            child: Image.network(
                                              holdlist[index]['poster_url'],
                                              width: 80,
                                              height: 117.93,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget> [
                                                const SizedBox(height: 10),
                                                Text(
                                                  holdlist[index]['product_name'],
                                                  style: TextStyle(
                                                    fontFamily: 'NotoSans',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: holdlist[index]['product_name'].length >= 21 ? 13 : 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  holdlist[index]['place'],
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "${holdlist[index]['seat_class']}석 ${holdlist[index]['seat_No']}번",
                                                  style: const TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  holdlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + holdlist[index]['performance_date'].substring(11, 16),
                                                  style: const TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Center(
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(
                                                  Icons.qr_code_rounded,
                                                  size: 50.0,
                                                ),
                                                iconSize: 50.0,
                                                onPressed: () async {
                                                  final alias = holdlist[index]['category'];
                                                  final token_id = holdlist[index]['token_id'];
                                                  final _kip17GetTokenData = await kip17GetTokenData(alias, token_id);

                                                  if (_kip17GetTokenData['statusCode'] == 200) {
                                                    final owner = _kip17GetTokenData['data']['owner']; // from kip17 token
                                                    final kas_address_data = await getKasAddress();

                                                    if (kas_address_data['statusCode'] == 200) {
                                                      final kas_address = kas_address_data['data'][0]['kas_address'];

                                                      if (compareStringsIgnoreCase(owner, kas_address)) {
                                                        final category = translateCategory(alias);
                                                        final product_name = holdlist[index]['product_name'];
                                                        final place = holdlist[index]['place'];
                                                        final seat_class = holdlist[index]['seat_class'];
                                                        final seat_No = holdlist[index]['seat_No'];
                                                        final performance_date = holdlist[index]['performance_date'];
                                                        final tokenUri = _kip17GetTokenData['data']['tokenUri'];
                                                        final nickname = Get.arguments.toString();

                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (context) => TicketView(
                                                              category: category,
                                                              product_name: product_name,
                                                              place: place,
                                                              seat_class: seat_class,
                                                              seat_No: seat_No,
                                                              performance_date: performance_date,
                                                              tokenUri: tokenUri,
                                                              nickname: nickname,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        displayDialog_checkonly(context, "모바일 티켓", "해당 티켓은 변조로 인해 사용할 수 없습니다. 서비스 센터에 문의해 주세요.");
                                                      }
                                                    } else {
                                                      displayDialog_checkonly(context, "모바일 티켓", "사용자 kas 주소를 가져오지 못했습니다. 잠시 후 다시 시도해주세요.");
                                                    }
                                                  } else {
                                                    displayDialog_checkonly(context, "모바일 티켓", "토큰 정보를 가져오지 못했습니다. 잠시 후 다시 시도해주세요.");
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      ),
                    ),
                  ]
              )
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
