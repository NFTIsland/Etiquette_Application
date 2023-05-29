import 'package:flutter/material.dart';
import 'package:Etiquette/Screens/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Providers/KAS/Wallet/get_balance.dart';
import 'package:Etiquette/Providers/KAS/Wallet/klay_transaction.dart';
import 'package:Etiquette/Providers/DB/get_UserInfo.dart';

class KlayWithdraw extends StatefulWidget {
  const KlayWithdraw({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KlayWithdraw();
}

class _KlayWithdraw extends State<KlayWithdraw> {
  late final Future future;
  late bool theme;
  final inputValueController = TextEditingController();
  final inputReceiverAddressController = TextEditingController();
  double klay = 0.0;
  late final senderAddress;

  final warningMessageTitle = "주의사항";
  final warningMessage1 = "수신자의 주소가 ";
  final warningMessage2 = "Klaytn 주소";
  final warningMessage3 = "가 맞는지 다시 한번 확인해 주세요. 출금이 진행된 이후에는 되돌릴 수 없습니다.\n\n출금 시 송신자로부터 0.000525 KLAY의 수수료가 발생합니다.";

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> processGetBalance() async {
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      senderAddress = kas_address_data['data'][0]['kas_address'];
      final data = await getBalance(senderAddress);
      if (data["statusCode"] == 200) {
        String _klay = data["data"];
        klay = double.parse(_klay);
        klay = roundDouble(klay, 2);
        setState(() {

        });
      } else {
        String msg = data["msg"];
        String errorMessage = "KAS 계정 잔액 확인에 실패했습니다.\n\n$msg";
        displayDialog_checkonly(context, "KAS 계정 잔액 확인", errorMessage);
        setState(() {
          klay = 0.0;
        });
      }
    } else {
      String message = kas_address_data["msg"];
      String errorMessage = "잔액 정보를 가져오지 못했습니다.\n\n$message";
      displayDialog_checkonly(context, "통신 오류", errorMessage);
    }
  }

  Future<void> processWithdraw() async {
    if (inputReceiverAddressController.text == "") {
      displayDialog_checkonly(context, "KLAY 출금", "수신자 주소가 입력되지 않았습니다.");
    } else if (inputValueController.text == "") {
      displayDialog_checkonly(context, "KLAY 출금", "출금 금액을 입력해주세요.");
    } else {
      final data = await klayTransaction(senderAddress, inputValueController.text, inputReceiverAddressController.text);
      if (data["statusCode"] == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("KLAY 출금"),
            content: const Text("KLAY 출금이 완료되었습니다."),
            actions: <Widget> [
              TextButton(
                onPressed: () => {
                  Navigator.of(context).pop(),
                },
                child: const Text("확인"),
              )
            ],
          )
        );
      } else {
        int statusCode = data["statusCode"];
        String message = data["msg"];
        String errorMessage = "KLAY 출금에 실패했습니다.\n\nstatus code: $statusCode\nmessage: $message";
        displayDialog_checkonly(context, "KLAY 출금", errorMessage);
      }
    }
  }

  Future<void> loading() async {
    await processGetBalance();
    await getTheme();
  }

  @override
  void initState() {
    super.initState();
    future = loading();
    // future = processGetBalance();
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
            appBar: appbarWithArrowBackButton("Wallet", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("KLAY 출금", theme),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    const Text(
                      "출금 주소, 출금 수량을 입력해 주세요",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        maxLength: 42,
                        controller: inputReceiverAddressController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '주소 입력',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Pretendard',
                          ),
                          labelText: '출금 주소',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontFamily: 'Quicksand',
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: () async {
                              final qrCodeScanResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const QRCodeScanner()
                                ),
                              );
                              inputReceiverAddressController.text = qrCodeScanResult!;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          counterText: "",
                        )
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (amount) {
                        setState(() {
                          int? _parse = int.tryParse(amount);
                          if (_parse != null) {
                            if (_parse > (klay - 0.01)) {
                              inputValueController.text = (klay - 0.01).toString();
                            }
                          }
                        });
                      },
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      maxLength: 11,
                      controller: inputValueController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                          hintText: '수량 입력',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Pretendard',
                          ),
                          labelText: '출금 수량',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontFamily: 'Pretendard',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          counterText: "",
                          suffixText: "KLAY",
                          suffixStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "Quicksand",
                            color: Colors.grey[600],
                          )
                      ),
                    ),
                    Divider(
                      height: 40,
                      color: Colors.grey[400],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            const Text(
                              "출금 가능 수량",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            Text(
                              "${(klay - 0.01).toString().replaceAllMapped(reg, mathFunc)} KLAY",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        )
                    ),
                    Divider(
                      height: 40,
                      color: Colors.grey[400],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget> [
                          Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                  const Text(
                                    "수수료",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  Text(
                                    "0.00525 KLAY",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                ],
                              )
                          ),
                          Divider(
                            height: 40,
                            color: Colors.grey[400],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                  RichText(
                                    text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "총 출금 수량",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                          TextSpan(
                                            text: "(수수료 포함)",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  Text(
                                      double.tryParse(inputValueController.text) == null
                                          ? "0.00525 KLAY"
                                          : "${roundDouble((double.parse(inputValueController.text) + 0.00525), 5)} KLAY",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: 'Pretendard',
                                      )
                                  )
                                ],
                              )
                          ),
                        ],
                      ),
                    )
                  ]
              ),
            ),
            bottomNavigationBar: Container(
              padding : EdgeInsets.fromLTRB(width * 0.03, height * 0.01, width * 0.03, height * 0.011),
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget> [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                    ),
                    Text(
                      " 전송",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.5)
                  ),
                  minimumSize: Size.fromHeight(height * 0.062),
                  primary: const Color(0xffEE3D43),
                ),
                onPressed: () async {
                  // final selected = await displayDialog_YesOrNo(context, "KLAY 출금", "수신자 주소가 Klaytn 주소가 맞는지 다시 한번 확인해 주세요.\n\n출금이 이루어진 이후에는 되돌릴 수 없습니다.\n\nKLAY 출금을 진행하시겠습니까?");
                  final selected = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "KLAY 출금",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      content: RichText(
                        text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "수신자 주소가 Klaytn 주소가 맞는지 다시 한번 확인해 주세요.\n\n",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              TextSpan(
                                text: "출금이 이루어진 이후에는 되돌릴 수 없습니다.\n\n",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              TextSpan(
                                text: "KLAY 출금을 진행하시겠습니까?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ]
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (selected) {
                    processWithdraw();
                  }
                },
              ),
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

