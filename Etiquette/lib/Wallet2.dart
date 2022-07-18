import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'Utilities/printlog.dart';
import 'Utilities/round.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  _Wallet createState() => _Wallet();
}

class _Wallet extends State<Wallet> {
  String lastCurrencyMsg = "Loading...";
  var klayBalance = "500.13";
  var wonString = "";
  String balanceAndWonMsg = "Loading...";

  Future<void> getKlayCurrencyAndBalance() async {
    String url = "https://api.coinone.co.kr/public/v2/ticker_new/KRW/KLAY";
    var res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var lastCurrency = data["tickers"][0]["last"];
      lastCurrencyMsg = "1 KLAY ≈ " + lastCurrency.toString() + "￦";
      double won = roundDouble(double.parse(klayBalance) * double.parse(lastCurrency), 1);
      balanceAndWonMsg = klayBalance + " KLAY ≈ " + won.toString() + "￦";
    } else {
      lastCurrencyMsg = "에러 발생";
      balanceAndWonMsg = "에러 발생";
    }
  }

  bool loading = false;

  void loadKlayCurrency() async {
    setState(() {
      loading = true; // I need to update the display here
    });

    await getKlayCurrencyAndBalance();

    setState(() {
      loading = false;
    });
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadKlayCurrency();

    timer = Timer.periodic (
      const Duration(seconds: 10), // 10초마다 자동 갱신
          (timer) {
        setState(() {
          printlog("Klay Currency Updated");
          getKlayCurrencyAndBalance();
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar : AppBar(title : const Text("Wallet",style : TextStyle(fontSize : 25)), backgroundColor: Colors.white24,foregroundColor: Colors.black, elevation: 0, centerTitle: true,
          leading: IconButton(
              onPressed: (){Navigator.pop(context);},
              icon : const Icon(Icons.arrow_back_ios_new_rounded)
          ),
        ),
        body :
        Container(
            width : double.infinity,
            child : Column (
                crossAxisAlignment: CrossAxisAlignment.center,
                children : <Widget>[
                  Column(
                      children : <Widget>[
                        Image.asset('assets/image/KlaytnLogo.png', width : 155, height : 155),
                        const SizedBox(height : 20),
                        Text(lastCurrencyMsg, style : const TextStyle(fontSize : 25,)),
                        Text(balanceAndWonMsg, style : const TextStyle(fontSize : 25,)),
                        const SizedBox(height : 20),
                        ElevatedButton(onPressed:(){}, child : const Text("Charge", style : TextStyle(fontSize : 20)),
                            style : ElevatedButton.styleFrom(primary : const Color(0xff7795FF), shape : RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),fixedSize: const Size(140,45) ))
                      ]
                  ),
                  const SizedBox(height : 20),
                  Container(
                      child : Column(
                          children : <Widget>[
                            const Text('History of Transaction', style : TextStyle(fontSize : 30, fontWeight : FontWeight.bold)),
                            const SizedBox(height : 20),
                            Container(
                                child :
                                Column(//거래내역
                                    children : <Widget>[
                                    ]
                                )
                            )
                          ]
                      )
                  )
                ]
            )
        )
    );
  }
}