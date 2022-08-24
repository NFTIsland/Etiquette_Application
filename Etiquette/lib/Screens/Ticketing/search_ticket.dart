import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Screens/Ticketing/ticket_details.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';

class TicketingList extends StatefulWidget {
  const TicketingList({Key? key}) : super(key: key);

  @override
  State createState() => _TicketingList();
}

class _TicketingList extends State<TicketingList> {
  List list = [];
  late final Future future;

  final inputTicketNameController = TextEditingController();

  Future<void> getMarketTicketsFromDB() async {
    list = new List.empty(growable: true);
    const url = "$SERVER_IP/ticketInfo";
    try {
      var res = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(res.body);
      if (res.statusCode == 200) {
        List tickets = data["data"];
        for (Map<String, dynamic> ticket in tickets) {
          Map<String, dynamic> ex = {
            'product_name': ticket['product_name'],
            'place': ticket['place'],
          };
          list.add(ex);
        }
      } else {
        int statusCode = res.statusCode;
        String msg = data['msg'];
        displayDialog_checkonly(context, "티켓팅", "statusCode: $statusCode\n\nmessage: $msg");
      }
    } catch (ex) {
      print("티켓팅 --> ${ex.toString()}");
    }
  }

  @override
  void initState(){
    super.initState();
    future = getMarketTicketsFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Ticketing"),
                backgroundColor: Colors.white24,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              body: Column(
                children: <Widget> [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 18, right: 18),
                          child: Column(
                            children: <Widget> [
                              Column(
                                children: <Widget> [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                    child: TextField(
                                      keyboardType: TextInputType.emailAddress,
                                      controller: inputTicketNameController,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '티켓 이름',
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        focusedBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.blueAccent,
                                            )
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).accentColor,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          color: Theme.of(context).accentColor,
                                          icon: const Icon(
                                              Icons.search,
                                              size: 30
                                          ),
                                          onPressed: () async {

                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => TicketDetails(
                                                      product_name: list[index]['product_name'],
                                                      place: list[index]['place'],
                                                    )
                                                )
                                            );
                                          },
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget> [
                                                Expanded(
                                                  flex: 2,
                                                  child: Image.network(
                                                      'https://metadata-store.klaytnapi.com/bfc25e78-d5e2-2551-5471-3391b813e035/b8fe2272-da23-f1a0-ad78-35b6b349125a.jpg',
                                                      width: 50,
                                                      height: 50
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: <Widget> [
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        list[index]['product_name'],
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        list[index]['place'],
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      // Text(
                                                      //   "${list[index]['first_date']} ~ ${list[index]['last_date']}",
                                                      //   style: const TextStyle(
                                                      //     fontSize: 15,
                                                      //   ),
                                                      // ),
                                                      // const SizedBox(height: 5),
                                                      // Text(
                                                      //   list[index]['place'],
                                                      //   style: const TextStyle(
                                                      //     fontSize: 20,
                                                      //   ),
                                                      // ),
                                                      // const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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