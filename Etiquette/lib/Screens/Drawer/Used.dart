import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';

class Used extends StatefulWidget {
  const Used({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Used();
}

class _Used extends State<Used> {
  List<String> filter = ['All', 'High', 'Row', 'Recent', 'Old'];
  String _selected = 'All';
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
            };
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
            appBar: appbarWithArrowBackButton("기간 만료 티켓 목록", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: appbarWithArrowBackButton("기간 만료 티켓", theme),
              body: Column(
                children: <Widget> [
                  Container(
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      padding:  EdgeInsets.only(left: width*0.05),
                      child: Column(
                          children: <Widget>[
                            const SizedBox(height: 20),
                            SizedBox(
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
                                            fontSize: 15,
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
                            )
                          ]
                      )
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(width*0.05,0,width*0.05,0),
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: usedlist.length,
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
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget> [
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Image.network(
                                                'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                        ),
                                        SizedBox(width : height *0.03),
                                        Expanded(
                                          flex: 3,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget> [
                                                const SizedBox(height: 10),
                                                Text(
                                                  usedlist[index]['product_name'],
                                                  textAlign: TextAlign.center,

                                                  style: const TextStyle(
                                                    fontFamily: 'NotoSans',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  usedlist[index]['place'],
                                                  style: const TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "${usedlist[index]['seat_class']}석 ${usedlist[index]['seat_No']}번",
                                                  style: const TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  usedlist[index]['performance_date'].substring(0, 10).replaceAll("-", ".") + " " + usedlist[index]['performance_date'].substring(11, 16),
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
                ],
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
