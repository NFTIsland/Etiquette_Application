import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';

class Guide extends StatefulWidget{
  const Guide({Key? key}) : super(key: key);

  @override
  createState() => _Guide();
}

class _Guide extends State<Guide> {
  bool theme = false;

  List titles = [
    "자산관리",
    "1차 티켓 구매",
    "2차 티켓 입찰",
    "2차 티켓 낙찰",
    "티켓 사용",
    "티켓 업로드",
    "관심 티켓",
    "입찰 티켓",
    "판매 중 티켓",
    "사용 만료 티켓",
    "비밀번호 변경",
    "닉네임 변경"
  ];

  List contents = [
    // 자산관리
    "1) 좌측 탭에서 자산 → 보유자산 항목을 통해 현재 계정에 있는 KLAY 잔액, KAS 주소, 거래 내역을 확인할 수 있습니다.\n\n"
    "2) KLAY 충전: 코인원, 바이낸스 등 암호화폐 거래소에서 KLAY를 구매한 다음 KAS 계정으로 KLAY 전송을 하면 앱 내에서 KLAY를 사용할 수 있습니다.\n\n"
    "3) KLAY 출금: 계정에 있는 KLAY를 다른 계정으로 전송할 수 있습니다. KLAY 전송을 할 때 0.00525 KLAY의 수수료가 발생합니다.",

    // 1차 티켓 구매
    "영화, 공연, 스포츠 등 다양한 분야의 티켓을 KLAY로 구매할 수 있습니다.\n\n"
    "Ticketing 탭에서 우측 상단에 돋보기 모양 검색 버튼 → 티켓 이름 입력 → 돋보기 모양 검색 버튼 터지 후 원하는 티켓 선택 → 예매하기 클릭 후 원하는 날짜, 시간, 좌석 등급, 좌석 번호 선택 → 결제 진행",

    // 2차 티켓 입찰
    "다른 사용자가 올린 티켓을 경매를 통해 구매할 수 있습니다.\n\n"
    "Market 탭에서 우측 상단에 돋보기 모양 검색 버튼 → 티켓 이름 입력 → 돋보기 모양 검색 버튼 터지 후 원하는 티켓 선택 → 입찰하기 탭 선택 → 입찰가 입력\n\n",

    // 2차 티켓 낙찰
    "경매 마감 시각이 되면 최상위 입찰자부터 차례대로 결제가 시도됩니다. 입찰가가 높을수록 결제가 먼저 진행되며 입찰가가 같을 경우 먼저 입찰한 사용자부터 결제가 진행됩니다.\n\n"
    "단, 즉시 입찰가로 입찰할 경우 결제가 자동으로 진행되며 해당 티켓에 대한 경매 또한 마감됩니다.\n\n"
    "잔액이 충분하지 않을 경우 결제가 정상적으로 진행되지 않으므로 경매 마감전에 충분한 잔액이 있는지 확인해주시기 바랍니다.\n\n",

    // 티켓 사용
    "좌측 탭에서 티켓 → 보유 티켓 항목에서 각 티켓 오른쪽에 있는 QR 코드 아이콘을 클릭하면 화면 아래에 QR 코드가 있습니다. 해당 QR 코드를 입장할 때 제시하시기 바랍니다.\n",

    // 티켓 업로드
    "앱에서 구매한 1차 티켓은 다른 사용자에게 경매를 통해 판매할 수 있습니다.\n\n"
    "좌측 탭에서 티켓 → 보유 티켓에서 판매하려는 티켓 선택 → 판매하기 클릭 → 코멘트 탭에서 판매자 코멘트 입력 → 경매 정보 탭에서 거래 종료일, 경매 시작가, 입찰 단위, 즉시 거래가 입력 → 티켓 업로드 클릭\n\n"
    "경매 시작가, 입찰 단위, 즉시 거래가의 경우 티켓 원가를 넘을 수 없습니다.",

    // 관심 티켓
    "1차, 2차 티켓 중 관심이 있는 티켓의 경우 따로 관리할 수 있습니다. 티켓 상세 정보에서 하트 모양의 아이콘을 클릭하여 관심 있는 티켓으로 지정하거나 해제할 수 있습니다.\n\n"
    "관심 티켓은 좌측 탭에서 티켓 → 관심 티켓에서 확인할 수 있습니다.",

    // 입찰 티켓
    "사용자가 입찰한 티켓은 좌측 탭에서 티켓 → 입찰 티켓에서 확인할 수 있습니다.\n",

    // 판매 중 티켓
    "사용자가 티켓 업로드를 통해 경매가 진행중인 티켓은 좌측 탭에서 티켓 → 판매 중 티켓에서 확인할 수 있습니다.\n\n"
    "각 티켓 오른쪽 위에 있는 i 모양의 아이콘을 클릭하면 경매 마감까지 남은 시간, 현재 입찰자 수, 현재 최고 입찰가 등 상세 정보를 확인할 수 있습니다.",

    // 사용 만료 티켓
    "티켓 사용이 마감된 티켓은 좌측 탭에서 티켓 → 사용 만료 티켓에서 확인할 수 있습니다.\n",

    // 비밀번호 변경
    "1) 좌측 탭에서 내 정보 → 개인정보 변경 → 비밀번호 변경을 선택합니다.\n\n"
    "2) 현재 사용하고 있는 비밀번호를 입력하고 다음 버튼을 클릭합니다.\n\n"
    "3) 새로운 비밀번호를 입력하고 비밀번호 변경을 클릭합니다.\n",

    // 닉네임 변경
    "1) 좌측 탭에서 내 정보 → 개인정보 변경 → 닉네임 변경을 선택합니다.\n\n"
    "2) 새 닉네임을 입력하고 중복확인 → 닉네임 변경을 클릭합니다.\n"
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
        if(snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title : const Text("Application Guide"),
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
                                      overflow: TextOverflow.ellipsis
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