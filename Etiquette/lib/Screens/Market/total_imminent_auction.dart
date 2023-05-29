import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/Utilities/get_theme.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';

class TotalImminentAuction extends StatefulWidget {
  const TotalImminentAuction({Key? key}) : super(key: key);

  @override
  State createState() => _TotalImminentAuction();
}

class _TotalImminentAuction extends State<TotalImminentAuction> {
  bool ala = true;
  late bool theme;
  late final Future future;
  late double width;
  late double height;

  List deadlineAll = [];

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getImminentFromDB() async {
    const url = "$SERVER_IP/market/deadLineAllAuction";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (data['statusCode'] == 200) {
        List _hotpick = data["data"];
        for (Map<String, dynamic> item in _hotpick) {
          Map<String, dynamic> ex = {
            'product_name': item['product_name'],
            'place': item['place'],
            'seat_class': item['seat_class'],
            'seat_No': item['seat_No'],
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
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("Imminent List", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: appbarWithArrowBackButton("Imminent List", theme),
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
                                                  "마감 시각이 임박한 옥션 티켓의 전체 목록을 보여드립니다.",
                                                  style: TextStyle(
                                                    fontFamily: "Pretendard",
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                  )
                                              ),
                                              Text(
                                                  "(24시간 이내)",
                                                  style: TextStyle(
                                                    fontFamily: "Pretendard",
                                                    fontWeight: FontWeight.w500,
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
                                                elevation: 0,
                                                  color: Colors.white24,
                                                  child: SizedBox(
                                                      width: double.infinity,
                                                      child: (deadlineAll.length! == 0) ?
                                                      (
                                                          Container(
                                                              padding : EdgeInsets.fromLTRB(width*0.05, 0, width*0.05, 0),
                                                              width : width*0.9,
                                                              height : width*0.5,
                                                              alignment: Alignment.center,
                                                              child : const Text("마감이 임박한 티켓이 없습니다!",
                                                                  style : TextStyle(
                                                                    fontFamily: "Pretendard",
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 15,
                                                                  ))
                                                          ))
                                                          :
                                                      (
                                                          GridView.builder(
                                                              physics: const NeverScrollableScrollPhysics(),
                                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                                                                childAspectRatio: 3/5.5,
                                                                mainAxisSpacing: height*0.01, //수평 Padding
                                                                crossAxisSpacing: width*0.05, //수직 Padding
                                                              ),
                                                              shrinkWrap: true,
                                                              itemCount: deadlineAll.length,
                                                              itemBuilder: (context, index) {
                                                                return
                                                                  Card(
                                                                      color: Colors.white24,
                                                                      elevation : 0,
                                                                      child: InkWell(

                                                                        highlightColor: Colors.transparent,
                                                                        splashFactory: NoSplash.splashFactory,
                                                                        onTap:(){},
                                                                        child :
                                                                        Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children : <Widget>[
                                                                              Expanded(flex : 3,child: Image.network(
                                                                                "https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fmainlogo.png?alt=media&token=6195fc49-ac21-4641-94d9-1586874ded92",
                                                                                fit: BoxFit.fill,
                                                                                //color: Colors.blue,
                                                                              ),),
                                                                              Expanded(
                                                                                  flex: 1,
                                                                                  child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children : <Widget> [
                                                                                        Row(
                                                                                            children : <Widget>[
                                                                                              //Text(deadlineAll[index]['performance_date'])
                                                                                              Text("14:00", style : TextStyle(fontSize: 13, fontWeight: FontWeight.bold, ),),
                                                                                              Text(" | 12.31", style : TextStyle(fontSize: 12, ))
                                                                                            ]
                                                                                        ),
                                                                                        Text(deadlineAll[index]['product_name'], style: const TextStyle(
                                                                                          fontFamily: "NotoSans",
                                                                                          fontSize: 13,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        )
                                                                                        ),
                                                                                        Text(deadlineAll[index]['place'].toString(), style : const TextStyle(
                                                                                          fontSize: 10,
                                                                                          fontFamily: "NotoSans",
                                                                                          color: Colors.grey,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        ),
                                                                                        Text("${deadlineAll[index]['seat_class']}석 ${deadlineAll[index]['seat_No']}번",style : const TextStyle(
                                                                                          fontFamily: "NotoSans",
                                                                                          fontSize: 10,
                                                                                          color: Colors.grey,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),)
                                                                                      ]
                                                                                  )
                                                                              )

                                                                            ]
                                                                        ),
                                                                      )
                                                                  );
                                                              }
                                                          )
                                                      ),
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