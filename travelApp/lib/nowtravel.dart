import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'mypage.dart';

class nowTravel extends StatefulWidget {
  const nowTravel({super.key});

  @override
  nowTravelState createState() => nowTravelState();
}

Map<MarkerId, Marker> markers = {}; // 마커 데이터
Map<PolylineId, Polyline> polylines = {}; // 폴리라인 데이터

// 지도 페이지 상태 관리
class nowTravelState extends State<nowTravel> {
  late GoogleMapController mapController;
  final MarkerManager markerManager = MarkerManager();
  LatLng startposition = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    // _initializeMarkersAndPolylines(); // 초기 마커 및 폴리라인 설정
    clearMap();
  }
  Future<void> clearMap() async {
      setState(() {
        markers.clear();
        polylines.clear();
        markerManager.removePolyline("poly");
        markerManager.clearPolylines();
      });
}
  // 마커와 폴리라인을 업데이트하는 콜백 함수
  void updateMap(LatLng startLatLng, LatLng endLatLng) async {
    setState(() {
      // 마커 초기화
      markers.clear();
      polylines.clear();
      markerManager.removePolyline("poly");
      markerManager.clearPolylines();
      startposition = startLatLng;
      mapController.moveCamera(CameraUpdate.newLatLng(startLatLng) // 카메라 좌표로 이동
          );
    });

    // 새로운 마커 추가
    markerManager.addMarker(
        startLatLng, "origin", BitmapDescriptor.defaultMarker);
    markerManager.addMarker(
        endLatLng, "destination", BitmapDescriptor.defaultMarkerWithHue(90));

    // 새로운 폴리라인 추가
    await markerManager.getPolyline(startLatLng, endLatLng);

    setState(() {
      markers = markerManager.getMarkers();
      polylines = markerManager.getPolylines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFA6DBFF),
            title: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                '원데이 서울',
                style: TextStyle(fontFamily: 'Laundry'),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_rounded,
                    color: Colors.white, size: 30.0),
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => mypage()));
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: startposition, zoom: 13),
                      myLocationEnabled: true,
                      compassEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      onMapCreated: _onMapCreated,
                      markers: Set<Marker>.of(markers.values),
                      // 마커 적용
                      polylines: Set<Polyline>.of(polylines.values), // 폴리라인 적용
                    ),
                  ),

                ],
              ),
              MapBottomSheet(
                onUpdateMap: updateMap,
              ),
            ],
          )
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}

// Marker와 Polyline 관리 클래스
class MarkerManager {
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKeyL = FlutterConfig.get(
      'GOOGLE_MAPS_API_KEY');

  // 마커 추가 메서드
  void addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  // 마커 제거 메서드
  void removeMarker(String markerId) {
    markers.remove(MarkerId(markerId));
  }

  // 폴리라인 추가 메서드
  void addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
  }

  // 폴리라인 제거 메서드
  void removePolyline(String polylineId) {
    polylines.remove(PolylineId(polylineId));
  }

  void clearPolylines() {
    polylines.clear(); // 모든 폴리라인을 삭제
  }

  // 경로 폴리라인 가져오기
  Future<void> getPolyline(startLatLng, endLatLng) async {
    // 폴리라인 및 좌표 초기화
    clearPolylines();
    polylineCoordinates.clear(); // 추가된 라인 좌표를 초기화

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPiKeyL,
      request: PolylineRequest(
        origin: PointLatLng(startLatLng.latitude, startLatLng.longitude),
        destination: PointLatLng(endLatLng.latitude, endLatLng.longitude),
        mode: TravelMode.transit,
      ),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // 새로운 폴리라인 추가
    addPolyLine();
  }

  // 마커 반환 메서드
  Map<MarkerId, Marker> getMarkers() {
    return markers;
  }

  // 폴리라인 반환 메서드
  Map<PolylineId, Polyline> getPolylines() {
    return polylines;
  }
}

//BottomSheet용 클래스
class MapBottomSheet extends StatefulWidget {
  final Function(LatLng, LatLng) onUpdateMap;

  const MapBottomSheet({required this.onUpdateMap, Key? key}) : super(key: key);

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  late double _height;

  final double _lowLimit = 50;
  final double _upThresh = 100;
  final String apiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');
  String? startLocation; // 시작 좌표
  String? endLocation; // 도착 좌표
  List<TransitStep> transitSteps = [];
  bool showTransitSteps = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map? travel;
  String? userId;
  int travelIndex = 0;
  bool? traveling;
  String travelname = '';
  final MarkerManager markerManager = MarkerManager();

