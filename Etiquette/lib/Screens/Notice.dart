import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Etiquette/Models/Settings.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';
import 'package:Etiquette/widgets/appbar.dart';

class Notice extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Notice();
}

class _Notice extends State<Notice>{
  List titles = [];
  List upload_times = [];
  List contents = [];
  bool theme = false;
  Future<void> getHomeNotices() async {
    const url = "$SERVER_IP/screen/homeNotices";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        for (var _title in data['data']) {
          titles.add(_title['title']);
          contents.add(_title['contents']);
          upload_times.add(_title['upload_time'].toString());
        }

      } else {
        String msg = data['msg'];
        displayDialog_checkonly(context, "Home", msg);
      }
    } catch (ex) {
      displayDialog_checkonly(context, "Home", "네트워크 상태가 원활하지 않습니다.");
    }
  }

  Future<bool> getTheme() async {
    var key = 'theme';
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = (pref.getBool(key) ?? false);
    return theme;
  }

  Future<void> _fetchData() async {
      await getHomeNotices();
      await getTheme();
  }


  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future : _fetchData(),
      builder : (context, snapshot){
        if(snapshot.hasError){
          return Scaffold(
            appBar: appbarWithArrowBackButton("Home", theme),
            body: const Center(
              child: Text("통신 에러가 발생했습니다."),
            ),
          );
        }
        if(snapshot.connectionState == ConnectionState.done){
          return Scaffold(
            appBar: AppBar(
              title: Text("Notice"),
              backgroundColor: Colors.white24,
              foregroundColor: Colors.black,
              elevation: 0,),
            body: SingleChildScrollView(
              child: Column(
                children : [
                  ListView.separated(
                      separatorBuilder:
                          (BuildContext context, int index) =>
                      const Divider(thickness: 2),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        return Theme(
                            data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent),
                            child: ListTile(
                              //backgroundColor: Colors.white,
                              //collapsedBackgroundColor: Colors.white,
                                title: Text(titles[index],
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: (theme
                                            ? const Color(0xff000000)
                                            : const Color(0xff000000)),
                                        overflow: TextOverflow.ellipsis)),
                                subtitle: Text(upload_times[index],
                                    style: TextStyle(
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: (theme
                                            ? const Color(0xff000000)
                                            : const Color(0xff000000)),
                                        overflow: TextOverflow.ellipsis)),
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoticePage(title : titles[index], uploads_time: upload_times[index], contents: contents[index], theme : theme),
                                  ),
                                );
                              },
                            ),
                        );
                      }),
                ]
              )


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

class NoticePage extends StatefulWidget{
  String? title;
  String? uploads_time;
  String? contents;
  bool theme = false;
  NoticePage({
    Key? key,
    required this.title,
    required this.uploads_time,
    required this.contents,
    required this.theme,
}) : super(key:key);

@override
  State<StatefulWidget> createState() => _NoticePage();

}
class _NoticePage extends State<NoticePage>{
  Widget build(BuildContext context){

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar:AppBar(title: Text("Notice"),backgroundColor: Colors.white24,
          foregroundColor: Colors.black,
          elevation: 0, ),
        body : SingleChildScrollView(
          child : Padding(
            padding: EdgeInsets.fromLTRB(width*0.05, height * 0.03, width*0.05,0),
            child :
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("${widget.title}", style: TextStyle(
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: (widget.theme
                    ? const Color(0xff000000)
                    : const Color(0xff000000)),
                overflow: TextOverflow.ellipsis)),
                Text("${widget.uploads_time}", style: TextStyle(
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: (widget.theme
                        ? const Color(0xff000000)
                        : const Color(0xff000000)),
                    overflow: TextOverflow.ellipsis)),
                SizedBox(height : height * 0.025),
                Divider(thickness: 1,),
                SizedBox(height : height * 0.025),
                Text("${widget.contents}",
                    style : TextStyle( fontFamily: "NotoSans",
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: (widget.theme
                            ? const Color(
                            0xff000000)
                            : const Color(
                            0xff000000)
                        )
                    )
                )
          ],
        )
    )
    )
    );
  }
}

