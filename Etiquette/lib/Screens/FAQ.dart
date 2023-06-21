import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';

class FAQ extends StatefulWidget{
  const FAQ({Key? key}) : super(key: key);

  @override
  createState() => _FAQ();
}

class _FAQ extends State<FAQ>{
  bool theme = false;

  List titles = [
    "KLAY 충전은 어떻게 해야 하나요?",
    "결제가 안돼요",
    "다른 사용자에게 KLAY 전송을 하려면 어떻게 해야 하나요?",
    "티켓을 사용하려고 하는데 \"해당 티켓은 변조로 인해 사용할 수 없습니다\"라는 문구가 뜹니다. 어떻게 해야 할까요?",
    "Ticketing 탭에 있는 Coming Soon과 Hot Pick은 무엇인가요?",
    "제가 가지고 있는 티켓을 다른 사람에게 전달하고 싶습니다.",
    "티켓 업로드를 취소할 수 있나요?"
  ];

  List contents = [
    // KLAY 충전은 어떻게 해야 하나요?
    "코인원, 바이낸스 등 암호화폐 거래소에서 KLAY를 구매한 다음 KAS 계정으로 KLAY 전송을 하면 앱 내에서 KLAY를 사용할 수 있습니다.\n",

    // 결제가 안돼요
    "네트워크가 불안정하거나 KLAY의 잔액이 부족해 일어날 수 있습니다. 네트워크 환경과 잔액을 확인해주시기 바랍니다.\n",

    // 다른 사용자에게 KLAY 전송을 하려면 어떻게 해야 하나요?
    "좌측 탭에서 자산 → 보유자산 → KLAY 출금을 통해 KLAY 전송이 가능합니다.\n",

    // 티켓을 사용하려고 하는데 "해당 티켓은 변조로 인해 사용할 수 없습니다"라는 문구가 뜹니다. 어떻게 해야 할까요?
    "본 앱에서는 티켓 위변조를 막기 위해 티켓 사용을 하기 전에 KAS를 통해 2차 검증을 진행합니다. 그러나 네트워크가 불안정할 경우 해당 메세지가 뜰 수도 있습니다.\n\n"
    "만약 지속적으로 해당 메세지가 뜬다면 고객센터에 문의해 주시기 바랍니다.\n",

    // Ticketing 탭에 있는 Coming Soon과 Hot Pick은 무엇인가요?
    "Coming Soon: 예매 시작까지 1시간 이내로 남은 티켓을 의미합니다.\n\n"
    "Hot Pick: 1차 티켓 중 관심 있는 티켓으로 등록한 사용자의 수가 많은 티켓을 의미합니다.\n",

    // 제가 가지고 있는 티켓을 다른 사람에게 전달하고 싶습니다.
    "현재는 다른 사용자에게 티켓을 양도하는 기능이 구현되어 있지 않으며 문의를 통해 티켓 양도 기능을 제공하고 있습니다. 고객센터에 문의해 주세요.\n",

    // 티켓 업로드를 취소할 수 있나요?
    "업로드 된 티켓은 취소할 수 없습니다. 티켓 업로드 전에 신중하게 선택해 주세요.\n",


  ];

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height =  MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: getTheme(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("Home", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title : const Text("FAQ"),
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                body: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                        child: ListView.separated(
                            separatorBuilder: (BuildContext context, int index) =>
                            const Divider(thickness: 2),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: contents.length,
                            itemBuilder: (context, index) {
                              return Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                      title: Text(
                                        titles[index],
                                        style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            color: (theme ? const Color(0xff000000) : const Color(0xff000000)),
                                            overflow: TextOverflow.clip
                                        ),
                                      ),
                                      children: <Widget> [
                                        Container(
                                          width: width * 0.8,
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget> [
                                                Flexible(
                                                  child: Text(
                                                    contents[index],
                                                    softWrap: true,
                                                    maxLines: 40,
                                                    style: TextStyle(
                                                      fontFamily: "NotoSans",
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 15,
                                                      color: (theme ? const Color(0xff000000) : const Color(0xff000000)),
                                                    ),
                                                  ),
                                                ),
                                              ]
                                          ),
                                        ),
                                      ]
                                  )
                              );
                            }
                        )
                    )
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