  /// 100 -> 600, 550 -> 100 으로 애니메이션이 진행 될 때,
  /// 드래그로 인한 _height의 변화 방지
  bool _longAnimation = false;

  @override
  void initState() {
    super.initState();
    _height = _lowLimit;
    fetchTravelListOnly();
    fetchTransitDirections();
  }

  //여행 지역 나오는곳
  final List<Map<String, dynamic>> travelList = [];

  Future<void> fetchTravelListOnly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    travelIndex = prefs.getInt('travelIndex')!;
    traveling = prefs.getBool('traveling');
    if (traveling == true) {
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
              travel =
                  Map<String, dynamic>.from(firebaseTravelList[travelIndex]);
              travelname = travel?['travel_name'];
            });
            print("Travel list has been successfully overwritten.");
            print(
                "list : ${travel?['travel_location'].length}--------------------");
            for (int i = 0; i < (travel?['travel_location'].length) - 1; i++) {
              travelList.add({
                'from': travel?['travel_location'][i]['location_name'],
                'to': travel?['travel_location'][i + 1]['location_name'],
                'start_latitude': travel?['travel_location'][i]['latitude'],
                'start_longitude': travel?['travel_location'][i]['longitude'],
                'end_latitude': travel?['travel_location'][i + 1]['latitude'],
                'end_longitude': travel?['travel_location'][i + 1]['longitude'],
              });
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
  }

  Future<void> fetchTransitDirections() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLocation&destination=$endLocation&mode=transit&language=ko&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        transitSteps = _parseRoute(data);
      });
    } else {
      setState(() {
        transitSteps = [];
      });
    }
  }

  //여행경로 안내를 불러오는 함수
  List<TransitStep> _parseRoute(dynamic data) {
    if (data['status'] == 'OK') {
      final routes = data['routes'] as List;
      if (routes.isNotEmpty) {
        final legs = routes[0]['legs'] as List;
        final steps = legs[0]['steps'] as List;
        return steps
            .map((step) {
              final travelMode = step['travel_mode'];
              if (travelMode == 'TRANSIT') {
                final transitDetails = step['transit_details'];
                final line = transitDetails['line'];
                final vehicle = line['vehicle']['type']; // 버스 또는 지하철
                final lineName = line['name']; // 노선 이름 (예: 500번 버스, 지하철 2호선)
                final shortName = line['short_name']; // 정확한 노선 번호 (예: 500번)
                final departureStop = transitDetails['departure_stop']['name'];
                final arrivalStop = transitDetails['arrival_stop']['name'];
                final numStops = transitDetails['num_stops'];
                return TransitStep(
                  travelMode: travelMode,
                  vehicle: vehicle,
                  lineName: lineName,
                  shortName: shortName,
                  departureStop: departureStop,
                  arrivalStop: arrivalStop,
                  numStops: numStops,
                );
              } else if (travelMode == 'WALKING') {
                return TransitStep(
                  travelMode: travelMode,
                  distance: step['distance']['text'],
                  duration: step['duration']['text'],
                );
              }
              return null;
            })
            .whereType<TransitStep>()
            .toList();
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final double _highLimit = MediaQuery.of(context).size.height * 0.6;
    final double _downThresh = MediaQuery.of(context).size.height * 0.59;
    final double _boundary = MediaQuery.of(context).size.height * 0.56;

    return Positioned(
        bottom: 0.0,
        child: GestureDetector(
            onVerticalDragUpdate: ((details) {
              // delta: y축의 변화량, 우리가 보기에 위로 움직이면 양의 값, 아래로 움직이면 음의 값
              double? delta = details.primaryDelta;
              if (delta != null) {
                /// Long Animation이 진행 되고 있을 때는 드래그로 높이 변화 방지,
                /// 그리고 low limit 보다 작을 때 delta가 양수,
                /// High limit 보다 크거나 같을 때 delta가 음수이면 드래그로 높이 변화 방지
                if (_longAnimation ||
                    (_height <= _lowLimit && delta > 0) ||
                    (_height >= _highLimit && delta < 0)) return;
                setState(() {
                  /// 600으로 높이 설정
                  if (_upThresh <= _height && _height <= _boundary) {
                    _height = _highLimit;
                    _longAnimation = true;
                  }

                  /// 100으로 높이 설정
                  else if (_boundary <= _height && _height <= _downThresh) {
                    _height = _lowLimit;
                    _longAnimation = true;
                  }

                  /// 기본 작동
                  else {
                    _height -= delta;
                  }
                });
              }
            }),
            child: AnimatedContainer(
              curve: Curves.bounceOut,
              onEnd: () {
                if (_longAnimation) {
                  setState(() {
                    _longAnimation = false;
                  });
                }
              },
              duration: const Duration(milliseconds: 300),
              decoration: const BoxDecoration(
                  boxShadow: [BoxShadow(blurRadius: 6, spreadRadius: 0.7)],
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              width: MediaQuery.of(context).size.width,
              height: _height,
              child: Column(
                children: [
                  Text(
                    travelname != '' ? travelname : '여행이 없어요',
                    style: TextStyle(fontSize: 25, fontFamily: 'Laundry'),
                  ),
                  Container(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 15.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: _height - 40,
                    child: showTransitSteps
                        ? _buildTransitStepsList()
                        : _buildTravelList(),
                  ),
                ],
              ),
            )));
  }

  // 첫 번째 리스트 (출발지/도착지 리스트)
  Widget _buildTravelList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0), // 전체 여백
      itemCount: travelList.length,
      itemBuilder: (context, index) {
        final item = travelList[index];
        return Card(
          elevation: 4, // 그림자 효과
          margin: const EdgeInsets.symmetric(vertical: 8.0), // 카드 간격
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            // 카드 내 여백
            leading: Icon(Icons.directions_bus, color: Colors.blue),
            // 아이콘 추가
            title: Text(
              '${item['from']} → ${item['to']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, // 볼드 텍스트
              ),
            ),
            subtitle: Text(
              '여행 경로', // 하위 텍스트 추가
              style: TextStyle(color: Colors.grey[600]), // 회색 텍스트
            ),
            onTap: () {
              // 리스트 클릭 시 두 번째 리스트를 보여줌
              // 코스 클릭시
              // 지도 업데이트 요청
              widget.onUpdateMap(
                LatLng(item['start_latitude'], item['start_longitude']),
                LatLng(item['end_latitude'], item['end_longitude']),
              );
              setState(() {
                startLocation =
                    '${travelList[index]["start_latitude"]},${travelList[index]["start_longitude"]}'; // 서울 시청 좌표
                endLocation =
                    '${travelList[index]["end_latitude"]},${travelList[index]["end_longitude"]}';
                fetchTransitDirections();
                Future.delayed(const Duration(milliseconds: 500), () {});
                showTransitSteps = true;
              });
            },
          ),
        );
      },
    );
  }

  //경로안내 위젯
  Widget _buildTransitStepsList() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('교통 정보'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                showTransitSteps = false;
              }); // 뒤로가기 기능
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: transitSteps.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: transitSteps.length,
                itemBuilder: (context, index) {
                  final step = transitSteps[index];
                  return TransitStepTile(step: step);
                },
              ));
  }
}

