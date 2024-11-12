import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/question.dart';
import 'main.dart';
import 'package:encrypt/encrypt.dart' as en;

//개인정보 암호화
final key=en.Key.fromUtf8(FlutterConfig.get('SecretCode'));
final iv =en.IV.allZerosOfLength(16);
final encrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc, padding: 'PKCS7'));

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<StatefulWidget> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  String? name = 'Null';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  String? email;
  String? names;
  String? platform;
  bool? isLogged;

  // DateTime now = DateTime.now();
  // Timestamp timestamp = Timestamp.fromDate(now);
  // Date
  //화면
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan, Colors.tealAccent],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(1.0, -1.0),
              end: AlignmentDirectional(-1.0, 1.0),
            ),
            shape: BoxShape.rectangle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 20, 0.0, 20),
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Stack(children: <Widget>[
                    Text(
                      '원데이 서울',
                      style: TextStyle(
                        fontFamily: 'Laundry',
                        letterSpacing: 0.0,
                        fontSize: 30,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Color(0xCE1A1A1A),
                      ),
                    ),
                    Text(
                      '원데이 서울',
                      style: TextStyle(
                        fontFamily: 'Laundry',
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontSize: 30,
                      ),
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 570.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Color(0x33000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '소셜 로그인',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 24.0),
                            child: Text(
                              '원하는 소셜 로그인을 선택하세요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                          //구글로그인 버튼
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: TextButton.icon(
                              onPressed: googleloginBtn,
                              label: Text('Continue with Google'),
                              icon: ImageIcon(
                                AssetImage('assets/image/google.png'),
                                size: 20.0,
                              ),
                            ),
                          ),
                          //네이버 로그인 버튼
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: TextButton.icon(
                              onPressed: () async {
                                await naverLoginBtn();
                              },
                              label: Text('Continue with Naver'),
                              icon: ImageIcon(
                                AssetImage('assets/image/naver.png'),
                                size: 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // var _propileImageUrl;

  // Future<void> isLooggedIN() async{
  //   if(userId != null && email != null && names != null){
  //     isLogged = true;
  //   } else{
  //     isLogged = false;
  //   }
  // }

  //네이버 로그인 api
  Future<void> naverLoginBtn() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn().timeout(
          Duration(seconds: 10),
          onTimeout: () => null as NaverLoginResult);
      print(result);
     if(result.status == NaverLoginStatus.loggedIn) {
       userId = result.account.id;
       email = encrypter.encrypt(result.account.email,iv: iv).base64;
       names = encrypter.encrypt(result.account.name,iv: iv).base64;
       // String imageUrl = result.account.profileImage ?? '';
       // _propileImageUrl = imageUrl;

       SharedPreferences prefs = await SharedPreferences.getInstance();
       final QuerySnapshot userSnapshot = await _firestore
           .collection("clients")
           .where("user_info.platform", isEqualTo: "Naver")
           .where("user_info.id", isEqualTo: userId)
           .where("user_info.email", isEqualTo: email)
           .where("user_info.name", isEqualTo: names)
           .get();

       if (userSnapshot.docs.isNotEmpty) {
         print("이미 ID가 있는 유저입니다.: ${userId}");
         isLogged = true;
         DocumentSnapshot docSnapshot =
         await _firestore.collection('clients').doc(userId).get();
         await prefs.setBool('login', isLogged!);
         await prefs.setString('type', docSnapshot.get('user_info')['type']);
         Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (context) => MyApp()),
                 (Route<dynamic> route) => false);
       } else {
         isLogged = true;
         await prefs.setBool('login', isLogged!);
         await _firestore.collection("clients").doc(userId).set({
           "user_info": {
             "platform": "Naver",
             "id": userId,
             "email": email,
             "name": names,
           },
           "travel_list": []
         });
         print("새로운 유저 아이디 추가:${userId}");

         Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (context) => Survey()),
                 (Route<dynamic> route) => false);
       }

       await prefs.setString('id', userId!);
       await prefs.setString('email', email!);
       await prefs.setString('name', names!);
       await prefs.setString('platform', "Naver");
     }
     else{
       print("error try again");
     }
    } catch (error) {
      print(error);
    }
  }


  //구글 로그인 api
  Future<void> googleloginBtn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("login Failed");
        return;
      }

      userId = googleUser.id;
      names = encrypter.encrypt(googleUser.displayName!,iv: iv).base64;
      email = encrypter.encrypt(googleUser.email,iv: iv).base64;

      final QuerySnapshot userSnapshot = await _firestore
          .collection("clients")
          .where("user_info.platform", isEqualTo: "Google")
          .where("user_info.id", isEqualTo: userId)
          .where("user_info.email", isEqualTo: email)
          .where("user_info.name", isEqualTo: names)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // DocumentSnapshot existingUser = userSnapshot.docs.first;
        print("이미 ID가 있는 유저 입니다. ID : ${userId}");
        isLogged = true;
        DocumentSnapshot docSnapshot =
            await _firestore.collection('clients').doc(userId).get();
        await prefs.setBool('login', isLogged!);
        await prefs.setString('type', docSnapshot.get('user_info')['type']);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
            (Route<dynamic> route) => false);
      } else {
        // final DocumentReference docRef =
        await _firestore.collection("clients").doc(userId).set({
          "user_info": {
            "email": email,
            "id": userId,
            "name": names,
            "platform": "Google",
          },
          "travel_list": []
        });
        print("새로운 유저 ID 추가 : ${userId}");
        isLogged = true;
        await prefs.setBool('login', isLogged!);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Survey()),
            (Route<dynamic> route) => false);
      }
    } catch (error) {
      print("Error during Google login: $error");
    }

    await prefs.setString('id', userId!);
    await prefs.setString('email', email!);
    await prefs.setString('name', names!);
    await prefs.setString('platform', 'Google');
  }
}
