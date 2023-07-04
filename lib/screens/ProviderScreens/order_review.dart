import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:kappu/common/validation_dialogbox.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/components/ProviderItem.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/models/serializable_model/AddOrderResponse.dart';
import 'package:kappu/net/base_dio.dart';
import 'package:kappu/net/http_client.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kappu/screens/ProviderScreens/provider_detail.dart';
import 'package:kappu/screens/current_location_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/custom_progress_bar.dart';
import '../../components/MyAppBar.dart';
import '../../models/recommended.dart';
import '../../warning_dialogue.dart';

class OrderReview extends StatefulWidget {
  final Map<String, dynamic> bodyprovider;
  String? address;
  String? lat;
  String? long;
  String? userId;
  String? categoryId;
  OrderReview(
      {this.categoryId,
      this.userId,
      this.long,
      this.address,
      this.lat,
      required this.bodyprovider});

  @override
  _OrderReviewState createState() => _OrderReviewState();
}

class _OrderReviewState extends State<OrderReview> {

  late Future<Map<String,dynamic>> future;
  late GoogleMapController googleMapController;
  late TextEditingController aprtmentController;
  late TextEditingController phoneController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  String selectedPlacee='';
  late DateTime selectedDateTime;
  String formattedDate = '';
  double totalPrice = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Set<Marker> markersList = {};

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  Future<void> _selectTime(BuildContext context) async {
    String formattedTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      final TimeOfDay selectedTime = picked;

      setState(() {
        this.selectedTime = selectedTime;

        final DateTime now = DateTime.now();
        selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        formattedTime = DateFormat('hh:mm a').format(selectedDateTime);
        timeController.text = formattedTime.toString();
      });
    }
  }


  void getloc() async {
    kInitialPosition =
        LatLng(double.parse(widget.lat!), double.parse(widget.long!));
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2040),
    );
    if (picked != null && picked != _selectedDate) {
      formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  int count = 1;

  void decrementCount() {
    setState(() {
      if (count > 1) {
        count--;
      }
    });
  }

  refresh (){
    setState(() {

    });
  }

  PickResult? selectedPlace;
  bool loading = false;

  LatLng kInitialPosition = LatLng(-33.8567844, 151.213108);

  @override
  void initState() {
    getloc();
    future=getDirection();
    refresh();
    print('location ${widget.lat} and ${widget.long}');
    dateController = TextEditingController();
    timeController = TextEditingController();
    aprtmentController = TextEditingController();
    phoneController = TextEditingController();
    if (widget.lat != null) {
      markersList.clear();
      final Marker marker = Marker(
          markerId: MarkerId("2"),
          position:
              LatLng(double.parse(widget.lat!), double.parse(widget.long!)));
      markersList.add(
        marker,
      );
    }

    super.initState();
    // initPaymentSheet();
  }

  Future<Map<String,dynamic>> getDirection ()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
  String? lat=  preferences.getString('lat');
   String? long= preferences.getString('long');
 String? loc=   preferences.getString('currentLocation');
print('printing in function ${loc}');

    return {
      'lat' : lat,
      'long' : long,
      'loc' : loc,
    };



  }

  Future<List<DataModel>> fetchDataList(
      {required String categoryId, required String userId}) async {
    final url = Uri.parse('https://urbanmalta.com/api/services/recommended');
    final body = {
      'category_id': categoryId,
      'user_id': userId,
    };

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      print('response success');
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        print('another success');
        return jsonData
            .map<DataModel>((json) => DataModel.fromJson(json))
            .toList();
      }
    }

    return []; // Return an empty list if fetching or parsing fails
  }



  double? price = 10;
  Future<void> initPaymentSheet(AddOrderResponse data) async {
    try {
      print(data.stripeintent!.toJson().toString());
      await Stripe.instance
          .initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Enable custom flow
          customFlow: true,
          // setupIntentClientSecret: 'sk_test_51Lde8bIv5chsib1PT1sD0GFaWv5viIQzU6zIwIqzOK9ULVWiQChmZ1huNaLibaIUJNszVnpG5Dk64wF0XR08wMnx00x2YIx8vp',
          // Main params
          merchantDisplayName: 'UrbanMalta',
          paymentIntentClientSecret: data.stripeintent!.clientSecret,
          primaryButtonLabel: 'Pay now',
          googlePay: Platform.isAndroid
              ? PaymentSheetGooglePay(
                  merchantCountryCode: 'MT',
                  testEnv: true,
                )
              : null,
          style: ThemeMode.dark,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Colors.white,
              primary: Colors.blue,
            ),
            shapes: PaymentSheetShape(
              borderWidth: 4,
              shadow: PaymentSheetShadowParams(color: AppColors.color_707070),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: AppColors.app_color,
                  text: Colors.white,
                ),
              ),
            ),
          ),
        ),
      )
          .then((value) {
        showPaymentSheet(data.orderData!.id);
      });
    } on StripeException catch (e) {
      setState(() {
        this.loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: "Order Review"),
        backgroundColor: AppColors.app_bg,
        body: Stack(
          children: [
            Container(
              // color: AppColors.app_color,
              child: Column(
                children: [
                  Divider(
                    height: 0.5,
                    color: Colors.grey,
                  ),
                  Expanded(
                      child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        child: getCard(Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Image.asset('assets/images/barber.jpg',
                                        height: 80, width: 100, fit: BoxFit.fill),
                                  ),
                                  Expanded(
                                      child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(15, 0, 15, 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.bodyprovider['name'],
                                                maxLines: 3,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                widget.bodyprovider['desc'],
                                                maxLines: 3,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                         /*     Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Hours : ',
                                                    style: TextStyle(
                                                        color: Colors.black,

                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  Container(
                                                    margin:
                                                    EdgeInsets.only(top: 10, bottom: 10),
                                                    padding: EdgeInsets.only(right: 16),
                                                    height: 50,

                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      color: Color(0xFFF5F5F5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color(0xFFC7C7C7),
                                                          offset: Offset(4, 4),
                                                          blurRadius: 8,
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.white,
                                                          offset: Offset(-4, -4),
                                                          blurRadius: 8,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            print('decrement running');
                                                            setState(() {
                                                              if (count > 1) {
                                                                count--;
                                                                totalPrice = count *
                                                                    double.parse(widget
                                                                        .bodyprovider['price']);
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.only(left: 10),

                                                            child: Icon(
                                                              Icons.remove,
                                                              size: 30,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.only(left: 14),
                                                          child: Center(
                                                            child: Text(
                                                              '${count.toString()}',
                                                              style: TextStyle(

                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(

                                                          child: IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                count++;
                                                                totalPrice = count *
                                                                    double.parse(widget
                                                                        .bodyprovider['price']);
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.add,
                                                              size: 32,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )*/
                                            ],
                                          )))
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Required Hours : ',
                                    style: TextStyle(
                                        color: Colors.black,

                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    margin:
                                    EdgeInsets.only(top: 10, bottom: 10),
                                    padding: EdgeInsets.only(right: 16),
                                    height: 50,

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xFFF5F5F5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFFC7C7C7),
                                          offset: Offset(4, 4),
                                          blurRadius: 8,
                                        ),
                                        BoxShadow(
                                          color: Colors.white,
                                          offset: Offset(-4, -4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            print('decrement running');
                                            setState(() {
                                              if (count > 1) {
                                                count--;
                                                totalPrice = count *
                                                    double.parse(widget
                                                        .bodyprovider['price']);
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10),

                                            child: Icon(
                                              Icons.remove,
                                              size: 30,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 14),
                                          child: Center(
                                            child: Text(
                                              '${count.toString()}',
                                              style: TextStyle(

                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(

                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                count++;
                                                totalPrice = count *
                                                    double.parse(widget
                                                        .bodyprovider['price']);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.add,
                                              size: 32,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                      ),

                      ///more similar gigs are temporarily hidden
                      /* Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 20, bottom: 5, top: 5),
                        child: Text(
                          'More similar GIGs',
                          style: TextStyle(
                              color: AppColors.app_black,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(16)),
                        ),
                      ),


                      FutureBuilder<List<DataModel>>(
                        future: fetchDataList(userId: widget.userId!,categoryId: widget.categoryId!),
                        builder: (BuildContext context, AsyncSnapshot<List<DataModel>> snapshot) {
                          print('pritning mydata ${snapshot.data.toString()}');

                          if (snapshot.connectionState == ConnectionState.waiting) {

                            return Center(child: SizedBox(height: 30,width: 30,child: CircularProgressIndicator()));
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            if (snapshot.hasData) {
                              // Process the data here
                              final data = snapshot.data!;
                              print('pritning mydata ${data.toString()}');
                              return    Container(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 0, bottom: 0),
                                height: 200,
                                child: SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount:data.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () async {
                                            SharedPreferences prefs=await SharedPreferences.getInstance();
                                            String? addres= prefs.getString('currentLocation');
                                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                                              return ProviderDetailScreen(id: snapshot.data![index].id,location:addres ?? 'Malta' ,);
                                            },));
                                          },
                                          child: Container(
                                            width: 150,
                                            margin: const EdgeInsets.only(
                                                right: 10, bottom: 10, top: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: Colors.white),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(10),
                                                          topRight: Radius.circular(10)),
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/tt.png'),
                                                          fit: BoxFit.fill)),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  padding:
                                                  EdgeInsets.only(left: 5, right: 5),
                                                  child:  Text(
                                                    data[index].servicePackage.title.toString(),
                                                    style: TextStyle(
                                                        color: AppColors.app_black,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    RatingBar.builder(
                                                      initialRating: data[index].rating.toDouble(),
                                                      minRating: 1,
                                                      direction: Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemCount: 1,
                                                      itemSize: 13,
                                                      ignoreGestures: true,
                                                      itemPadding:
                                                      EdgeInsets.only(right: 0.1),
                                                      itemBuilder: (context, _) => Icon(
                                                          Icons.star,
                                                          color: Colors.amber),
                                                      onRatingUpdate: (rating) {
                                                        print(rating);
                                                      },
                                                    ),
                                                    Text(
                                                      "${data[index].rating}",
                                                      style: TextStyle(
                                                        color: Color(0xffF79E1F),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          0.005,
                                                    ),
                                                    Text(
                                                      '(${data[index].ratingCount} Rating)',
                                                      style: TextStyle(
                                                          fontSize: 10.sp,
                                                          color: AppColors.text_desc,
                                                          fontFamily:
                                                          "Montserrat-regular"),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  padding:
                                                  EdgeInsets.only(left: 5, right: 5),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          child: Text('Hourly Price',
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                  FontWeight.bold))),
                                                      Text('\€ ${data[index].servicePackage.price}',
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 12,
                                                              fontWeight:
                                                              FontWeight.bold)),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                              );
                            } else {
                              return Text('No data available',style: TextStyle(color: Colors.black),);
                            }
                          }
                        },
                      ),*/

                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        child: getCard(Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Detail',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue.withOpacity(0.15),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.app_color,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Subtotal',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Service Fee",
                                          // widget.bodyprovider['name'],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '\€' + widget.bodyprovider['price'],
                                          style: TextStyle(
                                              color: AppColors.app_color,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '\€' + widget.bodyprovider['price'],
                                          style: TextStyle(
                                              color: AppColors.app_color,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                      ),
                      //  SizedBox(
                      //   height: 5,
                      // ),

                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        child: getCard(Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    width: MediaQuery.of(context).size.width,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      heightFactor: 0.3,
                                      widthFactor: 2.5,
                                      child:FutureBuilder<Map<String, dynamic>>(
                                        future: getDirection(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            // While waiting for the future to complete, show a loading indicator
                                            return CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            // If an error occurs during the future execution, handle it appropriately
                                            return Text('Error: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            final data = snapshot.data!;

                                            // Update your selectedPlacee variable based on the new data
                                            selectedPlacee = data['loc'];

                                            // Return the GoogleMap widget with the updated data
                                            return GoogleMap(
                                              zoomControlsEnabled: true,
                                              zoomGesturesEnabled: true,
                                              markers: markersList,
                                              mapType: MapType.normal,
                                              initialCameraPosition: CameraPosition(
                                                target: LatLng(
                                                  double.parse(data['lat']),
                                                  double.parse(data['long']),
                                                ),
                                                zoom: 14.0,
                                              ),
                                              onMapCreated: (GoogleMapController controller) {
                                                googleMapController = controller;
                                              },
                                            );
                                          } else {
                                            // If the future completes with no data, display an appropriate message
                                            return Text('No data available.');
                                          }
                                        },
                                      )
                                    ),
                                  ),
                                  Positioned(
                                      right: 10,
                                      top: 10,
                                      child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  child: Container(
                                                    child: PlacePicker(
                                                      resizeToAvoidBottomInset:
                                                          false, // only works in page mode, less flickery
                                                      apiKey: Platform.isAndroid
                                                          ? "AIzaSyArdmRIiIuLzzGzTDdm_krtdMTJtY5xBTA"
                                                          : "AIzaSyDIdtmuQa4mIjIF-u-MmkB7hhAiQE_IxXo",
                                                      hintText:
                                                          "Find a place ...",
                                                      searchingText:
                                                          "Please wait ...",
                                                      selectText:
                                                          "Select place",
                                                      outsideOfPickAreaText:
                                                          "Place not in area",
                                                      initialPosition:
                                                          kInitialPosition,
                                                      useCurrentLocation: true,
                                                      selectInitialPosition:
                                                          true,
                                                      usePinPointingSearch:
                                                          true,
                                                      usePlaceDetailSearch:
                                                          true,
                                                      zoomGesturesEnabled: true,
                                                      zoomControlsEnabled: true,
                                                      onMapCreated:
                                                          (GoogleMapController
                                                              controller) {
                                                        print("Map created");
                                                        print("$selectedPlace");
                                                      },
                                                      onPlacePicked:
                                                          (PickResult result) {
                                                        print(
                                                            "Place picked: ${result.formattedAddress}");
                                                        setState(() {
                                                          selectedPlace =
                                                              result;
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      },
                                                      onMapTypeChanged:
                                                          (MapType mapType) {
                                                        print(
                                                            "Map type changed to ${mapType.toString()}");
                                                      },
                                                      // #region additional stuff
                                                      // forceSearchOnZoomChanged: true,
                                                      // automaticallyImplyAppBarLeading: false,
                                                      // autocompleteLanguage: "ko",
                                                      // region: 'au',
                                                      pickArea: CircleArea(
                                                        center:
                                                            kInitialPosition,
                                                        radius: 300,
                                                        fillColor: Colors.blue
                                                            .withOpacity(0.5),
                                                        strokeColor: Colors
                                                            .lightGreen
                                                            .withGreen(255)
                                                            .withAlpha(192),
                                                        strokeWidth: 2,
                                                      ),
                                                      selectedPlaceWidgetBuilder:
                                                          (_,
                                                              selectedPlace,
                                                              state,
                                                              isSearchBarFocused) {
                                                        print(
                                                            "state: $state, isSearchBarFocused: $isSearchBarFocused");
                                                        return isSearchBarFocused
                                                            ? Container()
                                                            : FloatingCard(
                                                                bottomPosition:
                                                                    10, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                                                leftPosition:
                                                                    0.0,
                                                                rightPosition:
                                                                    0.0,
                                                                color: Colors
                                                                    .transparent,
                                                                // width: MediaQuery.of(context).size.width * 0.4,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                                child: state ==
                                                                        SearchingState
                                                                            .Searching
                                                                    ? SizedBox(
                                                                        height:
                                                                            50,
                                                                        child: Center(
                                                                            child: CircularProgressIndicator(
                                                                          color:
                                                                              Colors.white,
                                                                        )))
                                                                    : Container(
                                                                        color: Colors
                                                                            .transparent,
                                                                        padding: EdgeInsets.only(
                                                                            left: MediaQuery.of(context).size.width *
                                                                                0.2,
                                                                            right:
                                                                                MediaQuery.of(context).size.width * 0.2),
                                                                        child: SizedBox(
                                                                            width: 100,
                                                                            child: InkWell(
                                                                                child: Container(
                                                                                  height: 50,
                                                                                  width: 30,
                                                                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)),
                                                                                  child: SizedBox(
                                                                                      height: 50,
                                                                                      child: Center(
                                                                                          child: loading
                                                                                              ? CircularProgressIndicator(
                                                                                                  color: Colors.white,
                                                                                                )
                                                                                              : Text(
                                                                                                  "Confirm",
                                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                                                                                ))),
                                                                                ),
                                                                                onTap: () async {
//                                   // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
//                                   //            this will override default 'Select here' Button.
                                                                                  loading = true;

                                                                                  setState(() {});
                                                                                  print("do something with [selectedPlace] data");
                                                                                  print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                                                                                  print(selectedPlace!.formattedAddress!);
                                                                                  print("(lat: " + selectedPlace.geometry!.location.lat.toString());
                                                                                  print("(lng: " + selectedPlace.geometry!.location.lng.toString());

                                                                                  String lattitude;
                                                                                  String longitude;

                                                                                  if (selectedPlace.geometry?.location.lat == null && selectedPlace.geometry?.location.lng == null) {
                                                                                    lattitude = kInitialPosition.latitude.toString();
                                                                                    longitude = kInitialPosition.longitude.toString();
                                                                                  } else {
                                                                                    lattitude = selectedPlace.geometry!.location.lat.toString();
                                                                                    longitude = selectedPlace.geometry!.location.lng.toString();
                                                                                  }

                                                                                  if (kDebugMode) {
                                                                                    print('printing from selectedpLACE ${selectedPlace.geometry?.location.lat}');
                                                                                  }
                                                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                  prefs.setString('currentLocation', '${selectedPlace.name}');
                                                                                  prefs.setString('lat', lattitude);
                                                                                  prefs.setString('long', longitude);

                                                                                  print('formated address ${selectedPlace.formattedAddress}');

                                                                                  print('lattitude ${lattitude}');

                                                                                  print('longitude ${longitude}');
                                                                                  getDirection();
          refresh();
                                                                                  loading = false;

                                                                                 // refresh(lattitude: lattitude, longitude: longitude, place: selectedPlace.name!);

                                                                                  Navigator.pop(context);
                                                                                })),
                                                                      ),
                                                              );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ))),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 20, right: 8, bottom: 10),
                                      width: MediaQuery.of(context).size.width,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Color(0xffFBFBFB),
                                        border: Border.all(
                                            color: Colors.grey, width: 0.3),
                                      ),
                                      child: TextFormField(
                                        controller: aprtmentController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Appt./office",
                                          hintStyle: TextStyle(
                                              fontSize: 13, color: Colors.blue),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter apartment/office no';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 20, right: 8, bottom: 10),
                                      width: MediaQuery.of(context).size.width,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Color(0xffFBFBFB),
                                        border: Border.all(
                                            color: Colors.grey, width: 0.3),
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.phone,
                                        controller: phoneController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Phone Number",
                                          hintStyle: TextStyle(
                                              fontSize: 13, color: Colors.blue),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter Phone Number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 20, right: 8, bottom: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.4,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Color(0xffFBFBFB),
                                            border: Border.all(
                                                color: Colors.grey, width: 0.3),
                                          ),
                                          child: TextFormField(
                                            controller: dateController,
                                            onTap: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2023),
                                                lastDate: DateTime(2040),
                                              );
                                              if (picked != null &&
                                                  picked != _selectedDate) {
                                                formattedDate =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(picked);
                                                setState(() {
                                                  _selectedDate = picked;
                                                  dateController.text =
                                                      formattedDate;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Select Date",
                                              hintStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please select a date';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 20, right: 8, bottom: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.4,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Color(0xffFBFBFB),
                                            border: Border.all(
                                                color: Colors.grey, width: 0.3),
                                          ),
                                          child: TextFormField(
                                            controller: timeController,
                                            onTap: () {
                                              _selectTime(context);
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Select Time",
                                              hintStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please select a time';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )

                              /* Form(
                               key: _formKey,
                               child: Column(children: [
                                 Container(
                                   padding: EdgeInsets.only(
                                       left: 10, right: 8, bottom: 8),
                                   width: MediaQuery.of(context).size.width,
                                   height: 45,
                                   decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(30),
                                       color: Color(0xffFBFBFB),
                                       border: Border.all(
                                           color: Colors.grey, width: 0.3)),
                                   child: TextFormField(
                                     controller: aprtmentController,
                                     decoration: InputDecoration(
                                         border: InputBorder.none,
                                         hintText: " Appt./office",
                                         hintStyle: TextStyle(fontSize: 13)),
                                   ),
                                 ),
                                 SizedBox(
                                   height: 10,
                                 ),
                                 Container(
                                   padding: EdgeInsets.only(
                                       left: 10, right: 8, bottom: 8),
                                   width: MediaQuery.of(context).size.width,
                                   height: 45,
                                   decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(30),
                                       color: Color(0xffFBFBFB),
                                       border: Border.all(
                                           color: Colors.grey, width: 0.3)),
                                   child: TextFormField(
                                     controller: phoneController,
                                     decoration: InputDecoration(
                                         border: InputBorder.none,
                                         hintText: " Phone Number",
                                         hintStyle: TextStyle(fontSize: 13)),
                                   ),
                                 ),
                                 SizedBox(
                                   height: 10,
                                 ),
                                 Row(
                                   mainAxisAlignment:
                                   MainAxisAlignment.spaceBetween,
                                   children: [
                                     Container(
                                       padding: EdgeInsets.only(
                                           left: 10, right: 8, bottom: 8),
                                       width:
                                       MediaQuery.of(context).size.width / 2.4,
                                       height: 45,
                                       decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(30),
                                           color: Color(0xffFBFBFB),
                                           border: Border.all(
                                               color: Colors.grey, width: 0.3)),
                                       child: TextFormField(
                                         controller: dateController,
                                         onTap: () async {
                                           final DateTime? picked =
                                           await showDatePicker(
                                             context: context,
                                             initialDate: DateTime.now(),
                                             firstDate: DateTime(2023),
                                             lastDate: DateTime(2040),
                                           );
                                           if (picked != null &&
                                               picked != _selectedDate) {
                                             formattedDate =
                                                 DateFormat('dd/MM/yyyy')
                                                     .format(picked);
                                             setState(() {
                                               _selectedDate = picked;
                                               dateController.text = formattedDate;
                                             });
                                           }
                                         },
                                         decoration: InputDecoration(
                                             border: InputBorder.none,
                                             hintText: " Select Date",
                                             hintStyle: TextStyle(fontSize: 13)),
                                       ),
                                     ),
                                     Container(
                                       padding: EdgeInsets.only(
                                           left: 10, right: 8, bottom: 8),
                                       width:
                                       MediaQuery.of(context).size.width / 2.4,
                                       height: 45,
                                       decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(30),
                                           color: Color(0xffFBFBFB),
                                           border: Border.all(
                                               color: Colors.grey, width: 0.3)),
                                       child: TextFormField(
                                         controller: timeController,
                                         onTap: () {
                                           _selectTime(context);
                                         },
                                         decoration: InputDecoration(
                                             border: InputBorder.none,
                                             hintText: "Select Time",
                                             hintStyle: TextStyle(fontSize: 13)),
                                       ),
                                     ),
                                   ],
                                 )
                               ],),
                             )*/
                            ],
                          ),
                        )),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        child: getCard(Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order Summary',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.keyboard_arrow_down_sharp)
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          "Subtotal",
                                          // '\€' + widget.bodyprovider['price'],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        )),
                                        Text(
                                          "",
                                          // '\€' + widget.bodyprovider['price'],
                                          style: TextStyle(
                                              color: AppColors.app_color,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          'Card',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        )),
                                        Text(
                                          totalPrice == 0
                                              ? '\€${widget.bodyprovider['price']}'
                                              : totalPrice.toString(),
                                          style: TextStyle(
                                              color: AppColors.app_color,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            height: 22,
                                            width: 60,
                                            decoration: BoxDecoration(
                                                color: AppColors.app_color,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: Center(
                                              child: Text(
                                                "Change",
                                                // '\€10',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                            ],
                          ),
                        )),
                      ),
                      InkWell(
                          onTap: () async {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(),));
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                this.loading = true;
                              });
                              placeOrder(StorageManager().accessToken,
                                  StorageManager().userId, context);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: AppColors.app_color,
                            ),
                            child: Text(
                              'Place Order',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ))
                    ],
                  )),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            if (loading) const CustomProgressBar()
          ],
        ));
  }

  placeOrder(token, userId, context) {
    HttpClient()
        .addOrder(
            widget.address! ?? 'Malta',
            'Bearer ' + token,
            totalPrice == 0
                ? double.parse(widget.bodyprovider['price']).round().toString()
                : totalPrice.round().toString(),
            widget.bodyprovider['provider_id'].toString(),
            widget.bodyprovider['service_id'].toString(),
            userId.toString(),
            widget.bodyprovider['location'],
            "EUR",
            "0",
            widget.lat!,
            widget.long!,
            aprtmentController.text,
            phoneController.text,
            dateController.text,
            selectedDateTime)
        .then((value) => {
              print('printing status vallue ${value.status}'),
              print('printing status vallue ${value.message}'),
              if (value.status)
                {
                  // showSuccessDialog(context, value.message)
                  initPaymentSheet(value)
                }
            })
        .catchError((e) {
      print(
          'printing all stuff ${widget.address! + double.parse(widget.bodyprovider['price']).round().toString() + widget.bodyprovider['provider_id'].toString() + widget.bodyprovider['service_id'].toString() + userId.toString() + widget.bodyprovider['location'] + "EUR" + "0" + widget.lat! + widget.long! + aprtmentController.text + phoneController.text + dateController.text + timeController.text}');

      BaseDio.getDioError(e);
    });
  }

  showSuccessDialog(context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WarningDialogBox(
            title: 'Success',
            descriptions: message,
            buttonTitle: 'ok',
            buttonColor: AppColors.color_green,
            icon: Icons.check,
            onPressed: () {
              print('ok');
              Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        });
  }

  showBookingSuccessDialog(context, String message) async {
    await Future.delayed(Duration(seconds: 2)).then((value) {
      Navigator.pop(context);
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WarningDialog2Box(
            title: 'Success',
            descriptions: message,
            buttonTitle: 'ok',
            buttonColor: AppColors.color_green,
            icon: Icons.check,
            onPressed: () {
              print('ok');
              Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        });
  }

  void showPaymentSheet(orderId) async {
    await Stripe.instance.presentPaymentSheet().then((value) {
      HttpClient().orderPayment(orderId.toString()).then((value) {
        setState(() {
          this.loading = false;
        });
        showBookingSuccessDialog(
          context,
          "Payment done",
        );
      }).onError((error, stackTrace) {});
    }).onError((error, stacktrace) {
      setState(() {
        this.loading = false;
      });
    });
  }
}

_createTestPaymentSheet() async {}
