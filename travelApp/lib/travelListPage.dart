import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/loactionRating.dart';
import 'mypage.dart';
import 'nowtravel.dart';

class travelList extends StatefulWidget {
  const travelList({super.key});

  @override
  State<travelList> createState() => travelListState();
}

// 이전 여행 리스트
class travelListState extends State<travelList> {
  String? userId;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> travels = [];
  int? travelIndex;
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
    fetchTravelListOnly();
  }

  Future<void> fetchTravelListOnly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    traveling = prefs.getBool('traveling');
    travelIndex = prefs.getInt('travelIndex');
    try {
      // Firestore의 특정 문서에서 travel_list 필드만 가져오기
      DocumentSnapshot docSnapshot = await _firestore
          .collection("clients") // 예: 'travels'
          .doc(userId) // 예: 'your_doc_id'
          .get();

      if (docSnapshot.exists) {
        List<dynamic>? firebaseTravelList = docSnapshot.get('travel_list');

        if (firebaseTravelList != null) {
          setState(() {
            travels = List<Map<String, dynamic>>.from(firebaseTravelList);
          });
          print("Travel list has been successfully overwritten.");
        } else {
          print("No travel_list found in Firebase.");
        }
      } else {
        print("Document does not exist in Firebase.");
      }
    } catch (e) {
      print("Error fetching travel list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //상단 앱바
        appBar: AppBar(
          // Generated code for this AppBar Widget...
          backgroundColor: Color(0xFFA6DBFF),
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('원데이 서울',style: TextStyle(fontFamily: 'Laundry'),),
          ),

          actions: [
            IconButton(
              icon: Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () async {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => mypage()));
              },
            ),
          ],
        ),
        //지난 여행 기록을 리스트 뷰로 만듬
        body: ListView.builder(
          reverse: true,
          itemCount: travels.length,
          itemBuilder: (context, index) {
            var travelItem = travels[index];
            return Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
              child: ListTile(
                onTap: () async {
                  print(index);
                  if(index != travelIndex) checkTraveling(index);
                },
                leading: ImageIcon(
                  AssetImage(images[travelItem['theme']]!), // 테마 아이콘
                  size: 40,
                  color: Colors.blue,
                ),
                title: Text(
                  travelItem['travel_name'], // 여행 이름
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Date: ${travelItem['travel_date']}', // 여행 날짜
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'City: ${travelItem['travel_city']}', // 여행 지역
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red), // 삭제 아이콘
                  onPressed: () {
                    // 삭제 로직을 여기에 추가
                    // 예를 들어, travels 리스트에서 travelItem을 삭제
                    deletecourse(context, index);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void deletecourse(BuildContext context, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text("해당 코스를 삭제하시겠습니까?"),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(()   {
                      if(index == travelIndex){
                        prefs.setBool('traveling', false);
                      }
                    });
                    travels.removeAt(index);
                    _firestore.collection("clients").doc(userId).update({
                      'travel_list': travels,
                    });
                    fetchTravelListOnly();
                    setState((){
                     if(index == travelIndex){
                       travelIndex = -1;
                       prefs.setInt('travelIndex', -1);
                     }
                     else if(index < travelIndex!){
                       prefs.setInt('travelIndex', travelIndex! - 1);
                       travelIndex = travelIndex! - 1;
                     }
                    });

                    Navigator.of(context).pop(); // 팝업 닫기 (코스 삭제)
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
          });
        });
  }
  Future<void> checkTraveling(int index) async { //여행진행중인지 체크하는 함수
    bool? traveling;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() async {
      traveling = prefs.getBool('traveling');
    });
    if(traveling == true){
      await showRatingPopup(context, false);
      setState(() {
        traveling = prefs.getBool('traveling');
      });
      if (traveling == false){
        setState(() async {
          travelIndex = index;
          await prefs.setInt('travelIndex', index);
          await prefs.setBool('traveling', true);
        });
        travelchage(context);
      }
    }
    else{
      setState(() async {
        travelIndex = index;
        await prefs.setInt('travelIndex', index);
        await prefs.setBool('traveling', true);
      });
      travelchage(context);
    }
  }
}

void travelchage(BuildContext context) async { //여행 변경 확인창
  final MarkerManager markerManager = MarkerManager();
  showDialog(context: context, builder: (BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("여행코스가 \n변경 되었습니다!\n현재여행에서 확인하세요"),
          content: Container(
            width: double.maxFinite,
            height: 0,), // 팝업 창의 높이
          actions: [
            TextButton(
              onPressed: () {
                markerManager.clearPolylines();
                markers.clear();
                polylines.clear();
                Navigator.of(context).pop();
                setState((){});// 팝업 닫기
              },
              child: Text('EXIT'),
            ),
          ],
        );
      },
    );
  });

}
