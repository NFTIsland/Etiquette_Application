import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> filter = ['예매날짜 (오름차순)', '예매날짜 (내림차순)', '이름 (오름차순)', '이름 (내림차순)', '장소 (오름차순)', '장소 (내림차순)'];
  String _selected = '예매날짜 (오름차순)';
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

  Future<void> sortHoldlist() async {
    if (_selected == '예매날짜 (오름차순)') {
      holdlist.sort((a, b) => (a['performance_date'].compareTo(b['performance_date'])));
    } else if (_selected == '예매날짜 (내림차순)') {
      holdlist.sort((a, b) => (b['performance_date'].compareTo(a['performance_date'])));
    } else if (_selected == '이름 (오름차순)') {
      holdlist.sort((a, b) => (a['product_name'].compareTo(b['product_name'])));
    } else if (_selected == '이름 (내림차순)') {
      holdlist.sort((a, b) => (b['product_name'].compareTo(a['product_name'])));
    } else if (_selected == '장소 (오름차순)') {
      holdlist.sort((a, b) {
        var r = a['place'].compareTo(b['place']);
        if (r != 0) {
          return r;
        }
        return a['product_name'].compareTo(b['product_name']);
      });
    } else if (_selected == '장소 (내림차순)') {
      holdlist.sort((a, b) {
        var r = b['place'].compareTo(a['place']);
        if (r != 0) {
          return r;
        }
        return a['product_name'].compareTo(b['product_name']);
      });
    }
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: DropdownButtonFormField(
                        icon: const Icon(Icons.expand_more),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Filter',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _selected,
                        items: filter.map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (dynamic value) {
                          setState(() {
                            _selected = value;
                            sortHoldlist();
                          });
                        },
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Divider(
                          height: 31,
                          color: Colors.grey[400],
                        ),
                        SizedBox(
                          height: height - 220,
                          child: ListView.separated(
                            itemCount: holdlist.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashFactory: InkRipple.splashFactory,
                                  // splashFactory: NoSplash.splashFactory,
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
                                          bottomButtonType: 2,
                                          seat_class: holdlist[index]['seat_class'],
                                          seat_No: holdlist[index]['seat_No'],
                                          performance_date : holdlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + holdlist[index]['performance_date'].substring(11, 16),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget> [
                                      const SizedBox(width: 5),
                                      Image.network(
                                        holdlist[index]['poster_url'],
                                        // 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fkbo_logo.png?alt=media&token=b3a5372d-1e5c-4013-b2d5-1dad86ff4060',
                                        width: 88.18,
                                        height: 130,
                                        fit: BoxFit.fill,
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget> [
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget> [
                                                  Text(
                                                    holdlist[index]['product_name'],
                                                    style: const TextStyle(
                                                      fontFamily: 'NotoSans',
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 14),
                                                    child: Text(
                                                      holdlist[index]['place'],
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: 'Pretendard',
                                                        fontWeight: FontWeight.w400,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 14),
                                                    child: Text(
                                                      "${holdlist[index]['seat_class']}석 ${holdlist[index]['seat_No']}번",
                                                      style: const TextStyle(
                                                        fontFamily: 'Pretendard',
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 13,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 14),
                                                    child: Text(
                                                      holdlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + holdlist[index]['performance_date'].substring(11, 16),
                                                      style: const TextStyle(
                                                        // fontFamily: 'Pretendard',
                                                        // fontWeight: FontWeight.w400,
                                                        fontFamily: 'Quicksand',
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
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
                                                    navigatorToTicketView(
                                                      holdlist[index]['category'],
                                                      holdlist[index]['token_id'],
                                                      holdlist[index]['product_name'],
                                                      holdlist[index]['place'],
                                                      holdlist[index]['seat_class'],
                                                      holdlist[index]['seat_No'],
                                                      holdlist[index]['performance_date'],
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(
                                height: 20,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ]
              ),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> navigatorToTicketView(
      String alias,
      String token_id,
      String product_name,
      String place,
      String seat_class,
      String seat_No,
      String performance_date,
      ) async {
    final category = translateCategory(alias);
    final _kip17GetTokenData = await kip17GetTokenData(alias, token_id);

    if (_kip17GetTokenData['statusCode'] == 200) {
      final owner = _kip17GetTokenData['data']['owner']; // from kip17 token
      final kas_address_data = await getKasAddress();

      if (kas_address_data['statusCode'] == 200) {
        final kas_address = kas_address_data['data'][0]['kas_address'];

        if (compareStringsIgnoreCase(owner, kas_address)) {
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
  }
}
