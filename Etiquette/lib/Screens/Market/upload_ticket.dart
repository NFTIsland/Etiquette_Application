import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:Etiquette/Screens/Market/load_holding_tickets.dart';
import 'package:Etiquette/Models/serverset.dart';
import 'package:Etiquette/Widgets/alertDialogWidget.dart';

class UploadTicket extends StatefulWidget {
  const UploadTicket({Key? key}) : super(key: key);

  @override
  State createState() => _UploadTicket();
}

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime? currentTime, LocaleType? locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(this.currentTime.minute);
    this.setRightIndex(this.currentTime.second);
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return "|";
  }

  @override
  String rightDivider() {
    return "|";
  }

  @override
  List<int> layoutProportions() {
    return [1, 2, 1];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        this.currentLeftIndex(),
        this.currentMiddleIndex(),
        this.currentRightIndex())
        : DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        this.currentLeftIndex(),
        this.currentMiddleIndex(),
        this.currentRightIndex());
  }
}

class _UploadTicket extends State<UploadTicket> {
  String token_id = "";
  String product_name = "";
  String place = "";
  String original_price = "";
  int end_year = 0;
  int end_month = 0;
  int end_day = 0;
  int end_hour = 0;
  int end_minute = 0;

  String auction_end_date = "";

  final start_price_controller = TextEditingController();
  final bid_unit_controller = TextEditingController();
  final immediate_purchase_price_controller = TextEditingController();
  final comments_controller = TextEditingController();

  Future<void> upload_ticket() async {
    const url = "$SERVER_IP/setTicketToBid";
    try {
      var res = await http.post(Uri.parse(url), body: {
        "token_id": token_id,
        "auction_start_price": start_price_controller.text,
        "bid_unit": bid_unit_controller.text,
        "immediate_purchase_price": immediate_purchase_price_controller.text,
        "auction_end_date": auction_end_date,
        "auction_comments": comments_controller.text
      });
      if (res.statusCode == 200) {
        displayDialog_checkonly(context, "티켓 업로드", "티켓 업로드가 성공적으로 완료되었습니다.");
      } else {
        displayDialog_checkonly(context, "티켓 업로드", "티켓 업로드에 실패했습니다.");
      }
    } catch (ex) {
      print("티켓 업로드 --> ${ex.toString()}");
      displayDialog_checkonly(context, "티켓 업로드", "티켓 업로드에 실패했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) { // NFT화 된 티켓 업로드
    return Scaffold(
      appBar: AppBar(
        title: const Text("티켓 업로드"),
        centerTitle: true,
        backgroundColor: Colors.white24,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon( // 뒤로가기 버튼
              Icons.arrow_back_ios_new_rounded
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final data = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoadHoldingTickets()
                                )
                            );
                            if (data != null) {
                              setState(() {
                                token_id = data["token_id"];
                                product_name = data["product_name"];
                                place = data["place"];
                                original_price = data["original_price"].toString();
                                end_year = int.parse(data["end_year"]);
                                end_month = int.parse(data["end_month"]);
                                end_day = int.parse(data["end_day"]);
                                end_hour = int.parse(data["end_hour"]);
                                end_minute = int.parse(data["end_minute"]);
                              });
                              print(DateTime(end_year, end_month, end_day, end_hour, end_minute));
                            }
                          },
                          child: const Text("티켓 불러오기"),
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                      child: Row(
                        children: <Widget> [
                          Text("티켓 이름: $product_name"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: Row(
                        children: <Widget> [
                          Text("장소: $place"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: Row(
                        children: <Widget> [
                          Text("원가: $original_price 원"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                      child: ElevatedButton(
                          onPressed: () {
                            if (product_name != "" && place != "" && original_price != "") {
                              final maxTime = DateTime(end_year, end_month, end_day, end_hour, end_minute).subtract(const Duration(hours: 3));
                              DatePicker.showDateTimePicker(
                                context,
                                showTitleActions: true,
                                minTime: DateTime.now().add(const Duration(minutes: 1)),
                                maxTime: maxTime,
                                onChanged: (date) {
                                  print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                },
                                onConfirm: (date) {
                                  if (date.isBefore(maxTime) || date.isAtSameMomentAs(maxTime)) {
                                    setState(() {
                                      auction_end_date = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00";
                                    });
                                  } else {
                                    displayDialog_checkonly(context, "티켓 업로드", "경매 마감 시각은 티켓 사용 시각으로부터 3시간 전 까지 선택 할 수 있습니다.");
                                  }
                                },
                                locale: LocaleType.ko,
                              );
                            } else {
                              displayDialog_checkonly(context, "티켓 업로드", "업로드 할 티켓을 선택해 주세요.");
                            }
                          },
                          child: const Text(
                            '경매 마감 날짜 및 시각 선택',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                      ),
                    ),
                    const Text("(티켓 사용 시각 3시간 전까지 선택 가능)"),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: Row(
                        children: <Widget> [
                          Text("경매 마감: $auction_end_date"),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: Row(
                        children: <Widget>[
                          const Text("경매 시작가: "),
                          Flexible(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: start_price_controller,
                            ),
                          ),
                          const Text("원"),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Text("(원가 이하만 입력 가능)"),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: Row(
                        children: <Widget>[
                          const Text("입찰 단위: "),
                          Flexible(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: bid_unit_controller,
                            ),
                          ),
                          const Text("원"),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Text("(100의 배수만 입력 가능)"),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: Row(
                        children: <Widget>[
                          const Text("즉시 거래가: "),
                          Flexible(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: immediate_purchase_price_controller,
                            ),
                          ),
                          const Text("원"),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Text("(원가 이하만 입력 가능)"),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: const Text("사용자 코멘트"),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Row(
                          children: <Widget> [
                            Flexible(
                              child: TextField(
                                maxLines: null,
                                maxLength: 500,
                                expands: true,
                                keyboardType: TextInputType.multiline,
                                controller: comments_controller,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 3, color: Colors.greenAccent)
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                      child: ElevatedButton(
                        child: const Text("티켓 업로드"),
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xffffb877),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          int _startPrice = int.parse(start_price_controller.text);
                          int _bidUnit = int.parse(bid_unit_controller.text);
                          int _immediatePurchasePrice = int.parse(immediate_purchase_price_controller.text);
                          int _originalPrice = int.parse(original_price);
                          if (_startPrice <= _originalPrice
                              && (_bidUnit % 100 == 0)
                              && _immediatePurchasePrice <= _originalPrice) {
                            if (comments_controller.text != "") {
                              final selected = await displayDialog_YesOrNo(context, "티켓 업로드", "위 옵션으로 티켓 업로드를 진행하시겠습니까?");

                              if (selected) {
                                upload_ticket();
                              }
                            } else {
                              displayDialog_checkonly(context, "티켓 업로드", "사용자 코멘트를 작성해 주십시오.");
                            }
                          } else {
                            displayDialog_checkonly(context, "티켓 업로드", "조건을 모두 만족하는지 확인해 주십시오.");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}