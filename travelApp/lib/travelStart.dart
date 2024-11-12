import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelapp/travelStart2.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';



class Travelstart extends StatefulWidget {


  const Travelstart({super.key});

  @override
  State<StatefulWidget> createState() => _travelstartState();
}

class _travelstartState extends State<Travelstart> {
  DateTime chooseDay = DateTime.now();
  var pickplace = '선택 안됨';
  Mode _mode = Mode.overlay;
  var start_location_lat;
  var start_location_lng;

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
        body: SingleChildScrollView(
          // Generated code for this Column Widget...
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.2,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          '여행 \n시작지점',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Laundry',
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: OutlinedButton(
                          onPressed: _handlePressButton,
                          child: Text('시작지점 선택'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: _requestLocationPermission,
                        )
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '여행 시작 날짜 선택',
                    style: TextStyle(
                      fontFamily: 'Laundry',
                      fontSize: 15.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),


              Align(
                alignment: Alignment.center,
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2100),
                  onDateChanged: (DateTime value) {
                    setState(() {
                      chooseDay = value;
                    });
                  },
                ),
              ),
              Align(child: Text(
                  '시작 날짜 :${chooseDay.year}-${chooseDay.month}-${chooseDay.day},\n 시작장소 : ${pickplace}',style: TextStyle(fontWeight: FontWeight.bold),)),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                  child: ElevatedButton(
                      onPressed: () {
                         if(start_location_lat!=null) {
                           Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) =>
                                       Travelstart2(
                                           chooseDay, start_location_lat,
                                           start_location_lng)));
                         }
                         else {
                           setState(() {
                             _requestLocationPermission();
                           });
                           myDialog(context);
                         }
                      },
                      child: Text('다음',style: TextStyle(fontFamily: "Laundry"),)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //위치권한 체크용 함수
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;

    // 권한이 거부된 경우 다시 요청
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    // 영구적으로 거부된 경우 설정 화면으로 안내
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    // 권한 상태에 따른 처리
    if (status.isGranted) {
      // 권한이 부여된 경우 실행할 코드
      setState(() {
        getCurrentLocation();
      });
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 권한이 거부되었습니다.')),
      );
    }
  }

  Future<void> _handlePressButton() async {
    void onError(PlacesAutocompleteResponse response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errorMessage ?? 'Unknown error'),
        ),
      );
    }

    // show input autocomplete with selected mode
    // then get the Prediction selected
    final p = await PlacesAutocomplete.show(
      context: context,
      apiKey: FlutterConfig.get('GOOGLE_MAPS_API_KEY'),
      onError: onError,
      mode: _mode,
      language: 'ko',
      components: [const Component(Component.country, 'kr')],
      resultTextStyle: Theme
          .of(context)
          .textTheme
          .titleMedium,
    );
    if (!mounted) {
      return;
    }
    await displayPrediction(p, ScaffoldMessenger.of(context));
  }

  Future<void> displayPrediction(Prediction? p,
      ScaffoldMessengerState messengerState) async {
    if (p == null) {
      return;
    }

    // get detail (lat/lng)
    final places = GoogleMapsPlaces(
      apiKey: FlutterConfig.get('GOOGLE_MAPS_API_KEY'),
    );

    final detail = await places.getDetailsByPlaceId(p.placeId!);
    final geometry = detail.result.geometry!;
    setState(() {

      pickplace = p.description!;
      start_location_lat = geometry.location.lat;
      start_location_lng = geometry.location.lng;
    });
  }
  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      pickplace = '현재위치';
      start_location_lat = position.latitude;
      start_location_lng = position.longitude;
    });
  }

  void myDialog(context) {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
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
                  "시작 장소 선택이 되지 않아 \n"
                      "현재 위치로 선택됩니다.",
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
}
