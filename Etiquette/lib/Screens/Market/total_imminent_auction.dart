import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Screens/Market/market_details.dart';
import 'package:Etiquette/Utilities/time_remaining_until_end.dart';
import 'package:Etiquette/Providers/DB/get_UserInfo.dart';

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
          final auction_end_date = item['auction_end_date'];

          Map<String, dynamic> ex = {
            'token_id': item['token_id'],
            'product_name': item['product_name'],
            'owner': item['owner'],
            'place': item['place'],
            'performance_date': item['performance_date'],
            'seat_class': item['seat_class'],
            'seat_No': item['seat_No'],
            'auction_end_date': item['auction_end_date'],
            'auction_end_date_day_of_the_week': DateFormat.E('ko_KR').format(
              DateTime(
                int.parse(auction_end_date.substring(0, 4)),
                int.parse(auction_end_date.substring(5, 7)),
                int.parse(auction_end_date.substring(8, 10)),
              ),
            ),
            'poster_url': item['poster_url'],
          };

          if (item['poster_url'] == null) {
            if (item['category'] == 'movie') {
              ex['poster_url'] = 'https://firebasestorage.googleapis.com/v0/b/island-96845.appspot.com/o/poster%2Fsample_movie_poster.png?alt=media&token=536aeb85-7b8f-4f1d-b99f-340abc2259c4';
            } else {
              ex['poster_url'] = 'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg';
            }
          }

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
                                        (deadlineAll.isEmpty) ? (
                                            Container(
                                                padding : EdgeInsets.fromLTRB(width* 0.05, 0, width* 0.05, 0),
                                                width : width * 0.9,
                                                height : width * 0.5,
                                                alignment: Alignment.center,
                                                child : const Text(
                                                    "마감이 임박한 티켓이 없습니다!",
                                                    style : TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 15,
                                                    )
                                                )
                                            )
                                        ) : (
                                            GridView.builder(
                                                physics: const NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2, // 1 개의 행에 보여줄 item 개수
                                                  childAspectRatio: 3 / 7,
                                                  mainAxisSpacing: height * 0.01, // 수평 Padding
                                                  crossAxisSpacing: width * 0.05, // 수직 Padding
                                                ),
                                                shrinkWrap: true,
                                                itemCount: deadlineAll.length,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                      color: Colors.white24,
                                                      elevation : 0,
                                                      child: InkWell(
                                                        highlightColor: Colors.transparent,
                                                        splashFactory: NoSplash.splashFactory,
                                                        onTap: () async {
                                                          final kas_address_data = await getKasAddress();
                                                          if (kas_address_data['statusCode'] != 200) {
                                                            displayDialog_checkonly(context, "티켓 검색", "서버와의 연결이 원활하지 않습니다. 잠시 후 다시 시도해 주세요.");
                                                            return;
                                                          }
                                                          final kas_address = kas_address_data['data'][0]['kas_address'];
                                                          if (kas_address == deadlineAll[index]['owner']) {
                                                            displayDialog_checkonly(context, "티켓 검색", "이미 해당 티켓을 가지고 있습니다.");
                                                            return;
                                                          }
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => MarketDetails(
                                                                token_id: deadlineAll[index]['token_id'],
                                                                product_name: deadlineAll[index]['product_name'],
                                                                owner: deadlineAll[index]['owner'],
                                                                place: deadlineAll[index]['place'],
                                                                performance_date: deadlineAll[index]['performance_date'],
                                                                seat_class: deadlineAll[index]['seat_class'],
                                                                seat_No: deadlineAll[index]['seat_No'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget> [
                                                              Expanded(
                                                                flex: 3,
                                                                child: Image.network(
                                                                  deadlineAll[index]['poster_url'],
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Expanded(
                                                                  flex: 1,
                                                                  child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: <Widget> [
                                                                        Row(
                                                                            children: <Widget> [
                                                                              Icon(
                                                                                Icons.alarm,
                                                                                size: 15,
                                                                                color: Colors.grey[600],
                                                                              ),
                                                                              const SizedBox(width: 4),
                                                                              Text(
                                                                                "${deadlineAll[index]['auction_end_date'].substring(5, 10).replaceAll("-", ".")}",
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'Quicksand',
                                                                                  color: Colors.grey[600],
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                  "(${deadlineAll[index]['auction_end_date_day_of_the_week']}) ",
                                                                                  style : TextStyle(
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Quicksand',
                                                                                    color: Colors.grey[600],
                                                                                  )
                                                                              ),
                                                                              Text(
                                                                                "${deadlineAll[index]['auction_end_date'].substring(11, 16)}",
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'Quicksand',
                                                                                  color: Colors.grey[600],
                                                                                ),
                                                                              ),
                                                                            ]
                                                                        ),
                                                                        const SizedBox(height: 5),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: <Widget> [
                                                                            Icon(
                                                                              Icons.access_time_rounded,
                                                                              size: 15,
                                                                              color: Colors.grey[600],
                                                                            ),
                                                                            const SizedBox(width: 4),
                                                                            Text(
                                                                              "${timeRemainingUntilEndUnderOneDay(deadlineAll[index]['auction_end_date'])} 남음",
                                                                              style: TextStyle(
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: 'Quicksand',
                                                                                color: Colors.grey[600],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(height: 5),
                                                                        Text(
                                                                            deadlineAll[index]['product_name'],
                                                                            style: const TextStyle(
                                                                              fontFamily: "NotoSans",
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.bold,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            )
                                                                        ),
                                                                        Text(
                                                                          deadlineAll[index]['place'].toString(),
                                                                          style: const TextStyle(
                                                                            fontSize: 10,
                                                                            fontFamily: "NotoSans",
                                                                            color: Colors.grey,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "${deadlineAll[index]['seat_class']}석 ${deadlineAll[index]['seat_No']}번",
                                                                          style: const TextStyle(
                                                                            fontFamily: "NotoSans",
                                                                            fontSize: 10,
                                                                            color: Colors.grey,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        )
                                                                      ]
                                                                  )
                                                              )
                                                            ]
                                                        ),
                                                      )
                                                  );
                                                }
                                            )
                                        )
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