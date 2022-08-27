import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Providers/KAS/Kip17/kip17_get_token_data.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Utilities/compare_strings_ignore_case.dart';
import 'package:Etiquette/Screens/Ticketing/ticket_details.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Hold extends StatefulWidget {
  const Hold({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Hold();
}

class _Hold extends State<Hold> {
  List<String> filter = ['All', 'High', 'Low', 'Recent', 'Old'];
  String _selected = 'All';
  late final Future future;

  List<Map<String, dynamic>> holdlist = [];

  late double width;
  late double height;

  Future<void> getHoldlistFromDB() async {
    const url = "$SERVER_IP/holdlist";
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
            };
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
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          title: const Text("모바일 티켓"),
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  const Text(
                    "캡쳐화면 사용 시 입장이 제한될 수 있습니다.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product_name,
                    style: const TextStyle(
                      fontSize: 35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox( // QR 코드 부분
                    width: 200.0,
                    height: 200.0,
                    child: QrImage(
                      errorStateBuilder: (context, error) => Text(error.toString()),
                      data: tokenUri,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${seat_class}석 ${seat_No}번",
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    performance_date.substring(0, 10).replaceAll("-", ".") + " " + performance_date.substring(11, 16),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getHoldlistFromDB();
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
            appBar: appbarWithArrowBackButton("보유 티켓 목록"),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "보유 티켓 목록",
                  style: TextStyle(
                      fontSize: 25
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    Get.back();
                  },
                ),
                elevation: 0,
                backgroundColor: Colors.white24,
                foregroundColor: Colors.black,
              ),
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: holdlist.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => TicketDetails(
                                                product_name: holdlist[index]['product_name'],
                                                place: holdlist[index]['place'],
                                                showPurchaseButton: false,
                                              )
                                          )
                                      );
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget> [
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Image.network(
                                                'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                width: 80,
                                                height: 80
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget> [
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    holdlist[index]['product_name'],
                                                    style: const TextStyle(
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    holdlist[index]['place'],
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    "${holdlist[index]['seat_class']}석 ${holdlist[index]['seat_No']}번",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    holdlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + holdlist[index]['performance_date'].substring(11, 16),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Center(
                                              child: IconButton(
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
                                                        final product_name = holdlist[index]['product_name'];
                                                        final place = holdlist[index]['place'];
                                                        final seat_class = holdlist[index]['seat_class'];
                                                        final seat_No = holdlist[index]['seat_No'];
                                                        final performance_date = holdlist[index]['performance_date'];
                                                        final tokenUri = _kip17GetTokenData['data']['tokenUri'];
                                                        showTicketQrCodeDialog(product_name, place, seat_class, seat_No, performance_date, tokenUri);
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
