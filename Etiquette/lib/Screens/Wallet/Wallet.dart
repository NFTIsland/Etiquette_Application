import 'dart:async';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:Etiquette/Screens/Wallet/klay_withdraw.dart';
import 'package:Etiquette/Providers/KAS/Wallet/get_balance.dart';
import 'package:Etiquette/Providers/Coinone/get_klay_currency.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  _Wallet createState() => _Wallet();
}

class _Wallet extends State<Wallet> {
  late final Future future;
  late bool theme;

  String lastCurrencyMsg = "Loading...";
  String klayBalance = "";
  String klayCurrency = "";
  String won = "";
  String balanceAndWonMsg = "Loading...";
  late final String address;

  final darkBlue = const Color(0xff00008b);

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> printKlayCurrencyAndBalance() async {
    Map<String, dynamic> data = await getKlayCurrency(); // 현재 KLAY 시세 정보를 API를 통해 가져옴
    if (data["statusCode"] == 200) { // 현재 KLAY 시세 정보를 정상적으로 가져옴
      klayCurrency = data["lastCurrency"];
      lastCurrencyMsg = "1 KLAY ≈ " + klayCurrency.toString() + "￦"; // 현재 KLAY 시세 표시
      double _won = roundDouble(double.parse(klayBalance) * double.parse(klayCurrency), 1); // 잔액 정보를 원화로 환산
      // won = _won.toString().replaceAllMapped(reg, mathFunc) + "￦";
      won = _won.toString().replaceAllMapped(reg, mathFunc) + "￦";
      balanceAndWonMsg = klayBalance.replaceAllMapped(reg, mathFunc) + " KLAY ≈ " + won.toString().replaceAllMapped(reg, mathFunc) + "￦"; // 잔액 정보 표시
    } else {
      balanceAndWonMsg = "잔액 정보를 가져오지 못했습니다.";
    }
  }

