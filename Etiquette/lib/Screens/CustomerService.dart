import 'package:flutter/material.dart';


class Customer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Customer();
}

class _Customer extends State<Customer>{
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String? title;
    String? question;
    return Scaffold(
      appBar: AppBar(
        title: Text("1:1 Customer Service"),
        backgroundColor: Colors.white24,
        foregroundColor: Colors.black,
        elevation: 0,),
      body: SingleChildScrollView(
        child: Padding(
        padding : EdgeInsets.fromLTRB(width*0.05, 0, width*0.05, 0),
        child : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        Text("제목 : "),
                        Expanded(
                            child: TextField(
                                onChanged: (text) {
                                  setState(() {
                                    title = text;
                                  });
                                }
                            )
                        )

                      ],
                    ),
                    SizedBox(height : height*0.05),
                    Text("문의내용"),
                    SizedBox(height : height*0.02),
                    TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width : 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width : 1.0),
                        ),

                      ),
                      maxLines: null,
                        minLines: 23,
                        onChanged: (text) {
                          setState(() {
                            question = text;
                          });
                        }
                    ),
                    SizedBox(height : height*0.02),
                  ],
                ),
        ),
      ),
                    bottomNavigationBar: Container(
    padding : EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, 0),
    child: ElevatedButton(
    child: const Text("문의 보내기"),
    style: ElevatedButton.styleFrom(
    elevation: 0,
    shadowColor: Colors.transparent,
    primary: Color(0xffEE3D43),
    shape: RoundedRectangleBorder(
    borderRadius:
    BorderRadius.circular(9.5)),
    minimumSize: Size.fromHeight(height * 0.062),

    ),
    onPressed: () async {

    }
    ),
    )
    );
  }
}