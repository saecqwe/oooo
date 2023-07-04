import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../net/http_client.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // do not import this yourself
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:kappu/common/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_manager.dart';
import '../net/base_dio.dart';

class LocationScreen extends StatefulWidget {
  final String? loginType;
  final String? socialId;
  final String? name;
  final String? email;
  String password = '';




 // String checkPassword = '';
 // bool _showPassword = true;
  //bool _showCheckPassword = true;
  bool? isLockedIn=false;
  String passwordStrength = '';
  //String countryValue = "";
 // String stateValue = "";
 // String cityValue = "";
  LocationScreen({required this.password  ,this.name,this.email,this.loginType,this.socialId,Key? key}) : super(key: key);

  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  PickResult? selectedPlace;
  bool loading = false;

  LatLng kInitialPosition = LatLng(-33.8567844, 151.213108);

  void initRenderer() {
    // if (_mapsInitialized) return;
    // if (widget.mapsImplementation is GoogleMapsFlutterAndroid) {
    //   switch (_mapsRenderer) {
    //     case "legacy":
    //       (widget.mapsImplementation as GoogleMapsFlutterAndroid)
    //           .initializeWithRenderer(AndroidMapRenderer.legacy);
    //       break;
    //     case "latest":
    //       (widget.mapsImplementation as GoogleMapsFlutterAndroid)
    //           .initializeWithRenderer(AndroidMapRenderer.latest);
    //       break;
    //   }
    // }
    // setState(() {
    //   _mapsInitialized = true;
    // });
  }
  @override
  void initState() {
    getloc();
    super.initState();
  }

