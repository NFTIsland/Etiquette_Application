import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';

class TotalImminent extends StatefulWidget {
  const TotalImminent({Key? key}) : super(key: key);

  @override
  State createState() => _TotalImminent();
}

class _TotalImminent extends State<TotalImminent> {
  bool ala = true;
  late bool theme;
  late final Future future;

  List deadlineAll = [];

  Future<void> getImminentFromDB() async {
    const url = "$SERVER_IP/ticketing/deadLineAll";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        List _hotpick = data["data"];
        for (Map<String, dynamic> item in _hotpick) {
          Map<String, dynamic> ex = {
            'product_name': item['product_name'],
            'place': item['place'],
          };
          deadlineAll.add(ex);
          setState(() {});
        }
      } else {
        await displayDialog_checkonly(context, "마감 임박", "서버와의 상태가 원활하지 않습니다.");
        Navigator.of(context).pop();
      }
    } catch (ex) {
      String msg = ex.toString();
      await displayDialog_checkonly(context, "마감 임박", msg);
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    future = getImminentFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("마감 임박 티켓 목록"),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: appbarWithArrowBackButton("마감 임박 티켓 목록"),
                body: Column(
                    children: <Widget>[
                      Expanded(
                          child: SingleChildScrollView(
                            child: Center(
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(left: 18, right: 18),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽에 딱 붙도록 설정
                                      children: <Widget> [
                                        Center(
                                          child: Column(
                                            children: const <Widget> [
                                              Text(
                                                  "마감 시각이 임박한 티켓의 전체 목록을 보여드립니다.",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  )
                                              ),
                                              Text(
                                                  "(24시간 이내)",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: deadlineAll.length,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                  child: SizedBox(
                                                      width: double.infinity,
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Image.network(
                                                                  "https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg",
                                                                  width: 40,
                                                                  height: 40
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 2,
                                                                child: Column(
                                                                    children: <Widget>[
                                                                      Text(deadlineAll[index]['product_name']),
                                                                      Text(deadlineAll[index]['place'].toString()),
                                                                    ]
                                                                )
                                                            )
                                                          ]
                                                      )
                                                  )
                                              );
                                            }
                                        ),
                                      ]
                                  )
                              ),
                            ),
                          )
                      ),
                    ]
                )
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );
  }
}