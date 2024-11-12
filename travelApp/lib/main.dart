import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travelapp/login.dart';
import 'package:travelapp/question.dart';
import 'package:travelapp/travelListPage.dart';
import 'loactionRating.dart';
import 'mypage.dart';
import 'nowtravel.dart';
import 'travelStart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    int data = 1;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MemoApp',
      home: MyAppPage(data),
    );
  }
}

// 기본 앱 화면
class MyAppPage extends StatefulWidget {
  const MyAppPage(this.data, {super.key});

  final int data;
  @override
  State<MyAppPage> createState() => MyAppState();
}

class MyAppState extends State<MyAppPage> {
  //초기 네비게이션바 인덱스
  int _selectedIndex = 1;
  bool? isLogged;
  String? type;
  DateTime? currentBackPressTime;

  // 바텀 네비게이션 바 인덱스
  final List<Widget> _navIndex = [
    nowTravel(),
    HomePage(),
    travelList(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.data;
    _Logincheck();
    _Questioncheck();
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "'뒤로' 버튼을 한번 더 누르시면 종료됩니다.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xff6E6E6E),
          fontSize: 20,
          toastLength: Toast.LENGTH_SHORT);
      return false;
    }
    return true;
  }

  //네비게이션바 선택시
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //네비게이션 바 ui
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async{
      bool result = onWillPop();
      return await Future.value(result);
    },
    child: Scaffold(
      body: _navIndex.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home_filled),
          //   label: '홈',
          //   backgroundColor: Colors.white,
          // ),

          //현재여행 버튼
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: '현재여행',
          ),

          //홈버튼
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),

          //여행리스트 버튼
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '여행리스트',
          ),
        ],

        currentIndex: _selectedIndex,
        //클릭시 이동
        onTap: _onNavTapped,
      ),
    )
    );
  }

  Future<void> _Logincheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogged = prefs.getBool('login');
    if (isLogged != true) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => loginPage()),
              (Route<dynamic> route) => false);
    }
  }
  Future<void> _Questioncheck() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    type = prefs.getString('type');
    if (type == '' || type == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Survey()));
    }
  }
}

// double _originLatitude = 37.569400, _originLongitude = 126.985832;
// double _destLatitude = 37.512303, _destLongitude = 127.071929;

// Home 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          //상단 앱바
          appBar: // Generated code for this AppBar Widget...
              AppBar(
            backgroundColor: Color(0xFFA6DBFF),
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('원데이 서울',style: TextStyle(fontFamily: 'Laundry'),),
            ),
            actions: [
              //환경설정으로 가는 아이콘 버튼
              IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => mypage()));
                },
              ),
            ],
          ),
          //메인 화면
          body: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        0.0, MediaQuery.sizeOf(context).height * 0.1, 0.0, 0.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      decoration: BoxDecoration(
                        color: Color(0xFF111111),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0),
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        ),
                        shape: BoxShape.rectangle,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: GestureDetector(
                            onTap: () {
                              checkTraveling();
                            },
                            child: Image.asset(
                              'assets/image/homeimage.png',
                              width: MediaQuery.sizeOf(context).width * 8.0,
                              height: MediaQuery.sizeOf(context).height * 2.5,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 0.0, MediaQuery.sizeOf(context).height * 0.1),
                  //여행 시작 버튼
                  child: OutlinedButton(
                    onPressed: () {
                      checkTraveling();
                    },
                    child: Text('여행 시작',style: TextStyle(fontFamily: 'Laundry'),),
                  ),
                ),
              ],
            ),
          )),
    );
  }
  Future<void> checkTraveling() async {
    bool? traveling;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      traveling = prefs.getBool('traveling');
    });
    if(traveling == true){
      await showRatingPopup(context,false);
      setState(() {
        traveling = prefs.getBool('traveling');
      });
      if (traveling == false) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Travelstart()));
      }
    }
    else{
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Travelstart()));
    }
  }
}




