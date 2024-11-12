import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:travelapp/question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'loactionRating.dart';
import 'logoutDialog.dart';





class mypage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Mypage();
}

class _Mypage extends State<mypage> {
  String? userId;
  String names = '???';
  String email = 'SNS email';
  bool? isLogged;
  String? type;
  bool? traveling;
  final Map<String, String> images = {
    "예술 애호가": 'assets/image/공연장.png',
    "자연 사랑꾼": 'assets/image/공원.png',
    "문화 탐방자": 'assets/image/문화 거리.png',
    "미술 감상자": 'assets/image/미술관.png',
    "쇼핑 전문가": 'assets/image/쇼핑.png',
    "모험의 달인": 'assets/image/스포츠.png',
    "로컬 탐방자": 'assets/image/시장.png',
    "역사 애호가": 'assets/image/역사.png',
    "경치 감상가": 'assets/image/전망대.png'
  };


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    //개인정보 암호화
    final key=en.Key.fromUtf8(FlutterConfig.get('SecretCode'));
    final iv =en.IV.allZerosOfLength(16);
    final encrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc, padding: 'PKCS7'));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id');
      names =  prefs.getString('name')!;
      email =  prefs.getString('email')!;
      isLogged = prefs.getBool('login');
      type = prefs.getString('type');
      traveling = prefs.getBool('traveling');
    });
    try {
      setState(() {
        names = encrypter.decrypt64(names, iv: iv);
        email = encrypter.decrypt64(email, iv: iv);
      });
    }catch(e){
      print('복화화 시 : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFA6DBFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFA6DBFF),
          automaticallyImplyLeading: false,
          leading: IconButton(
            color: Colors.transparent,
            splashRadius: 30.0,
            iconSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xff007099),
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6AFFA4), Color(0xFFFFC82B)],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(1.0, -1.0),
                                end: AlignmentDirectional(-1.0, 1.0),
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Image.asset(
                                          images[type!]!,
                                          // Image.network(propileImageUrl!) as String,
                                          width: 90.0,
                                          height: 90.0,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 12.0),
                          child: Text(
                            '선호도테스트 결과\n${type!}', style: TextStyle(fontFamily: 'Laundry'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                child: Text('${names}님',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight:FontWeight.bold,
                      fontFamily: 'Outfit',
                      letterSpacing: 0.0,
                      color: Color(0xFF3C2393),
                    )),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 0.0),
                child: Text(
                  '${email}',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Color(0xFF3C2393),
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                          color: Color(0x33000000),
                          offset: Offset(
                            0.0,
                            -1.0,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '환경설정',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Survey()));
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFBCBCBC),
                                      borderRadius: BorderRadius.circular(18.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Icon(
                                            Icons.check_sharp,
                                            color: Colors.black,
                                            size: 40.0,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            '관광지 선호도 재설정',
                                            style: TextStyle(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (traveling == true) {
                                      await showRatingPopup(context, true);
                                    }
                                    else{
                                      Fluttertoast.showToast(
                                          msg: "여행중이 아닙니다",
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: const Color(0xff6E6E6E),
                                          fontSize: 20,
                                          toastLength: Toast.LENGTH_SHORT);
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFBCBCBC),
                                      borderRadius: BorderRadius.circular(18.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Icon(
                                            Icons.stop_circle,
                                            color: Colors.black,
                                            size: 40.0,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            '여행종료',
                                            style: TextStyle(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                //로그아웃
                                padding: EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    logoutdialog(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFBCBCBC),
                                      borderRadius: BorderRadius.circular(18.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Icon(
                                            Icons.login_sharp,
                                            color: Colors.black,
                                            size: 40.0,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            '로그아웃',
                                            style: TextStyle(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                // 회원 탈퇴
                                padding: EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Resigndialog(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFBCBCBC),
                                      borderRadius: BorderRadius.circular(18.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Icon(
                                            Icons.delete_forever_sharp,
                                            color: Colors.black,
                                            size: 40.0,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            '탈퇴하기',
                                            style: TextStyle(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
}

class LogoutService {
  String? PlatForm;

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PlatForm = prefs.getString('platform');
    if (PlatForm == 'Google') {
      await _googleLogout();
    } else if (PlatForm == 'Naver') {
      await _naverLogout();
    }
    await _clearUserData();
  }

  Future<void> _googleLogout() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      await _googleSignIn.signOut();
      print('로그아웃');
    } catch (error) {
      print('로그아웃 실패 : $error');
    }
  }

  Future<void> _naverLogout() async {
    try {
      await FlutterNaverLogin.logOut();
      print('로그아웃');
    } catch (error) {
      print('로그아웃 실패 : $error');
    }
  }

  Future<void> _clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('로컬 저장 데이터 초기화');
  }
}

class Withdraw {
  String? userId;
  String? PlatForm;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('로컬 저장 데이터 초기화');
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PlatForm = prefs.getString('platform');
    if (PlatForm == 'Google') {
      await _googleLogout();
    } else if (PlatForm == 'Naver') {
      await _naverLogout();
    }
    await _clearUserData();
  }

  Future<void> _googleLogout() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      await _googleSignIn.signOut();
      print('로그아웃');
    } catch (error) {
      print('로그아웃 실패 : $error');
    }
  }

  Future<void> _naverLogout() async {
    try {
      await FlutterNaverLogin.logOut();
      print('로그아웃');
    } catch (error) {
      print('로그아웃 실패 : $error');
    }
  }

  Future<void> userWithdraw() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    await _firestore.collection("clients").doc(userId).delete();
    await logout();
    print('회원 탈퇴 완료');
  }
}