  Future<void> loadKlayBalanceAndCurrency() async {
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      address = kas_address_data['data'][0]['kas_address'];
      Map<String, dynamic> data = await getBalance(address);
      if (data["statusCode"] == 200) {
        klayBalance = data["data"];
        double _klay = double.parse(klayBalance);
        _klay = roundDouble(_klay, 2);
        setState(() {
          klayBalance = _klay.toString();
        });
        await printKlayCurrencyAndBalance();
      } else {
        String message = data["msg"];
        String errorMessage = "잔액 정보를 가져오지 못했습니다.\n\n$message";
        displayDialog_checkonly(context, "통신 오류", errorMessage);
      }
    } else {
      String message = kas_address_data["msg"];
      String errorMessage = "잔액 정보를 가져오지 못했습니다.\n\n$message";
      displayDialog_checkonly(context, "통신 오류", errorMessage);
    }
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    print(Get.arguments);
    getTheme();
    future = loadKlayBalanceAndCurrency();
    timer = Timer.periodic(
      const Duration(seconds: 3), // 3초 마다 자동 갱신
          (timer) {
        setState(() {
          printKlayCurrencyAndBalance();
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void showKasAddressDialog() { // KAS 주소와 QR 코드를 보여주는 다이얼로그
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Center(
            child: Text(
              "KAS 주소 확인",
              style: TextStyle(
                fontFamily: "Pretendard",
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                SizedBox( // QR 코드 부분
                  width: 200.0,
                  height: 200.0,
                  child: QrImage(
                    errorStateBuilder: (context, error) => Text(error.toString()),
                    data: address,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  address.substring(0, 25),
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  address.substring(25, ),
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.fromLTRB(width * 0.03, height * 0.01, width * 0.03, height * 0.011),
                  color: Colors.white24,
                  width: width,
                  height: 80,
                  child: CupertinoButton( // 복사 버튼
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blue,
                    child: const Text(
                      "주소 복사",
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(
                            text: address,
                          )
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget> [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("보유자산", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: appbarWithArrowBackButton("보유자산", theme),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget> [
                    Container(
                      padding: const EdgeInsets.all(25.0),
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget> [
                            const Text(
                              "잔액 정보",
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 11.0,
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: klayBalance.replaceAllMapped(reg, mathFunc),
                                      style: Theme.of(context).textTheme.headline4?.apply(
                                        color: Colors.white,
                                        fontWeightDelta: 2,
                                      )
                                  ),
                                  const TextSpan(
                                    text: " KLAY",
                                    style: TextStyle(
                                      fontFamily: "Pretendard",
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              "약 $won",
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontFamily: "Pretendard",
                              ),
                            ),
                            const SizedBox(
                              height: 11.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget> [
                                Flexible(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 11.0,
                                      ),
                                      primary: darkBlue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9.0),
                                          side: const BorderSide(
                                              color: Colors.white
                                          )
                                      ),
                                    ),
                                    onPressed: () {
                                      showKasAddressDialog();
                                    },
                                    child: const Text(
                                      '주소확인',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Pretendard",
                                      ),
                                    ),
                                  )
                                ),
                                Flexible(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 11.0
                                      ),
                                      primary: darkBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9.0),
                                        side: const BorderSide(
                                          color: Colors.white
                                        ),
                                      ),
                                    ),
                                    onPressed: () {

                                    },
                                    child: const Text(
                                      'KLAY 출금',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Pretendard",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]
                      ),
                    ),
                  ]
                )
              )
              // body: Column(
              //   children: <Widget> [
              //     Expanded(
              //       child: SingleChildScrollView(
              //         child: Center(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: <Widget> [
              //               Container(
              //                   padding: const EdgeInsets.all(25.0),
              //                   decoration: BoxDecoration(
              //                     color: const Color(0xff00008b),
              //                     borderRadius: BorderRadius.circular(15.0),
              //                   ),
              //                   child: Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: <Widget> [
              //                         const Text(
              //                           "잔액 정보",
              //                           style: TextStyle(
              //                             fontSize: 19,
              //                             fontWeight: FontWeight.bold,
              //                             color: Colors.white,
              //                           ),
              //                         ),
              //                         const SizedBox(
              //                           height: 11.0,
              //                         ),
              //                         RichText(
              //                           text: TextSpan(
              //                             children: [
              //                               TextSpan(
              //                                 text: klayBalance.replaceAllMapped(reg, mathFunc),
              //                                 style: Theme.of(context).textTheme.headline4?.apply(
              //                                     color: Colors.white,
              //                                     fontWeightDelta: 2,
              //                                 )
              //                               ),
              //                               const TextSpan(text: " KLAY")
              //                             ],
              //                           ),
              //                         ),
              //                         Text(
              //                           "약 $won",
              //                           style: TextStyle(
              //                               color: Colors.grey[300]
              //                           ),
              //                         ),
              //                         const SizedBox(
              //                           height: 11.0,
              //                         ),
              //                         Row(
              //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                           children: <Widget> [
              //                             Flexible(
              //                               child: ElevatedButton(
              //                                 style: ElevatedButton.styleFrom(
              //                                   padding: EdgeInsets.symmetric(
              //                                     horizontal: 15.0,
              //                                     vertical: 11.0,
              //                                   ),
              //                                   primary: const Color(0xff00008b),
              //                                   shape: RoundedRectangleBorder(
              //                                     borderRadius: new BorderRadius.circular(9.0),
              //                                     side: BorderSide(color: Colors.white)
              //                                   ),
              //                                 ),
              //                                 onPressed: () {
              //
              //                                 },
              //                                 child: Text(
              //                                   'Deposit',
              //                                   style: TextStyle(
              //                                     color: Colors.white,
              //                                     fontWeight: FontWeight.bold,
              //                                   ),
              //                                 ),
              //                               )
              //                             )
              //                             // Flexible(
              //                             //   child: ElevatedButton(
              //                             //     padding: EdgeInsets.symmetric(
              //                             //         horizontal: 15.0,
              //                             //         vertical: 11.0
              //                             //     ),
              //                             //     color: const Color(0xff00008b),
              //                             //     onPressed: () {},
              //                             //     child: Text(
              //                             //       'Deposit',
              //                             //       style: TextStyle(
              //                             //           color: Colors.white,
              //                             //           fontWeight: FontWeight.bold),
              //                             //     ),
              //                             //     shape: RoundedRectangleBorder(
              //                             //         borderRadius: new BorderRadius.circular(9.0),
              //                             //         side: BorderSide(color: Colors.white)
              //                             //     ),
              //                             //   ),
              //                             // ),
              //                             // Flexible(
              //                             //   child: ElevatedButton(
              //                             //     padding: EdgeInsets.symmetric(
              //                             //         horizontal: 15.0, vertical: 11.0),
              //                             //     color: const Color(0xff00008b),,
              //                             //     onPressed: () {},
              //                             //     child: Text(
              //                             //       'Cash',
              //                             //       style: TextStyle(
              //                             //           color: Colors.white,
              //                             //           fontWeight: FontWeight.bold),
              //                             //     ),
              //                             //     shape: RoundedRectangleBorder(
              //                             //         borderRadius: new BorderRadius.circular(9.0),
              //                             //         side: BorderSide(color: Colors.white)),
              //                             //   ),
              //                             // ),
              //                             // Flexible(
              //                             //   child: ElevatedButton(
              //                             //     padding: EdgeInsets.symmetric(
              //                             //         horizontal: 15.0, vertical: 11.0),
              //                             //     color: Color(0xff1b4dff),
              //                             //     onPressed: () {},
              //                             //     child: Text(
              //                             //       'Deposit',
              //                             //       style: TextStyle(
              //                             //           color: Colors.white,
              //                             //           fontWeight: FontWeight.bold),
              //                             //     ),
              //                             //     shape: RoundedRectangleBorder(
              //                             //       borderRadius: new BorderRadius.circular(9.0),
              //                             //     ),
              //                             //   ),
              //                             // ),
              //                           ],
              //                         )
              //                       ]
              //                   )
              //               ),
              //               Column(
              //                 children: <Widget> [
              //                   Image.asset('assets/image/KlaytnLogo.png', width : 155, height : 155),
              //                   const SizedBox(height : 20),
              //                   Text(
              //                       lastCurrencyMsg,
              //                       style: const TextStyle(
              //                         fontSize : 20,
              //                       )
              //                   ),
              //                   Text(
              //                       balanceAndWonMsg,
              //                       style: const TextStyle(
              //                         fontSize : 20,
              //                       )
              //                   ),
              //                   const SizedBox(height : 10),
              //                   ElevatedButton(
              //                     onPressed: () {
              //                       showKasAddressDialog();
              //                     },
              //                     child: const Text("주소 확인", style : TextStyle(fontSize : 20)),
              //                     style: ElevatedButton.styleFrom(
              //                       primary: Colors.green,
              //                       shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(15),
              //                       ),
              //                       fixedSize: const Size(140,45),
              //                     ),
              //                   ),
              //                   const SizedBox(height : 10),
              //                   ElevatedButton(
              //                     onPressed: () {
              //                       Navigator.push(
              //                           context,
              //                           MaterialPageRoute(
              //                               builder : (context) => const KlayWithdraw()
              //                           )
              //                       );
              //                       setState(() {});
              //                     },
              //                     child: const Text(
              //                         "KLAY 출금",
              //                         style: TextStyle(
              //                             fontSize : 20
              //                         )
              //                     ),
              //                     style: ElevatedButton.styleFrom(
              //                       primary: const Color(0xff7795FF),
              //                       shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(15),
              //                       ),
              //                       fixedSize: const Size(140,45),
              //                     ),
              //                   ),
              //                   const SizedBox(height : 20),
              //                   Container(
              //                     child: Column(
              //                       children: <Widget> [
              //                         const Text('History of Transaction', style: TextStyle(fontSize : 30, fontWeight : FontWeight.bold)),
              //                         const SizedBox(height : 20),
              //                         Container(
              //                           child: Column(
              //                             children: <Widget> [
              //                               // 거래 내역
              //                             ],
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     )
              //   ],
              // )
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}
