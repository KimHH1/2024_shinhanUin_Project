import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/main.dart';

class Survey extends StatefulWidget {
  const Survey({super.key});

  @override
  State<Survey> createState() => SurveyState();
}

//선호도 조사페이지 화면및 함수
class SurveyState extends State<Survey> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var question = ['start']; //선호도 조사용 질문
  var answer = []; //선택한 질문별 선호 가중치 저장
  var qindex = 0; // 질문 순서
  var cateanswer = 0;
  var qnumber = 0; // 선택한 선호 가중치
  var choseType;
  String? userId;
  String? type;
  List icons = [
    Icons.looks_one,
    Icons.looks_two,
    Icons.looks_3,
    Icons.looks_4,
    Icons.looks_5
  ];
  bool check = false;

  @override
  void initState() {
    super.initState();
    fetchArrayField();
    _loadUID();
  }

  Future<void> fetchArrayField() async {
    // Firestore 인스턴스 생성
    try {
      // 특정 컬렉션의 문서에서 배열 필드 가져오기
      DocumentSnapshot docSnapshot =
          await _firestore.collection('question').doc('type1').get();
      List<dynamic> data = docSnapshot.get('Q1');
      setState(() {
        question = List<String>.from(data); // 타입 변환
      });
      for (int i = 2; i <= 9; i++) {
        List<dynamic> data = docSnapshot.get('Q${i}');
        // 배열을 List<String>으로 변환하여 사용
        setState(() {
          question += List<String>.from(data); // 타입 변환
        });
      }
    } catch (e) {
      print('Error fetching array field: $e');
    }
  }

  Future<void> _loadUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    type = prefs.getString('type');
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        if (type == null) {
          SystemNavigator.pop();
          return Future(() => false);
        } else {
          return Future(() => true);
        }
      },
      child: Scaffold(
        //상단 앱바
        appBar: // Generated code for this AppBar Widget...
            AppBar(
          backgroundColor: Color(0xffffffff),
          automaticallyImplyLeading: false,
          title: Text(
            'travel test',
            style: TextStyle(
              fontFamily: 'Laundry',
              letterSpacing: 0.0,
            ),

          ),
          actions: [
            Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                child: (type != null)
                    ? IconButton(
                        color: Colors.transparent,
                        splashRadius: 30.0,
                        iconSize: 50.0,
                        splashColor: Color(0xffffffff),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Color(0xff000000),
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    : Text('')),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 12.0, 0.0, 0.0),
                          child: Text(
                            'Question ${qindex + 1}/${question.length}',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 0.0),
                        child: LinearPercentIndicator(
                          percent: (qindex + 1) / question.length,
                          width: MediaQuery.sizeOf(context).width * 0.95,
                          lineHeight: 12.0,
                          animation: true,
                          animateFromLastPercent: true,
                          progressColor: Color(0xFFEE59FF),
                          backgroundColor: Color(0xff6c6c6c),
                          barRadius: Radius.circular(24.0),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(16.0, 150.0, 0.0, 0.0),
                        child: Text(
                          question[qindex],
                          style: TextStyle(
                            fontFamily: 'Laundry',
                            letterSpacing: 0.0,
                            fontSize: 18,
                            fontWeight:FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 20.0, 0.0, 0.0),
                        child: Text(
                          '1(매우 아니다), 2(아니다), 3(보통), 4(그렇다), 5(매우 그렇다)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            14.0, 120.0, 14.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(5, (index) {
                            int buttonNumber = index + 1;
                            return IconButton(
                              splashRadius: 20.0,
                              iconSize: 65.0,
                              icon: Icon(
                                icons[index], // Dynamic icon for each button
                                color: qnumber == buttonNumber
                                    ? Color(
                                    0xff9950e8) // Highlight color for selected button
                                    : Colors.black,
                                // Default color for other buttons
                                size: 50.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  qnumber = buttonNumber;
                                  check =true;
                                });
                                print('IconButton $buttonNumber pressed ...');
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (!check) {
                            myDialog(context);
                          } else {
                            cateanswer += qnumber;
                            if ((qindex + 1) % 3 == 0) {
                              answer.add(double.parse((cateanswer / 3).toStringAsFixed(2)));
                              cateanswer = 0;
                            }
                            if (qindex == question.length - 1) {
                              setState(() {
                                type = userType(answer);
                              });
                              _firestore.collection("clients").doc(userId).set({
                                "user_info": {
                                  "Question": answer,
                                },
                              }, SetOptions(merge: true));
                              resultDialog(context, type);
                              qindex--;
                            }
                            check = false;
                            qindex++;
                            qnumber = 0;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.8, 50),
                        backgroundColor: (!check) ? Color(0xE6E457FF) : Color(
                            0xff9950e8),
                        textStyle: TextStyle(
                            fontFamily: 'Readex Pro',
                            color:  Colors.black ,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold),
                      ),
                      child: Text(
                        (qindex == question.length - 1)
                            ? '종료'
                            : '다음 질문',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Readex Pro',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String userType(List answer) {
    int typenum = answer.indexOf(
        answer.reduce((current, next) => current > next ? current : next));
    String type = '';
    if (typenum == 0)
      type = "예술 애호가";
    else if (typenum == 1)
      type = "자연 사랑꾼";
    else if (typenum == 2)
      type = "미술 감상자";
    else if (typenum == 3)
      type = "문화 탐방자";
    else if (typenum == 4)
      type = "쇼핑 전문가";
    else if (typenum == 5)
      type = "로컬 탐방자";
    else if (typenum == 6)
      type = "역사 애호가";
    else if (typenum == 7)
      type = "모험의 달인";
    else if (typenum == 8) type = "경치 감상가";
    _firestore.collection("clients").doc(userId).set({
      "user_info": {
        "type": type,
      },
    }, SetOptions(merge: true));
    _saveType(type);
    return type;
  }

  Future<void> _saveType(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('type', type);
  }
}

void myDialog(context) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("Error"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "선호도를 눌러주세요",
              ),
            ],
          ),
          actions: <Widget>[
            new OutlinedButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      });
}

void resultDialog(context, result) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("결과"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${result}",
              ),
            ],
          ),
          actions: <Widget>[
            new OutlinedButton(
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                    (Route<dynamic> route) => false);
              },
              child: Text('확인'),
            ),
          ],
        );
      });
}
