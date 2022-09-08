import 'package:Etiquette/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
class Bid extends StatefulWidget {
  State<StatefulWidget> createState() => _Bid();
}

class _Bid extends State<Bid> {
  List<String> filter = ['All', 'High', 'Row', 'Recent', 'Old'];
  String _selected = 'All';
  late bool theme;

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  @override
  void initState() {
    super.initState();
    getTheme();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future : getTheme(),
      builder : (context, snapshot){
        if(snapshot.hasError){
          return Center(child : Text("Error입니다!"));
        }
        else if(snapshot.connectionState == ConnectionState.done){
          return  Scaffold(
              appBar: appbarWithArrowBackButton("Bid Tickets", theme),
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
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
     );
  }
}
