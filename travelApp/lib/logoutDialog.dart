import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'mypage.dart';

void logoutdialog(BuildContext context) async {
  showDialog(context: context, builder: (BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("로그아웃하시겠습니까?",),
          content: Container(
            width: double.maxFinite,
            height: 5,
           ), // 팝업 창의 높이
          actions: [
            TextButton(
              onPressed: () async {
                LogoutService().logout();
                SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setBool('login', false);
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => loginPage()),
                        (Route<dynamic> route) => false);
              },
              child: Text('네'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text('아니요'),
            ),
          ],
        );
      },
    );
  });
}

void Resigndialog(BuildContext context) async {
  showDialog(context: context, builder: (BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("정말로 탈퇴 하시겠습니까?",),
          content: Container(
            width: double.maxFinite,
            height: 5,
            ), // 팝업 창의 높이
          actions: [
            TextButton(
              onPressed: () async {
                Withdraw().userWithdraw();
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => loginPage()),
                        (Route<dynamic> route) => false);
              },
              child: Text('네'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text('아니요'),
            ),
          ],
        );
      },
    );
  });
}