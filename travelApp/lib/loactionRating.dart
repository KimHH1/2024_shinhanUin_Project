import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/main.dart';

List<Map<String, dynamic>> places = [
];
String? userId;
bool? traveling;
int travelIndex = 0;
Future<void> showRatingPopup(BuildContext context, bool check) async {
  // 여행 목록을 가져오기 전 로딩 상태를 위한 변수
  bool isLoading = true;

  // 로딩중 팝업창 (중요하진 않음)
   showDialog(
    context: context,
    builder: (BuildContext context) {
      // StatefulBuilder로 팝업 내에서 상태 관리
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text( check == true ? '여행을 종료하겠습니까?' : '현재 여행중입니다.\n현재 여행을 종료하시겠습니까?',style: TextStyle(fontFamily: 'Laundry'),),
            content: Container(
              width: double.maxFinite,
              height: 300, // 팝업 창의 높이
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // 로딩 스피너
                  : ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                          children: [
                            Text(
                              places[index]['name'],
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Laundry'),
                            ),
                            SizedBox(height: 8.0), // 텍스트와 별점 사이의 간격
                            StarRating(
                              rating: places[index]['rating'],
                              onRatingChanged: (rating) {
                                // 별점 클릭 시 상태 업데이트
                                setState(() {
                                  places[index]['rating'] = rating;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(thickness: 1.0), // 구분선 추가
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setchecktraveling();
                  Navigator.of(context).pop();// 팝업 닫기 (평점 제출)
                },
                child: Text('네', style: TextStyle(fontFamily: 'Laundry'),),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                },
                child: Text('아니요', style: TextStyle(fontFamily: 'Laundry'),),
              ),
            ],
          );
        },
      );
    },
  );

  // 여행 목록 가져오기
  await fetchTravelListOnly();

  // 데이터가 로드된 후 상태 업데이트 (팝업이 열린 상태에서)// 기존 팝업 닫기
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          setState(() {
            isLoading = false;  // 로딩 완료 후 isLoading 상태 업데이트
          });

          return AlertDialog(
            title: Text( check == true ? '여행을 종료하겠습니까?' : '현재 여행중입니다.\n현재 여행을 종료하시겠습니까?',style: TextStyle(fontFamily: 'Laundry'),),
            content: Container(
              width: double.maxFinite,
              height: 300, // 팝업 창의 높이
              child: ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                          children: [
                            Text(
                              places[index]['name'],
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, fontFamily: 'Laundry'),
                            ),
                            SizedBox(height: 8.0), // 텍스트와 별점 사이의 간격
                            StarRating(
                              rating: places[index]['rating'],
                              onRatingChanged: (rating) {
                                // 별점 클릭 시 상태 업데이트
                                setState(() {
                                  places[index]['rating'] = rating;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(thickness: 1.0), // 구분선 추가
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if(check == true) {
                    sendTravelRating(); //(평점 제출)
                    setchecktraveling(); // 여행 상태 변경
                    Navigator.of(context).pop(); //현재 팝업
                    Navigator.of(context).pop(); //로딩중 팝업
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyApp()));
                  }
                  else{
                    await sendTravelRating(); //(평점 제출)
                    await setchecktraveling(); // 여행 상태 변경
                    Navigator.of(context).pop(); //현재 팝업
                    Navigator.of(context).pop(); //로딩중 팝업
                  }
                },
                child: Text('네', style: TextStyle(fontFamily: 'Laundry'),),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); //현재 팝업
                  Navigator.of(context).pop(); //로딩중 팝업
                },
                child: Text('아니요', style: TextStyle(fontFamily: 'Laundry'),),
              ),
            ],
          );
        },
      );
    },
  );
}
Future<void> sendTravelRating() async {
  print(places.length);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  if (userId == null) {
    print("User ID가 null입니다.");
    return; // 사용자 ID가 없으면 함수 종료
  }

  try {
    Map<String, dynamic> ratings = {};

    // 모든 여행지의 평가를 맵에 추가
    for (int i = 0; i < places.length; i++) {
      if (places[i].containsKey('name') && places[i].containsKey('rating')) {
        ratings[places[i]['name']] = places[i]['rating'];
      } else {
        print("잘못된 데이터 구조: ${places[i]}");
      }
    }

    // travel_rating 필드를 한 번에 업데이트
    await _firestore.collection("clients").doc(userId).set({
      'travel_rating': ratings,
    }, SetOptions(merge: true));

    print("데이터 전송 성공");
  } catch (e) {
    print("데이터 전송 안됨: $e"); // 에러 메시지 출력
  }
}

Future<void> fetchTravelListOnly() async {
  places = [];


  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userId = prefs.getString('id');
  traveling = prefs.getBool('traveling');
  travelIndex = prefs.getInt('travelIndex')!;
  try {
    // Firestore의 특정 문서에서 travel_list 필드만 가져오기
    DocumentSnapshot docSnapshot = await _firestore
        .collection("clients") // 예: 'travels'
        .doc(userId) // 예: 'your_doc_id'
        .get();

    if (docSnapshot.exists) {
      List<dynamic>? firebaseTravelList = docSnapshot.get('travel_list');

      if (firebaseTravelList != null) {
        var travel = Map<String, dynamic>.from(firebaseTravelList[travelIndex]);
        for(int i =1;i<(travel['travel_location'].length);i++){
          places.add({'name' : travel['travel_location'][i]['location_name'], 'rating' : 0.0});
        }
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

Future<void> setchecktraveling()async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setBool('traveling', false);
  await prefs.setInt('travelIndex', -1);
}

class StarRating extends StatelessWidget {
  final ValueChanged<double> onRatingChanged;
  final double rating; // 현재 선택된 별점
  final int maxRating; // 최대 별점 (기본 5)
  final double sizeFactor; // 별 크기
  final Color selectedColor; // 선택된 별 색상
  final Color unselectedColor; // 선택되지 않은 별 색상


  StarRating({required this.rating, required this.onRatingChanged, this.maxRating=5,
    this.sizeFactor = 0.08, this.selectedColor = Colors.amber, this.unselectedColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double starSize = screenWidth * sizeFactor;
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
        child: Row(
      children: List.generate(maxRating, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating ? selectedColor : unselectedColor,
            size: starSize,
          ),
          onPressed: () {
            onRatingChanged(index + 1.0); // 평점 변경
          },
        );
      }),
        )
    );
  }
}
