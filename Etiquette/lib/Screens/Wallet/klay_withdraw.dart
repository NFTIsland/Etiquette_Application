import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Etiquette/Screens/qr_code_scanner.dart';
import 'package:Etiquette/widgets/appbar.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/Utilities/round.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';
import 'package:Etiquette/Providers/KAS/Wallet/get_balance.dart';
import 'package:Etiquette/Providers/KAS/Wallet/klay_transaction.dart';
import 'package:Etiquette/Providers/DB/get_kas_address.dart';

class KlayWithdraw extends StatefulWidget {
  const KlayWithdraw({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KlayWithdraw();
}

class _KlayWithdraw extends State<KlayWithdraw> {
  late final Future future;

  final inputValueController = TextEditingController();
  final inputReceiverAddressController = TextEditingController();
  String klay = "잔액: ";
  late final senderAddress;

  final warningMessageTitle = "주의사항";
  final warningMessage1 = "수신자의 주소가 ";
  final warningMessage2 = "Klaytn 주소";
  final warningMessage3 = "가 맞는지 다시 한번 확인해 주세요. 출금이 진행된 이후에는 되돌릴 수 없습니다.\n\n출금 시 송신자로부터 0.000525 KLAY의 수수료가 발생합니다.";

  Future<void> processGetBalance() async {
    Map<String, dynamic> kas_address_data = await getKasAddress();
    if (kas_address_data['statusCode'] == 200) {
      senderAddress = kas_address_data['data'][0]['kas_address'];
      final data = await getBalance(senderAddress);
      if (data["statusCode"] == 200) {
        klay = data["data"];
        double _klay = double.parse(klay);
        _klay = roundDouble(_klay, 2);
        setState(() {
          klay = "잔액: ${_klay.toString().replaceAllMapped(reg, mathFunc)} KLAY";
        });
      } else {
        int statusCode = data["statusCode"];
        String message = data["msg"];
        String errorMessage = "KAS 계정 잔액 확인에 실패했습니다.\n\nstatus code: $statusCode\nmessage: $message";
        displayDialog_checkonly(context, "KAS 계정 잔액 확인", errorMessage);
        setState(() {
          klay = "잔액: ";
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

  @override
  void initState() {
    super.initState();
    future = processGetBalance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: appbarWithArrowBackButton("Wallet"),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: defaultAppbar("KLAY 출금"),
            body: Column(
              children: <Widget> [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: <Widget> [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            child: Text(
                              klay,
                              style: const TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Text(
                              "수신자 주소",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: inputReceiverAddressController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                hintText: '수신자 주소',
                                hintStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)
                                    ),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.blueAccent,
                                    )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  color: Theme.of(context).accentColor,
                                  icon: const Icon(
                                      Icons.qr_code,
                                      size: 30
                                  ),
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
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Text(
                              "출금할 KLAY 양",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter(
                                  RegExp('[0-9.]'),
                                  allow: true,
                                ),
                                FilteringTextInputFormatter(
                                  RegExp('.'),
                                  allow: true,
                                ),
                              ],
                              controller: inputValueController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                hintText: '출금할 KLAY 양',
                                hintStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)
                                    ),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.blueAccent,
                                    )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Text(
                              warningMessageTitle,
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                            child: RichText(
                                text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    children: <TextSpan> [
                                      TextSpan(
                                        text: warningMessage1,
                                      ),
                                      TextSpan(
                                          text: warningMessage2,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          )
                                      ),
                                      TextSpan(
                                        text: warningMessage3,
                                      ),
                                    ]
                                )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget> [
                                ElevatedButton (
                                  child : const Text("출금"),
                                  style : ElevatedButton.styleFrom(
                                      primary : Colors.deepPurpleAccent
                                  ),
                                  onPressed: () async {
                                    final selected = await displayDialog_YesOrNo(context, "KLAY 출금", "수신자 주소가 Klaytn 주소가 맞는지 다시 한번 확인해 주세요.\n\n출금이 이루어진 이후에는 되돌릴 수 없습니다.\n\nKLAY 출금을 진행하시겠습니까?");

                                    if (selected) {
                                      processWithdraw();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}

