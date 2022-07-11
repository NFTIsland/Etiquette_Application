import 'dart:convert';
import 'package:http/http.dart' as http;

Map<String, String> headers = {
  "Content-Type": "application/json",
  "x-chain-id": "1001",
  "Authorization": "Basic ", // basic authentication
};

Future<void> getBalance() async {
  var res = await http.post(Uri.parse("https://node-api.klaytnapi.com/v1/klaytn"), body: jsonEncode ({
    "id": 1,
    "jsonrpc": "2.0",
    "method": "klay_getBalance",
    "params": [address, "latest"]
  }), headers: headers);

  if (res.statusCode == 200) {
    print(res.body);
    var data = json.decode(res.body);
    String balance_hex = data["result"];
    // hex to number conversion code here

  } else {
    print("Error");
  }
}