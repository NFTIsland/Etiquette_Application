import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Etiquette/Screens/Account.dart';
import 'package:Etiquette/Screens/Drawer/Bid.dart';
import 'package:Etiquette/Screens/Drawer/Hold.dart';
import 'package:Etiquette/Screens/Drawer/Interest.dart';
import 'package:Etiquette/Screens/Drawer/Selling.dart';
import 'package:Etiquette/Screens/Drawer/Used.dart';
import 'package:Etiquette/Screens/Wallet/Wallet.dart';
import 'package:Etiquette/Screens/Login.dart';
import 'package:Etiquette/widgets/alertDialogWidget.dart';
import 'package:Etiquette/Models/serverset.dart';

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
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Account()
                //     )
                // );
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
            ListTile(
              title: const Text('Wallet'),
              onTap: () {
                Get.to(
                  () => const Wallet(),
                );
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Wallet()
                //     )
                // ); // 네비게이션 필요
              },
            ),
            ListTile(
              title: const Text('List of holding tickets'),
              onTap: () {
                Get.to(
                  () => const Hold(),
                  arguments: nickname
                );
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Hold()
                //     )
                // ); // 네비게이션 필요
              },
            ),
            ListTile(
              title: const Text('Interest Tickets'),
              onTap: () {
                Get.to(() => Interest());
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Interest()
                //     )
                // );
              },
            ),
            ListTile(
              title: const Text('Bid Tickets'),
              onTap: () {
                Get.to(() => Bid());
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Bid()
                //     )
                // );
              },
            ),
            ListTile(
              title: const Text('Selling Tickets'),
              onTap: () {
                Get.to(() => Selling());
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Selling()
                //     )
                // );
              },
            ),
            ListTile(
              title: const Text('List of used tickets'),
              onTap: () {
                Get.to(() => const Used());
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Used()
                //     )
                // );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                try {
                  final selected = await displayDialog_YesOrNo(context, "로그아웃", "로그아웃 하시겠습니까?");
                  if (selected) {
                    await storage.deleteAll();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ), (route) => false
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