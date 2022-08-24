import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/get_theme.dart';

import '../Providers/DB/get_kas_address.dart';
import '../widgets/appbar.dart';

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
              'product_name': ticket['product_name'],
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

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getHoldlistFromDB();
  }

  @override
  Widget build(BuildContext context) {
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
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget> [
                                          Expanded(
                                            flex: 2,
                                            child: Image.network(
                                                'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                width: 50,
                                                height: 50
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
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
                                                  holdlist[index]['performance_date'],
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
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
