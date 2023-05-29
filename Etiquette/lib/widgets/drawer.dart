import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Etiquette/Screens/Account.dart';
import 'package:Etiquette/Screens/Drawer/ChangeUserInfo.dart';
import 'package:Etiquette/Screens/Drawer/Bid.dart';
import 'package:Etiquette/Screens/Drawer/Hold.dart';
import 'package:Etiquette/Screens/Drawer/Interest.dart';
import 'package:Etiquette/Screens/Drawer/Selling.dart';
import 'package:Etiquette/Screens/Drawer/Used.dart';
import 'package:Etiquette/Screens/Wallet/Wallet.dart';
import 'package:Etiquette/Screens/Login.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Models/Settings.dart';

@override
Widget drawer(BuildContext context, bool theme, String? nickname) {
  return SafeArea(
    child: Drawer(
      child: ListView(
          padding: EdgeInsets.zero,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => Account());
              },
              child: UserAccountsDrawerHeader(
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  backgroundImage: AssetImage(
                    'assets/image/mainlogo.png',
                  ),
                ),
                accountName: Text(
                  nickname! + " 님 반갑습니다.",
                  style: const TextStyle(color: Colors.black),
                ),
                accountEmail: const Text(
                  "좋은 하루 보내세요.",
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
                decoration: BoxDecoration(
                    color: (theme ? const Color(0xffe8e8e8) : const Color(0xff7b9acc)),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    )
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 5.0),
              child: Text(
                '내 정보',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                '개인정보 변경',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.offAll(
                      () => const ChangeUserInfo(),
                );
              },
            ),
            Divider(
              height: 20,
              color: Colors.grey[600],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 5.0),
              child: Text(
                '자산',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance,),
              title: const Text(
                '보유자산',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.to(
                  () => const Wallet(),
                );
              },
            ),
            Divider(
              height: 20,
              color: Colors.grey[600],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 5.0),
              child: Text(
                '티켓',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text(
                '보유 티켓',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.to(
                  () => const Hold(),
                    arguments: nickname,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text(
                '관심 티켓',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.to(
                  () => const Interest(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.back_hand),
              title: const Text(
                '입찰 티켓',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.to(
                  () => const Bid(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on_outlined),
              title: const Text(
                '판매 중 티켓',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.to(
                  () => const Selling(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text(
                '사용 만료 티켓',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.to(
                  () => const Used(),
                );
              },
            ),
            Divider(
              height: 20,
              color: Colors.grey[600],
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                '로그아웃',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                try {
                  final selected = await displayDialog_YesOrNo(context, "로그아웃", "로그아웃 하시겠습니까?");
                  if (selected) {
                    await storage.deleteAll();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ), (route) => false,
                    );
                  }
                } catch (ex) {
                  return;
                }
              },
            ),
          ]
      ),
    ),
  );
}

Widget _createDrawerItem(IconData icon, String text, GestureTapCallback onTap) {
  return ListTile(
    title: Row(
      children: <Widget> [
        Icon(icon),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}