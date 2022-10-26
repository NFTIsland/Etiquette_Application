import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Screens/Drawer/Change_pw.dart';
import 'package:Etiquette/Screens/Drawer/Change_nickname.dart';

class ChangeUserInfo extends StatefulWidget {
  const ChangeUserInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangeUserInfo();
}

class _ChangeUserInfo extends State<ChangeUserInfo> {
  late double width;
  late double height;
  late bool theme;
  late final Future future;
  String? nickname = "";
  var img = const Icon(Icons.notifications);

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> getNickname() async {
    nickname = await storage.read(key: "nickname");
  }

  Future<void> loading() async {
    getTheme();
    getNickname();
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
              appBar: appbarWithArrowBackButton("개인 정보 수정", theme),
              body: const Center(
                child: Text("통신 에러가 발생했습니다."),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: appbarWithArrowBackButton("개인 정보 수정", theme),
              body: Container(
                width: width,
                height: height,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                          width: width,
                          height: 0.35 * height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "비밀번호를 바꾸고 싶다면",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 0.6 * width,
                                height: 0.1 * height,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueAccent),
                                  onPressed: () {
                                    Get.to(
                                      () => ChangePW(),
                                    );
                                  },
                                  child: const Text("비밀번호 변경",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          )),
                      Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      SizedBox(
                          width: width,
                          height: 0.35 * height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "닉네임을 바꾸고 싶다면",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 0.6 * width,
                                height: 0.1 * height,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueAccent),
                                  onPressed: () {
                                    Get.to(
                                      () => ChangeNickname(),
                                    );
                                  },
                                  child: const Text("닉네임 변경",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          )),
                    ]),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
