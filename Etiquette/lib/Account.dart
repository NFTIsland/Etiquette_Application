import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  State createState() => _Account();
}

class _Account extends State<Account> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("계정 정보"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white24,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body : Container(
        
      )

    );
  }
}
