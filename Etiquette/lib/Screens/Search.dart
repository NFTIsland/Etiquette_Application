import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  State<StatefulWidget> createState() => _Search();
}

class _Search extends State<Search> {
  String find = "";
  var color;

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Container(
                        width: double.infinity,
                        child: Column(children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  color: Colors.black,
                                  onPressed: () {
                                    /*DB로 대상 탐색*/
                                  }),
                              hintText: "Search",
                            ),
                            onChanged: (text) {
                              setState(() {
                                find = text;
                              });
                            },
                          ),
                        ]))))));
  }
}
