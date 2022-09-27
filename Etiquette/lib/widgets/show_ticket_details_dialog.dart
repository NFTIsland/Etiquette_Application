import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Etiquette/Utilities/time_remaining_until_end.dart';
import 'package:Etiquette/Utilities/add_comma_to_number.dart';

Future<void> showTicketDetailsDialog(
    BuildContext context,
    double _width,
    double _height,
    String product_name,
    String place,
    String performance_date,
    String seat_class,
    String seat_No,
    String auction_end_date,
    int count,
    int? max,
    Color confirmedButtonColor
    ) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "티켓 정보",
              style: TextStyle(
                fontFamily: "Pretendard",
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Colors.black,
              ),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(32.0),
            ),
          ),
          content: SizedBox(
            height: 360,
            width: _width - 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text(
                  product_name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pretendard',
                    fontSize: product_name.length >= 11 ? 15 : 20,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: Row(
                    children: <Widget> [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        place,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: Row(
                    children: <Widget> [
                      const Icon(
                        Icons.calendar_month,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        performance_date.substring(0, 10).replaceAll("-", ".") + " " + performance_date.substring(11, 16),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [
                      const Icon(
                        Icons.event_seat_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            Text(
                              "좌석 정보",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$seat_class석 $seat_No번",
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [
                      const Icon(
                        Icons.access_alarms_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            Text(
                              "경매 마감 날짜",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              auction_end_date.substring(0, 10).replaceAll("-", ".") + " " + auction_end_date.substring(11, 16),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            Text(
                              "남은 시간",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              timeRemainingUntilEnd(auction_end_date),
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.bold,
                                color: (int.parse(timeRemainingUntilEnd(auction_end_date).split("일")[0])) < 1 ? Colors.red : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [
                      count! >= 2 ?
                      const Icon(
                        Icons.people,
                        size: 18,
                      ) :
                      const Icon(
                        Icons.person,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            Text(
                              "현재 입찰자 수",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${count.toString()}명",
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [
                      const Icon(
                        Icons.money,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            Text(
                              "현재 최고 입찰가",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              max != null ? "${max.toString().replaceAllMapped(reg, mathFunc)} 원" : "-",
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.fromLTRB(_width * 0.03, _height * 0.01, _width * 0.03, _height * 0.011),
                  width: _width,
                  height: 80,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(10),
                    borderRadius: BorderRadius.circular(50),
                    color: confirmedButtonColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "확인",
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
  );
}