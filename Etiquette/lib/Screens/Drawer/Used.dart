import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Providers/DB/get_UserInfo.dart';

class Used extends StatefulWidget {
  const Used({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Used();
}

class _Used extends State<Used> {
  List<String> filter = ['예매날짜 (오름차순)', '예매날짜 (내림차순)', '이름 (오름차순)', '이름 (내림차순)'];
  String _selected = '예매날짜 (오름차순)';
  late final Future future;

  List<Map<String, dynamic>> usedlist = [];

  late double width;
  late double height;
  late bool theme;

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getUsedlistFromDB() async {
    const url = "$SERVER_IP/individual/usedlist";
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
              'product_name': ticket['product_name'],
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

            usedlist.add(ex);
            setState(() {});
          }
        } else {
          String msg = data['msg'];
          displayDialog_checkonly(context, "기간 만료 티켓 목록", msg);
        }
      } else {
        displayDialog_checkonly(context, "기간 만료 티켓 목록", "보유 티켓 목록을 불러오는데 실패했습니다.");
      }
    } catch (ex) {
      print("보유 티켓 목록 --> ${ex.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getUsedlistFromDB();
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
            appBar: appbarWithArrowBackButton("사용 만료 티켓 목록", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("사용 만료 티켓", theme),
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
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: usedlist.isEmpty,
                    child: SizedBox(
                      height: height - 200,
                      child: const Center(
                        child: Text(
                          "기간 만료 티켓이 없습니다.",
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
                          itemCount: usedlist.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget> [
                                  const SizedBox(width: 5),
                                  Image.network(
                                    usedlist[index]['poster_url'],
                                    width: 88.18,
                                    height: 130,
                                    fit: BoxFit.fill,
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget> [
                                        Text(
                                          usedlist[index]['product_name'],
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
                                            usedlist[index]['place'],
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
                                            "${usedlist[index]['seat_class']}석 ${usedlist[index]['seat_No']}번",
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
                                            usedlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + usedlist[index]['performance_date'].substring(11, 16),
                                            style: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
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
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}
