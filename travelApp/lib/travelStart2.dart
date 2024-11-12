import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:travelapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> dropDownList = <String>[
  '없음',
  '강남구',
  '강동구',
  '강북구',
  '강서구',
  '관악구',
  '광진구',
  '구로구',
  '금천구',
  '노원구',
  '도봉구',
  '동대문구',
  '동작구',
  '마포구',
  '서대문구',
  '서초구',
  '성동구',
  '성북구',
  '송파구',
  '양천구',
  '영등포구',
  '용산구',
  '은평구',
  '종로구',
  '중구',
  '중랑구'
];

class Travelstart2 extends StatefulWidget {
  final Day;
  final start_location_lat;
  final start_location_lng;

  const Travelstart2(this.Day, this.start_location_lat, this.start_location_lng,
      {super.key});

  @override
  State<StatefulWidget> createState() => _travelstart2State();
}

class _travelstart2State extends State<Travelstart2> {
  String travelname = '';
  String sellocation = dropDownList.first;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  Timer? _timer; // 타이머 변수
  BuildContext? _dialogContext;
  BuildContext? _errorContext;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      _subscription; // Firestore 구독
  Map<String, dynamic>? documentData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> updatetravel() async { //여행 정보 업데이트
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id');
    });
    if (travelname == '') {
      travelname =
          "${widget.Day.year}-${widget.Day.month}-${widget.Day.day}-여행";
    }
    await _firestore.collection("clients").doc(userId).update({
      "CurrentCourse": {
        "start_location_lat": widget.start_location_lat,
        "start_location_lng": widget.start_location_lng,
        "start_Day": widget.Day,
        "travel_name": travelname,
        "city": sellocation
      },
    });
    _showLoadingDialog(context);
  }

  Future<void> _showLoadingDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic previousValue;
    final initialSnapshot = await FirebaseFirestore.instance
        .collection('clients')
        .doc(userId)
        .get();
    if (initialSnapshot.exists) {
      previousValue = initialSnapshot.get('travel_list');
      print('Initial value of travel_list: $previousValue');
    }
    _subscription = FirebaseFirestore.instance
        .collection('clients')
        .doc(userId)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      if (snapshot.exists) {
        final newValue = snapshot.get('travel_list');
        if (previousValue.length != newValue.length) {
          print('리스트 길이 : ${newValue.length}');
          prefs.setInt('travelIndex', newValue.length - 1);
          prefs.setBool('traveling', true);
          stopWatching();
          _closeLoadingDialog();
        }
        previousValue = newValue;
      }
    });

    // 10초 후에 구독을 취소합니다.
    Future.delayed(Duration(seconds: 10), () {
      stopWatching();
      Navigator.of(_dialogContext!).pop();
      errorDialog(context);
      print('Stopped watching after 5 seconds.');
    });//로딩 창

    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 밖을 클릭해도 닫히지 않도록 설정
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("로딩 중..."),
                  ],
                ),
              ),
            ));
      },
    );
  }


  void stopWatching() { //파이어베이스 검색 정지
    _subscription.cancel();
  }

  Future <void> errorDialog(BuildContext context)async {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 밖을 클릭해도 닫히지 않도록 설정
      builder: (errorContext) {
        _errorContext = errorContext;
        return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 20),
                    Text("여행 코스 생성에 실패했습니다..."),
                  ],
                ),
              ),
            ));
      },
    );
    // 2초 후 다이얼로그 닫기
    Future.delayed(Duration(seconds: 2), () {
      if (_timer?.isActive ?? false) _timer?.cancel();
      _subscription.cancel();
      Navigator.of(_errorContext!).pop(); // 다이얼로그 닫기
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyAppPage(0)),
              (Route<dynamic> route) => false);
    });
  }

  void _closeLoadingDialog() {// 타이머와 구독을 취소하고 다이얼로그를 닫습니다
    if (_timer?.isActive ?? false) _timer?.cancel();
    _subscription.cancel();
    Navigator.of(_dialogContext!).pop(); // 다이얼로그 닫기
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyAppPage(0)),
        (Route<dynamic> route) => false);
  }

  Future<void> _loadUserData() async { //유저 id 로딩
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: // Generated code for this AppBar Widget...
            AppBar(
          backgroundColor: Color(0xFF37CB37),
          automaticallyImplyLeading: false,
          leading: IconButton(
            color: Colors.transparent,
            splashRadius: 30.0,
            iconSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '여행 시작',
            style: TextStyle(
              fontFamily: 'Laundry',
              color: Colors.white,
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: // Generated code for this Column Widget...
            SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(14.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              30.0, 10.0, 20.0, 0.0),
                          child: Text(
                            '가고싶은 지역구',
                            style: TextStyle(
                              fontFamily: 'Laundry',
                              fontSize: 25.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: DropdownButton(
                            // 드롭다운의 리스트를 보여줄 값
                            value: sellocation,
                            elevation: 100,
                            menuMaxHeight: 300,
                            onChanged: (String? value) {
                              setState(() {
                                sellocation = value!;
                              });
                            },
                            items: dropDownList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 100.0, 0.0, 0.0),
                    child: Text(
                      '여행 이름 지정',
                      style: TextStyle(
                        fontFamily: 'Laundry',
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8425F8),
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '여행 이름을 지어주세요',
                        labelStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF8425F8),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                        ),
                        hintStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF8425F8),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      //입력한 여행 이름 반환
                      onChanged: (String value) async {
                        setState(() {
                          travelname = value;
                        });
                      },
                    )),
                Align(
                  alignment: AlignmentDirectional(1.0, 1.0),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await updatetravel(); // 팝업 닫기
                      },
                      child: Text('여행 시작', style: TextStyle(
                          fontFamily: 'Laundry')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