class TransitStep {
  final String travelMode;
  final String? vehicle;
  final String? lineName;
  final String? shortName;
  final String? departureStop;
  final String? arrivalStop;
  final int? numStops;
  final String? distance;
  final String? duration;

  TransitStep({
    required this.travelMode,
    this.vehicle,
    this.lineName,
    this.shortName,
    this.departureStop,
    this.arrivalStop,
    this.numStops,
    this.distance,
    this.duration,
  });
}

//경로 표시 안내 ui
class TransitStepTile extends StatelessWidget {
  final TransitStep step;

  TransitStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    if (step.travelMode == 'WALKING') {
      // 도보 경로 UI
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(Icons.directions_walk, color: Colors.green),
          title: Text(
            '도보 ${step.distance}, 약 ${step.duration}',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      );
    } else if (step.travelMode == 'TRANSIT') {
      // 대중교통 경로 UI
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: step.vehicle == 'BUS'
              ? Icon(Icons.directions_bus, color: Colors.blue)
              : Icon(Icons.directions_subway, color: Colors.red),
          title: Text(
            '${step.departureStop}에서 ${step.arrivalStop}까지 ${step.shortName} ${step.vehicle}, (${step.numStops} 정거장)',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      );
    } else {
      return SizedBox.shrink(); // 알 수 없는 경로일 때
    }
  }
}