  void getloc() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition();
    kInitialPosition = LatLng(position.latitude, position.longitude);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final rP = context.read<HomeProvider>();
    return PlacePicker(
      resizeToAvoidBottomInset:
      false, // only works in page mode, less flickery
      apiKey: Platform.isAndroid
          ? "AIzaSyArdmRIiIuLzzGzTDdm_krtdMTJtY5xBTA"
          : "AIzaSyDIdtmuQa4mIjIF-u-MmkB7hhAiQE_IxXo",
      hintText: "Find a place ...",
      searchingText: "Please wait ...",
      selectText: "Select place",
      outsideOfPickAreaText: "Place not in area",
      initialPosition: kInitialPosition,
      useCurrentLocation: true,
      selectInitialPosition: true,
      usePinPointingSearch: true,
      usePlaceDetailSearch: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        print("Map created");
        print("$selectedPlace");
      },
      onPlacePicked: (PickResult result) {
        print("Place picked: ${result.formattedAddress}");
        setState(() {
          selectedPlace = result;
          Navigator.of(context).pop();
        });
      },
      onMapTypeChanged: (MapType mapType) {
        print("Map type changed to ${mapType.toString()}");
      },
      // #region additional stuff
      // forceSearchOnZoomChanged: true,
      // automaticallyImplyAppBarLeading: false,
      // autocompleteLanguage: "ko",
      // region: 'au',
      pickArea: CircleArea(
        center: kInitialPosition,
        radius: 300,
        fillColor: Colors.blue.withOpacity(0.5),
        strokeColor: Colors.lightGreen.withGreen(255).withAlpha(192),
        strokeWidth: 2,
      ),
      selectedPlaceWidgetBuilder:
          (_, selectedPlace, state, isSearchBarFocused) {
        print("state: $state, isSearchBarFocused: $isSearchBarFocused");
        return isSearchBarFocused
            ? Container()
            : FloatingCard(
          bottomPosition:
          10, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
          leftPosition: 0.0,
          rightPosition: 0.0,
          color: Colors.transparent,
          // width: MediaQuery.of(context).size.width * 0.4,
          borderRadius: BorderRadius.circular(12.0),
          child: state == SearchingState.Searching
              ? SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator(color: Colors.white,)))
              : Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.2,
                right: MediaQuery.of(context).size.width * 0.2),
            child: SizedBox(
              width: 100,
              child: InkWell(
                child: Container(
                  height: 50,
                  width: 30,

                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5)),
                  child: SizedBox(
                      height: 50,
                      child: Center(
                          child: loading ? CircularProgressIndicator(color: Colors.white,) : Text(
                            "Confirm",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ))),
                ),
                onTap: () async {
//                                   // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
//                                   //            this will override default 'Select here' Button.
             loading=true;

                setState(() {

                });
                  print(
                      "do something with [selectedPlace] data");
                  print(
                      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                  print(selectedPlace!.formattedAddress!);
                  print("(lat: " +
                      selectedPlace.geometry!.location.lat
                          .toString());
                  print("(lng: " +
                      selectedPlace.geometry!.location.lng
                          .toString());



                  String lattitude;
                  String longitude;

                  if(selectedPlace.geometry?.location.lat == null && selectedPlace.geometry?.location.lng == null){
                    lattitude=kInitialPosition.latitude.toString();
                    longitude=kInitialPosition.longitude.toString();

                  }
                  else {
                    lattitude=selectedPlace.geometry!.location.lat.toString();
                    longitude=selectedPlace.geometry!.location.lng.toString();
                  }

                  if (kDebugMode) {
                    print('printing from selectedpLACE ${selectedPlace.geometry?.location.lat}');
                  }
             SharedPreferences prefs=await SharedPreferences.getInstance();
             prefs.setString('currentLocation', '${selectedPlace.name}');
             prefs.setString('lat', lattitude);
             prefs.setString('long', longitude);

             print('formated address ${selectedPlace.formattedAddress}');

             print('lattitude ${lattitude}');

             print('longitude ${longitude}');

                 await onsignup(selectedPlace.formattedAddress!,lattitude,longitude);
              loading=false;
              setState(() {

              });
             await Navigator.push(
                 context,
                 MaterialPageRoute(
                     builder: (context) => BottomNavBar(isprovider: false,)
                 ));
                  // await rP.getAddressFromLatLng(
                  //     selectedPlace.geometry!.location.lat,
                  //     selectedPlace.geometry!.location.lng);
                  // Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      },

    );

  }

  onsignup(String address, String lat,String long) async {
      Map<String, dynamic> body = widget.socialId!.isEmpty
          ? {
              'first_name': widget.name,
              'username': "",
              'last_name': "",
              'email': widget.email,
              'phone_number': "",
              'password':widget.password,
              'fcm_token': StorageManager().fcmToken,
              'os': Platform.isAndroid ? 'android' : 'ios',
              'language': "English",
              'nationality': "Malta",
              'login_src': '',
        'location' : selectedPlace?.formattedAddress,
              'social_login_id': '',
              'location' : '${address}',
              'lat' : lat,
              'lng' : long,
            }
          : {
              'first_name':widget.name,
              'username': "",
              'last_name': "",
              'email': widget.email,
              'phone_number': "",
              'lat' : lat,
        'location' : selectedPlace?.formattedAddress,

        'lng' : long,
              'password': '',
              'login_src': widget.loginType,
              'social_login_id': widget.socialId,
              'fcm_token': StorageManager().fcmToken,
              'os': Platform.isAndroid ? 'android' : 'ios',
              'language': "English",
              'nationality': "Malta",
            };
      print('lattitude ${lat}');

      print('longitude ${long}');
      await HttpClient().userSignup(body, File("path")).then((value) async {

        if (value?.data['status']) {
          var provider = StorageManager();
          provider.accessToken = value?.data['token'];
          provider.name = widget.name!;

          // provider.phone = _phnocontroller.text;
          provider.email = widget.email!;
          provider.isProvider = false;
          provider.isSocialUser = !widget.socialId!.isEmpty?true:false;
          provider.userId = value?.data['user']['id'];
          provider.nationality = value?.data['user']['nationality'];
          provider.language = value?.data['user']['languages'];
          provider.stripeId = "" + value?.data['user']['customer_stripe_id'];

        }
        print('printing signature data'+value!.data.toString());




      }).catchError((e) {

        BaseDio.getDioError(e);
      });
  }


}



