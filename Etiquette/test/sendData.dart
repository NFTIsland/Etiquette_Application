import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // SHA-256 적용

String phpurl = "http://49.50.172.60/etiquette/write.php";

bool error = false;
bool sending = false;
bool success = false;
String msg = "";

Future<void> sendData() async { // DB로 id, pw 정보 전송
  var digest = sha256.convert(utf8.encode(pwController.text)).toString(); // pw에 hashing 적용(SHA-256 기반)

  var res = await http.post(Uri.parse(phpurl), body: {
    "id": idController.text,
    "pw": digest,
  }); //sending post request with header data

  if (res.statusCode == 200) {
    print(res.body); //print raw response on console
    var data = json.decode(res.body); //decoding json to array
    if(data["error"]){
      setState(() { //refresh the UI when error is recieved from server
        sending = false;
        error = true;
        msg = data["message"]; //error message from server
      });
    } else {
      idController.text = "";
      pwController.text = "";
      //after write success, make fields empty

      setState(() {
        sending = false;
        success = true; //mark success and refresh UI with setState
      });
    }
  } else {
    //there is error
    setState(() {
      error = true;
      msg = "Error during sending data.";
      sending = false;
      //mark error and refresh UI with setState
    });
  }
}