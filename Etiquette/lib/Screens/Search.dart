import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Search();
}

class _Search extends State<Search> {
  String find = "";
  var color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Container(
                        width: double.infinity,
                        child: Column(
                            children: <Widget> [
                              TextField(
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                  suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      color: Colors.black,
                                      onPressed: () {
                                        /* DB로 대상 탐색 */
                                      }),
                                  hintText: "Search",
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    find = text;
                                  });
                                },
                              ),
                            ]
                        )
                    )
                )
            )
        )
    );
  }
}
