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
    List titles = [
      "KLAY 충전은 어떻게 해야 하나요?",
      "결제가 안돼요"
    ];
    List contents = [
      "코인원, 바이낸스 등 암호화폐 거래소에서 KLAY를 구매한 다음 KAS 계정으로 KLAY 전송을 하면 앱 내에서 KLAY를 사용할 수 있습니다.",
      "네트워크가 불안정하거나 Klay의 잔액이 부족해 일어날 수 있습니다. 네트워크 환경과 잔액을 확인해주시기 바랍니다."
    ];
    return FutureBuilder(
        future : getTheme(),
        builder : (context, snapshot){
          if(snapshot.hasError){
            return Scaffold(
              appBar: appbarWithArrowBackButton("Home", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done){
            return Scaffold(
                appBar: AppBar(
                  title : const Text("FAQ"),
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                body : SingleChildScrollView(
                    child : Padding(
                        padding : EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                        child : ListView.separated(
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