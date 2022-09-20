import 'package:flutter/material.dart';
const darkBlue = Color(0xff00008b);

// deposit(klay 입금), withdraw(klay 출금), buy(티켓 구매), sell(티켓 판매)
List<Map<String, dynamic>> transactions = [];

class TransactionContainer extends StatelessWidget {
  final int i;
  const TransactionContainer({Key? key, required this.i,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Row(
          children: <Widget> [
            Visibility(
              visible: transactions[i]['transferType'] == "KLAY 출금",
              child: const Icon(
                Icons.upload,
                color: Colors.red,
              ),
            ),
            Visibility(
              visible: transactions[i]['transferType'] == "KLAY 입금",
              child: const Icon(
                Icons.download,
                color: Color(0xff4bc46d),
              ),
            ),
            Visibility(
              visible: transactions[i]['transferType'] == "티켓 판매",
              child: const Icon(
                Icons.monetization_on_rounded,
                color: darkBlue,
              ),
            ),
            Visibility(
              visible: transactions[i]['transferType'] == "티켓 구매",
              child: const Icon(
                Icons.add_card,
                color: darkBlue,
              ),
            ),
            const SizedBox(width: 10),
            Visibility(
              visible: transactions[i]['transferType'] == "KLAY 출금",
              child: Expanded(
                child: Text(
                  "KLAY 출금",
                  style: Theme.of(context).textTheme.subtitle1?.apply(
                      color: Colors.red,
                      fontWeightDelta: 2
                  ),
                ),
              )
            ),
            Visibility(
              visible: transactions[i]['transferType'] == "KLAY 입금",
              child: Expanded(
                child: Text(
                  "KLAY 입금",
                  style: Theme.of(context).textTheme.subtitle1?.apply(
                      color: const Color(0xff4bc46d),
                      fontWeightDelta: 2
                  ),
                ),
              )
            ),
            Visibility(
              visible: transactions[i]['transferType'] == "티켓 판매",
              child: Expanded(
                child: Text(
                  "티켓 판매",
                  style: Theme.of(context).textTheme.subtitle1?.apply(
                      color: darkBlue,
                      fontWeightDelta: 2
                  ),
                ),
              )
            ),
            Visibility(
              visible: transactions[i]['transferType'] == "티켓 구매",
              child: Expanded(
                child: Text(
                  "티켓 구매",
                  style: Theme.of(context).textTheme.subtitle1?.apply(
                      color: darkBlue,
                      fontWeightDelta: 2
                  ),
                ),
              )
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 9.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: const Color(0xffd5d7dc),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                "${transactions[i]['kind']}",
                style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Visibility(
          visible: transactions[i]['transferType'] == "KLAY 입금",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget> [
              Text(
                "입금 금액",
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.grey[400],
                ),
              ),
              Text(
                "${transactions[i]['value']} KLAY",
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.bold,
                  color: Color(0xff4bc46d),
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: transactions[i]['transferType'] == "KLAY 출금",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget> [
              Text(
                "출금 금액",
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.grey[400],
                ),
              ),
              Text(
                "${transactions[i]['value']} KLAY",
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: transactions[i]['transferType'] == "티켓 판매",
          child: Column(
            children: <Widget> [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Text(
                    "티켓 이름",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    "${transactions[i]['product_name']}",
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Text(
                    "장소",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    "${transactions[i]['place']}",
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Text(
                    "좌석 정보",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    "${transactions[i]['seat_class']}석 ${transactions[i]['seat_No']}번",
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                    ),
                  )
                ],
              ),
            ],
          )
        ),
        Visibility(
          visible: transactions[i]['transferType'] == "티켓 구매",
          child: Column(
            children: <Widget> [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Text(
                    "티켓 이름",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    "${transactions[i]['product_name']}",
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Text(
                    "장소",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    "${transactions[i]['place']}",
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Text(
                    "좌석 정보",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    "${transactions[i]['seat_class']}석 ${transactions[i]['seat_No']}번",
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                    ),
                  )
                ],
              ),
            ],
          )
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget> [
            Text(
              "완료 일시",
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.grey[400],
              ),
            ),
            Text(
              "${transactions[i]['date']}",
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
        Divider(
          height: 21,
          color: Colors.grey[400],
        ),
      ],
    );
  }
}