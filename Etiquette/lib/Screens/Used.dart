import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Used extends StatefulWidget {
  State<StatefulWidget> createState() => _Used();
}

class _Used extends State<Used> {
  List<String> filter = ['All', 'High', 'Row', 'Recent', 'Old'];
  String _selected = 'All';

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("List of used tickets", style: TextStyle(fontSize: 25)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Get.back();
              //Navigator.pop(context);
            },
          ),
          elevation: 0,
          backgroundColor: Colors.white24,
          foregroundColor: Colors.black,
        ),
        body: Container(
            width: double.infinity,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 20),
            child: Column(children: <Widget>[
              SizedBox(height: 20),
              Container(
                  width: 150,
                  height: 60,
                  child: DropdownButtonFormField(
                    //style : TextStyle(fontSize : 15),
                    icon: Icon(Icons.expand_more),
                    decoration: InputDecoration(
                        //filled : true,
                        //fillColor: Hexcolor('#ecedec'),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey)),
                        labelStyle: TextStyle(color: Colors.grey),
                        labelText: 'Filter',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                    value: _selected,
                    items: filter.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (dynamic value) {
                      setState(() {
                        _selected = value;
                      });
                    },
                  ))
            ])));
  }
}
