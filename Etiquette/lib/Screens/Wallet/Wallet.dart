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
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Utilities/numberConversion.dart';
import 'package:Etiquette/Utilities/compare_strings_ignore_case.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/transaction_container.dart';
import 'package:Etiquette/Providers/KAS/get_transaction_history.dart';
import 'package:Etiquette/Providers/DB/get_ticketInfo_by_token_id.dart';

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

  // 조회 선택에서 사용
  String prev_selected_type = "전체";
  String prev_selected_period = "1주일";
  String selected_type = "전체";
  String selected_period = "1주일";

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

  Future<void> loadTransactionHistory() async {
    transactions.clear();
    final history = await getTransactionHistory(address, selected_type, selected_period);
    if (history['statusCode'] == 200) {
      for (var item in history['data']['items']) {
        if (item['transferType'] == 'klay') {
          if (compareStringsIgnoreCase(item["from"], address) && !compareStringsIgnoreCase(item["to"], address)) {
            transactions.add({
              "kind": "KLAY",
              "transferType": "KLAY 출금",
              "date": DateTime.fromMillisecondsSinceEpoch(item["timestamp"] * 1000).toString().substring(0, 19).replaceAll('-', '.'),
              "value": roundDouble(pebToKlayConversion(hexToDouble(item["value"].substring(2, ))), 2)
            });
          } else {
            transactions.add({
              "kind": "KLAY",
              "transferType": "KLAY 입금",
              "date": DateTime.fromMillisecondsSinceEpoch(item["timestamp"] * 1000).toString().substring(0, 19).replaceAll('-', '.'),
              "value": roundDouble(pebToKlayConversion(hexToDouble(item["value"].substring(2, ))), 2)
            });
          }
        } else if (item['transferType'] == 'nft') {
          final data = await getTicketInfoByTokenId(item["tokenId"]);
          if (compareStringsIgnoreCase(item["from"], address) && !compareStringsIgnoreCase(item["to"], address)) {
            transactions.add({
              "kind": "NFT",
              "transferType": "티켓 판매",
              "date": DateTime.fromMillisecondsSinceEpoch(item["transaction"]["timestamp"] * 1000).toString().substring(0, 19).replaceAll('-', '.'),
              "tokenId": item["tokenId"],
              "product_name": data['data'][0]['product_name'] ?? "",
              "place": data['data'][0]['place'] ?? "",
              "seat_class": data['data'][0]['seat_class'] ?? "",
              "seat_No": data['data'][0]['seat_No'] ?? "",
            });
          } else {
            transactions.add({
              "kind": "NFT",
              "transferType": "티켓 구매",
              "date": DateTime.fromMillisecondsSinceEpoch(item["transaction"]["timestamp"] * 1000).toString().substring(0, 19).replaceAll('-', '.'),
              "tokenId": item["tokenId"],
              "product_name": data['data'][0]['product_name'] ?? "",
              "place": data['data'][0]['place'] ?? "",
              "seat_class": data['data'][0]['seat_class'] ?? "",
              "seat_No": data['data'][0]['seat_No'] ?? "",
            });
          }
        }
      }
    } else {
      print(history['msg']);
    }
  }

  Timer? timer;

  Future<void> loading() async {
    await loadKlayBalanceAndCurrency();
    await printKlayCurrencyAndBalance();
    await loadTransactionHistory();
  }

  @override
  void initState() {
    super.initState();
    getTheme();
    future = loading();
    timer = Timer.periodic(
      const Duration(seconds: 1), // 3초 마다 자동 갱신
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
          contentPadding: EdgeInsets.zero,
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
                const SizedBox(height: 15),
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
                        ),
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const KlayWithdraw()
                                      )
                                    );
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget> [
                        Text(
                          "거래 내역",
                          style: Theme.of(context).textTheme.headline6?.apply(
                            color: Colors.black,
                            fontWeightDelta: 2,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        ElevatedButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget> [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "$selected_type · $selected_period",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.0),
                              side: const BorderSide(
                                color: Colors.white24,
                              ),
                            ),
                            elevation: 0,
                            primary: Colors.white24,
                          ),
                          onPressed: () {
                            showModalBottomSheetWidget();
                          },
                        ),
                      ],
                    ),
                    Divider(
                      height: 31,
                      color: Colors.grey[400],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (ctx, i) {
                          return TransactionContainer(i: i);
                        }
                      )
                    ),
                  ]
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

  Future<dynamic> showModalBottomSheetWidget() async {
    return await showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, bottomState) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget> [
                        IconButton(
                          onPressed: () {
                            selected_type = prev_selected_type;
                            selected_period = prev_selected_period;
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "조회 선택",
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            prev_selected_type = selected_type;
                            prev_selected_period = selected_period;
                            setState(() {});
                            loadTransactionHistory();
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "완료",
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 17,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        "유형",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 17,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget> [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_type == "전체" ? Colors.lightBlue[50] : Colors.grey[200],
                                child: Text(
                                  "전체",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 10,
                                    color: selected_type == "전체" ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_type = "전체";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_type == "KLAY 입금" ? Colors.lightBlue[50] : Colors.grey[100],
                                child: Text(
                                  "KLAY 입금",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 9,
                                    color: selected_type == "KLAY 입금" ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_type = "KLAY 입금";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_type == "KLAY 출금" ? Colors.lightBlue[50] : Colors.grey[100],
                                child: Text(
                                  "KLAY 출금",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 9,
                                    color: selected_type == "KLAY 출금" ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_type = "KLAY 출금";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_type == "티켓 구매" ? Colors.lightBlue[50] : Colors.grey[100],
                                child: Text(
                                  "티켓 구매",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 10,
                                    color: selected_type == "티켓 구매" ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_type = "티켓 구매";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_type == "티켓 판매" ? Colors.lightBlue[50] : Colors.grey[100],
                                child: Text(
                                  "티켓 판매",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 10,
                                    color: selected_type == "티켓 판매" ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_type = "티켓 판매";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        "기간",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 17,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget> [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_period == "1주일" ? Colors.lightBlue[50] : Colors.grey[200],
                                child: Text(
                                  "1주일",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 16,
                                    color: selected_period == "1주일" ? Colors.black : Colors.grey[400],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_period = "1주일";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_period == "1개월" ? Colors.lightBlue[50] : Colors.grey[100],
                                child: Text(
                                  "1개월",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 16,
                                    color: selected_period == "1개월" ? Colors.black : Colors.grey[400],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_period = "1개월";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: CupertinoButton( // 복사 버튼
                                borderRadius: BorderRadius.circular(15),
                                color: selected_period == "3개월" ? Colors.lightBlue[50] : Colors.grey[100],
                                child: Text(
                                  "3개월",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 16,
                                    color: selected_period == "3개월" ? Colors.black : Colors.grey[400],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                      selected_period = "3개월";
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        }
    );
  }
}