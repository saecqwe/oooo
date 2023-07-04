import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/components/AppColors.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/models/serializable_model/RecommendedServiceProvidersResponse.dart';
import 'package:kappu/screens/catagories/search_catagories_screen.dart';
import 'package:kappu/screens/home_page/widgets/best_services.dart';
import 'package:kappu/screens/home_page/widgets/slider.dart';
import 'package:kappu/screens/login/login_screen.dart';
import 'package:kappu/screens/settings/settings_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/promo_model.dart';
import '../../warning_dialogue.dart';
import '../ProviderScreens/provider_detail.dart';
import '../slider_offers.dart';
import 'widgets/search_text_field.dart';
import 'widgets/services_container.dart';
import 'package:http/http.dart' as http;


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  Future<PromoResponse>? _future;

  String loc = 'Malta';
  int pageNumber = 0;
  final CarouselController _controller = CarouselController();
  @override
  bool get wantKeepAlive => true;
  @override
  initState() {
    // TODO: implement initState
    getLoc();
    _future = fetchData();

    super.initState();
  }
  Future<PromoResponse> fetchData() async {
    final url = 'https://urbanmalta.com/api/home/'; // Replace with the actual API endpoint

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('printing Presponse ${response.body.toString()}' );

      return PromoResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch data');
    }
  }
  Future<void> getLoc() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      loc = preferences.getString('currentLocation')!;
    });
  }


  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 40, left: 10, right: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 30,
                        color: AppColors.app_color,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current location',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xff7B7D83)),
                          ),
                          Text(
                            loc ?? 'Malta',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xff7B7D83)),
                          )
                        ],
                      )),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                            // radius: 30,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                if (StorageManager().accessToken.isNotEmpty) {
                                  pushDynamicScreen(context,
                                      screen: SettingsRoutePage(),
                                      withNavBar: false);
                                } else {
                                  bottomSheetForSignIn(context);
                                }
                              },
                              icon: const Icon(
                                Icons.account_circle_outlined,
                                color: AppColors.app_color,
                                size: 30,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                // const SizedBox(height: 5,),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Image.asset(
                //       'assets/images/colorfulLogo.png',
                //       width: MediaQuery.of(context).size.width * 0.14,
                //       height: MediaQuery.of(context).size.height * 0.05,
                //     ),
                //     Text(
                //       'URBAN MALTA',
                //       style: TextStyle(
                //           fontSize: 22,
                //           color: AppColors.app_color,
                //           fontWeight: FontWeight.bold),
                //     )
                //   ],
                // ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(6)),
                    child: GestureDetector(
                      onTap: () {},
                      child: SearchTextField(
                        enable: true,
                        hintext: "Search Services",
                        value: "",
                        onSearchingComplete: (value) {
                          print('aaaa');
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  SearchCatagoriesScreen(searchtext: value)));
                        },
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),

            /*Container(
              height: ScreenUtil().setHeight(160),
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: ScreenUtil().setHeight(30),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                    child: Row(children: [
                      Image.asset(
                        'assets/images/colorfulLogo.png',
                        width: MediaQuery.of(context).size.width * 0.14,
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(5, 2, 2, 2.0),
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Text("Current Location",
                      //           style: TextStyle(
                      //               color: AppColors.title_desc,
                      //               fontSize: ScreenUtil().setSp(10),
                      //               fontWeight: FontWeight.w500)),
                      //       Text("Germany",
                      //           style: TextStyle(
                      //               color: AppColors.text_desc,
                      //               fontSize: ScreenUtil().setSp(14),
                      //               fontWeight: FontWeight.w500))
                      //     ],
                      //   ),
                      // ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                            // radius: 30,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                // if (StorageManager().accessToken.isNotEmpty) {
                                pushDynamicScreen(context,
                                    screen: SettingsPage(), withNavBar: false);
                                // } else {
                                //   changeScreen(
                                //       context: context,
                                //       screen: LoginScreen(isFromOtherScreen: true));
                                // }
                              },
                              icon: const Icon(
                                Icons.account_circle_outlined,
                                color: AppColors.app_color,
                              ),
                            )),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(15),
                      )
                    ]),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(15),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(6)),
                    child: SearchTextField(
                      hintext: "Search Services",
                      onSearchingComplete: () {},
                    ),
                  )
                ],
              ),
            ),*/
            Expanded(
                child: Container(
              color: AppColors.color_f2f7fd,
              child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      20.verticalSpace,
                    /*  CarouselSlider(
                        carouselController: _controller,
                        items: [
                          Container(
                            // margin: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              // color: Colors.amber,
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: AssetImage("assets/img/computer.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            // margin: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: AssetImage("assets/img/plumber.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            // margin: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: AssetImage("assets/img/elec.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            // margin: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: AssetImage("assets/img/doctor.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        options: CarouselOptions(
                            height: 180.0,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            aspectRatio: 16 / 9,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                            onPageChanged: (index, reason) {
                              setState(() {
                                pageNumber = index;
                              });
                            }),
                      ),*/
                       SliderWidget(),

                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 20, bottom: 5),
                        child: Text(
                          'Popular Services',
                          style: TextStyle(
                              color: AppColors.app_color,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(18)),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: const OurBestServices(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.white,
                              onTap: () {},
                              child: Container(
                                  height: h * .03,
                                  width: w * .066,
                                  // color: Colors.blue,
                                  child: const Center(
                                      // child:
                                      // Text(
                                      //   "View All",
                                      //   style: TextStyle(
                                      //       color: AppColors.app_color,
                                      //       fontSize: 11),
                                      // ),
                                      )),
                            ),
                          ),
                          // Container(
                          //   height: h * .03,
                          //   width: w * .07,
                          //   // margin: EdgeInsets.all(5),
                          //   // padding: EdgeInsets.all(),
                          //   decoration: const BoxDecoration(
                          //       color: Colors.white, shape: BoxShape.circle),
                          //   child: const Icon(
                          //     Icons.arrow_forward_ios,
                          //     color: Color(0xff4995EB),
                          //     size: 13,
                          //   ),
                          // )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 20, bottom: 5, top: 5),
                        child: Text(
                          'Best Services',
                          style: TextStyle(
                              color: AppColors.app_color,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(18)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: const Servicescontainer(),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Container(
                      //       height: h * .04,
                      //       width: w * .14,
                      //       // color: Colors.amber,
                      //       margin: EdgeInsets.only(left: 2, right: 2),
                      //       child: Row(
                      //         children: [
                      //           Material(
                      //             color: Colors.transparent,
                      //             child: InkWell(
                      //               splashColor: Colors.white,
                      //               onTap: () {},
                      //               child: Container(
                      //                   height: h * .03,
                      //                   width: w * .066,
                      //                   // color: Colors.blue,
                      //                   child: const Center(
                      //                       // child: Text(
                      //                       //   "View All",
                      //                       //   style: TextStyle(
                      //                       //       color: AppColors.app_color,
                      //                       //       fontSize: 11),
                      //                       // ),
                      //                       )),
                      //             ),
                      //           ),
                      //           Container(
                      //             height: h * .03,
                      //             width: w * .07,
                      //             // margin: EdgeInsets.all(5),
                      //             // padding: EdgeInsets.all(),
                      //             decoration: const BoxDecoration(
                      //                 color: Colors.white,
                      //                 shape: BoxShape.circle),
                      //             child: const Icon(
                      //               Icons.arrow_forward_ios,
                      //               color: Color(0xff4995EB),
                      //               size: 13,
                      //             ),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      //----------------Most Recent View Section---------------------------//
                      const SizedBox(height: 20),
                 FutureBuilder<PromoResponse>(future: _future,builder: (context, snapshott) {
                   if(snapshott.hasData){
                     List<Widget> children=[];
                     var data=snapshott.data!.carosuel;
                     for (int indexx=1; indexx<data.length; indexx++) {
                       var element=snapshott.data!.carosuel[indexx];
                       DateTime dateTime = DateTime.parse(snapshott.data!.carosuel[indexx].createdAt);
                       DateTime updatedAt = DateTime.parse(snapshott.data!.carosuel[indexx].updatedAt);
                       print(dateTime);
                       if(indexx == 2){

                         children.add( Column(
                           children: [
                             Container(
                               height: h * .22,
                               // width: w * .7,

                               margin: EdgeInsets.only(left: 10, right: 10),
                               decoration: BoxDecoration(
                                 // color: Colors.amber,
                                   image: DecorationImage(
                                       fit: BoxFit.cover,
                                       image: NetworkImage("https://urbanmalta.com/public/uploads/banners/${snapshott.data!.banners[0].image}")),
                                   borderRadius: BorderRadius.circular(15)),
                               child: Container(
                                 height: h * .22,
                                 // width: w * .7,
                                 decoration: BoxDecoration(
                                     color: AppColors.app_color.withOpacity(0.5),
                                     borderRadius: BorderRadius.circular(15)),
                                 child: Row(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     SizedBox(width: w * 0.05),
                                     Column(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           "${snapshott.data!.banners[0].title}",
                                           style: TextStyle(
                                               color: Colors.white,
                                               fontSize: 17,
                                               fontWeight: FontWeight.bold),
                                         ),
                                         SizedBox(
                                           height: h * .02,
                                         ),
                                         Text(
                                           "${snapshott.data!.banners[0].desc}",
                                           style: TextStyle(
                                               color: Colors.white, fontSize: 12),
                                         ),



                                         SizedBox(
                                           height: h * .02,
                                         ),
                                         InkWell(
                                           onTap: () async {

                                             pushDynamicScreen(context,
                                                 screen: ProviderOffersFromHomePage(
                                                     serviceid: snapshott.data!.banners[0].id,
                                                     name: snapshott.data!.banners[0].title,
                                                     desc:snapshott.data!.banners[0].desc),
                                                 withNavBar: false);
                                             /*pushDynamicScreen(context,
                                                 screen:
                                                 withNavBar: false);*/
                                           },
                                           child: Container(
                                             height: h * .05,
                                             width: w * .15,
                                             decoration: BoxDecoration(
                                                 color: Colors.black,
                                                 borderRadius:
                                                 BorderRadius.circular(30)),
                                             child: Center(
                                               child: Text(
                                                 "Book Now",
                                                 style: TextStyle(
                                                     color: Colors.white,
                                                     fontWeight: FontWeight.bold,
                                                     fontSize: 10),
                                               ),
                                             ),
                                           ),
                                         )
                                       ],
                                     )
                                   ],
                                 ),
                               ),
                             ),
                             SizedBox(height: 20,),
                           ],
                         ));





                       }
                       else if(indexx== 4){
                         if(snapshott.data!.banners.length>0) {
                           children.add(InkWell(
                             onTap: (){

                             },
                             child: Column(
                               children: [
                                 Container(
                                   height: h * .21,
                                   width: w,
                                   margin: EdgeInsets.only(left: 10, right: 10),
                                   decoration: BoxDecoration(
                                       color: Color(0xff4995EB),
                                       borderRadius: BorderRadius.circular(15)),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       SizedBox(width: w * 0.05),
                                       Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text(
                                             "${snapshott.data!.promocode[0].title}",
                                             style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.bold),
                                           ),
                                           SizedBox(
                                             height: h * .01,
                                           ),
                                           Container(
                                             height: h * .045,
                                             // width: w * .4,

                                             child: Text(
                                               "${snapshott.data!.promocode[0].desc}",
                                               style: TextStyle(
                                                   color: Colors.white, fontSize: 9),
                                             ),
                                           ),
                                           SizedBox(
                                             height: h * .02,
                                           ),
                                           InkWell(
                                             onTap: () {},
                                             child: Container(
                                               height: h * .05,
                                               width: w * .18,
                                               padding:
                                               EdgeInsets.only(left: 15, right: 10),
                                               decoration: BoxDecoration(
                                                   color: Colors.black,
                                                   borderRadius:
                                                   BorderRadius.circular(30)),
                                               child: InkWell(
                                                 onTap: () {

                                                   pushDynamicScreen(context,
                                                       screen: ProviderOffersFromHomePage(
                                                           serviceid: snapshott.data!.promocode[0].id!,
                                                           name: snapshott.data!.promocode[0].title!,
                                                           desc:snapshott.data!.promocode[0].desc),
                                                       withNavBar: false);

                                                 },
                                                 child: Row(
                                                   mainAxisAlignment:
                                                   MainAxisAlignment.spaceEvenly,
                                                   children: [
                                                     Text(
                                                       "${snapshott.data!.promocode[0].status}",
                                                       style: TextStyle(
                                                           color: Colors.white,
                                                           fontWeight: FontWeight.bold,
                                                           fontSize: 10),
                                                     ),
                                                     Container(
                                                       height: h * .03,
                                                       width: w * .04,
                                                       // margin: EdgeInsets.all(5),
                                                       // padding: EdgeInsets.all(),
                                                       decoration: BoxDecoration(
                                                           color: Colors.white,
                                                           shape: BoxShape.circle),
                                                       child: Icon(
                                                         Icons.arrow_forward_ios,
                                                         color: Color(0xff4995EB),
                                                         size: 13,
                                                       ),
                                                     )
                                                   ],
                                                 ),
                                               ),
                                             ),
                                           )
                                         ],
                                       )
                                     ],
                                   ),
                                 ),
                                 SizedBox(height: 20,),

                               ],
                             ),
                           ));
                         }else{
                           children.add(Container());
                         }

                       }

                         children.add(Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Container(
                               alignment: Alignment.centerLeft,
                               height: h * .04,
                               width: w * .3,
                               // color: Colors.black,
                               padding: EdgeInsets.only(left: 10),
                               child: Text("${element.heading}",
                                   style: TextStyle(
                                       color: AppColors.app_color,
                                       fontWeight: FontWeight.bold,
                                       fontSize: ScreenUtil().setSp(18))),
                             ),
                             const SizedBox(height: 10,),
                             Container(
                               height: h * .20,
                               width: w * .85,
                               child: ListView.builder(
                                 itemCount: element.services.length,
                                 scrollDirection: Axis.horizontal,
                                 itemBuilder: (context, index) {
                                   DateTime datettime = DateTime.parse(snapshott.data!.carosuel[indexx].services[index].servicePackages!.createdAt);
                                   DateTime updated = DateTime.parse(snapshott.data!.carosuel[indexx].services[index].servicePackages!.updatedAt);

                                   List<Gigdocument> gigdoc=[];
                                   Servicepackages sp=Servicepackages(id: snapshott.data!.carosuel[indexx].services[index].servicePackages?.id,description: snapshott.data!.carosuel[indexx].services[index].servicePackages?.description,title: snapshott.data!.carosuel[indexx].services[index].servicePackages?.title,createdAt: datettime,extraForUrgentNeed: snapshott.data!.carosuel[indexx].services[index].servicePackages?.extraForUrgentNeed,location: snapshott.data!.carosuel[indexx].services[index].servicePackages?.location,price: snapshott.data!.carosuel[indexx].services[index].servicePackages?.price,serviceId: snapshott.data!.carosuel[indexx].services[index].servicePackages?.serviceId,updatedAt: updated);
                                   snapshott.data!.carosuel[indexx].services[index].gigDocument.forEach((elementt) {
                                     gigdoc.add(Gigdocument(id: elementt.id,serviceid: elementt.serviceId,fileType: elementt.fileType,fileName: elementt.fileName,userid: elementt.userId));
                                   });
                                   RecommendedServiceProvidersResponse response= RecommendedServiceProvidersResponse(categoryId: int.parse(snapshott.data!.carosuel[indexx].categoryId),createdAt: dateTime,title: snapshott.data!.carosuel[indexx].services[index].title,id:snapshott.data!.carosuel[indexx].services[index].id,description: snapshott.data!.carosuel[indexx].services[index].description,gigdocument: gigdoc,isDeleted: false,isPaused: false,rating: 5,ratingCount: 5,reviewCount: 5,servicepackages:sp,updatedAt: updatedAt,slug: snapshott.data!.carosuel[indexx].services[index].slug,userData: snapshott.data!.carosuel[indexx].services[index].userData,userId: snapshott.data!.carosuel[indexx].services[index].userId );


                                   return InkWell(
                                     onTap: () async {


                                       SharedPreferences prefs=await SharedPreferences.getInstance();
                                       String? addres= prefs.getString('currentLocation');
                                       Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                         return ProviderDetailScreen(id: response.id!,location:addres ?? 'Malta' ,);
                                       },));
                                     },
                                     child: Container(
                                       height: h * .20,
                                       width: w * .19,
                                       clipBehavior: Clip.antiAlias,
                                       margin: const EdgeInsets.only(
                                           left: 5, right: 5, bottom: 5),
                                       decoration: BoxDecoration(
                                           boxShadow: [
                                             BoxShadow(
                                               color: Colors.black12,
                                               offset: Offset(
                                                 1.3,
                                                 1.3,
                                               ), //Offset
                                               blurRadius: 1.0,
                                               spreadRadius: 1.0,
                                             ),
                                           ],
                                           color: Colors.black,
                                           borderRadius:
                                           BorderRadius.circular(10)),
                                       child: Column(
                                         children: [
                                           Container(
                                             height: h * .13,
                                             width: w,
                                             // color: Colors.blue,
                                             child: Image.network(
                                               "https://urbanmalta.com/public/users/user_${element.services[index].userId}/documents/${element.services[index].gigDocument[0].fileName}",
                                               fit: BoxFit.fill,
                                             ),
                                           ),
                                           Expanded(
                                               child: Container(
                                                   height: h,
                                                   width: w,
                                                   padding: EdgeInsets.only(
                                                       left: 2, right: 2),
                                                   color: Colors.white,
                                                   child: Center(
                                                       child: Text(
                                                         "${element.services[index].title}",
                                                         textAlign: TextAlign.center,
                                                         style: TextStyle(
                                                           color: AppColors.text_desc,
                                                           fontSize:
                                                           ScreenUtil().setSp(12),
                                                           fontFamily:
                                                           "Montserrat-bold",
                                                         ),
                                                       ))))
                                         ],
                                       ),
                                     ),
                                   );


                                 },
                               ),
                             ),
                             const SizedBox(height: 10,),

                           ],
                         ),);

                     }
                     return Container(


                       // color: Colors.amber,
                       padding: EdgeInsets.only(left: 10),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           SizedBox(height: 20,),

                           ...children,

                           SizedBox(height: 20,),


                           // SizedBox(
                           //   height: h * .02,
                           // ),
                           // Row(
                           //   mainAxisAlignment: MainAxisAlignment.end,
                           //   children: [
                           //     Container(
                           //       height: h * .04,
                           //       width: w * .14,
                           //       // color: Colors.amber,
                           //       margin: EdgeInsets.only(left: 2, right: 2),
                           //       child: Row(
                           //         children: [
                           //           Material(
                           //             color: Colors.transparent,
                           //             child: InkWell(
                           //               splashColor: Colors.white,
                           //               onTap: () {},
                           //               child: Container(
                           //                   height: h * .03,
                           //                   width: w * .06,
                           //                   // color: Colors.blue,
                           //                   child: Center(
                           //                       // child: Text(
                           //                       //   "View All",
                           //                       //   style: TextStyle(
                           //                       //       color: Color(0xff4995EB),
                           //                       //       fontSize: 11),
                           //                       // ),
                           //                       )),
                           //             ),
                           //           ),
                           //           Container(
                           //             height: h * .03,
                           //             width: w * .07,
                           //             // margin: EdgeInsets.all(5),
                           //             // padding: EdgeInsets.all(),
                           //             decoration: BoxDecoration(
                           //                 color: Colors.white,
                           //                 shape: BoxShape.circle),
                           //             child: Icon(
                           //               Icons.arrow_forward_ios,
                           //               color: Color(0xff4995EB),
                           //               size: 13,
                           //             ),
                           //           )
                           //         ],
                           //       ),
                           //     ),
                           //   ],
                           // ),
                         ],
                       ),
                     );
                   }
                   else {
                     return Center(child: CircularProgressIndicator(),);
                   }
                 },),



                      //----------------------------------Book Now Section-------------------------------------//

                      SizedBox(
                        height: h * .03,
                      ),
                      //------------------------------Hair Dresses Section-------------------//
                     /* Container(
                        height: h * .32,
                        width: w,
                        // color: Colors.amber,
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: h * .04,
                              width: w,
                              // color: Colors.black,
                              padding: EdgeInsets.only(left: 6),
                              child: Text("Hair Dresser For Men",
                                  style: TextStyle(
                                      color: AppColors.app_color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(18))),
                            ),
                            SizedBox(
                              height: h * .02,
                            ),
                            Container(
                              height: h * .21,
                              width: w * .85,
                              child: ListView.builder(
                                itemCount: 7,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: h * .21,
                                    width: w * .195,
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(
                                              1.3,
                                              1.3,
                                            ), //Offset
                                            blurRadius: 1.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        // color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: h * .13,
                                          width: w,
                                          // color: Colors.blue,
                                          child: Image.asset(
                                            "assets/images/Dresser.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: h,
                                            width: w,
                                            color: Colors.white,
                                            padding: EdgeInsets.only(
                                              left: 5,
                                              top: 3,
                                              bottom: 2,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: h * .02,
                                                      width: w * .1,
                                                      // color: Colors.amber,
                                                      child: Text("John Carter",
                                                          style: TextStyle(
                                                            // color: AppColors
                                                            //     .text_desc,
                                                            color: Colors.black,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(11),
                                                            fontFamily:
                                                                "Montserrat-bold",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      width: w * .02,
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 12,
                                                    ),
                                                    // SizedBox(
                                                    //   width: w * .01,
                                                    // ),
                                                    Container(
                                                      height: h * .027,
                                                      width: w * .035,
                                                      // color: Colors.red,
                                                      child: Center(
                                                        child: Text(
                                                          "4.5",
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.amber),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: h * .01,
                                                ),
                                                Text("Hair Dresser",
                                                    style: TextStyle(
                                                      // color: Colors.black,
                                                      // fontSize: 10,
                                                      color:
                                                          AppColors.text_desc,
                                                      fontSize:
                                                          ScreenUtil().setSp(9),
                                                      fontFamily:
                                                          "Montserrat-bold",
                                                    )),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            //   SizedBox(
                            // height: h * .01,
                            //   ),
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       Container(
                            //         height: h * .04,
                            //         width: w * .14,
                            //         // color: Colors.amber,
                            //         margin: EdgeInsets.only(left: 2, right: 2),
                            //         child: Row(
                            //           children: [
                            //             Material(
                            //               color: Colors.transparent,
                            //               child: InkWell(
                            //                 splashColor: Colors.white,
                            //                 onTap: () {},
                            //                 child: Container(
                            //                     height: h * .03,
                            //                     width: w * .066,
                            //                     // color: Colors.blue,
                            //                     child: Center(
                            //                         // child: Text(
                            //                         //   "View All",
                            //                         //   style: TextStyle(
                            //                         //       color:
                            //                         //           AppColors.app_color,
                            //                         //       fontSize: 11),
                            //                         // ),
                            //                         )),
                            //               ),
                            //             ),
                            //             Container(
                            //               height: h * .03,
                            //               width: w * .07,
                            //               // margin: EdgeInsets.all(5),
                            //               // padding: EdgeInsets.all(),
                            //               decoration: BoxDecoration(
                            //                   color: Colors.white,
                            //                   shape: BoxShape.circle),
                            //               child: Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: Color(0xff4995EB),
                            //                 size: 13,
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // //
                          ],
                        ),
                      ),
                      SizedBox(
                        height: h * .01,
                      ),
                      //-----------------------------New House Section-----------------------------//
                      Container(
                        height: h * .32,
                        width: w,
                        // color: Colors.amber,
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: h * .04,
                              width: w,
                              // color: Colors.black,
                              padding: EdgeInsets.only(left: 6),
                              child: Text("New In the House ",
                                  style: TextStyle(
                                      color: AppColors.app_color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(18))),
                            ),
                            SizedBox(
                              height: h * .02,
                            ),
                            Container(
                              height: h * .20,
                              width: w * .85,
                              child: ListView.builder(
                                itemCount: 7,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: h * .20,
                                    width: w * .19,
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(
                                              1.3,
                                              1.3,
                                            ), //Offset
                                            blurRadius: 1.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: h * .13,
                                          width: w,
                                          // color: Colors.blue,
                                          child: Image.asset(
                                            "assets/images/doct.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                                height: h,
                                                width: w,
                                                padding: EdgeInsets.only(
                                                    left: 2, right: 2),
                                                color: Colors.white,
                                                child: Center(
                                                    child: Text(
                                                  "Doctor",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColors.text_desc,
                                                    fontSize:
                                                        ScreenUtil().setSp(12),
                                                    fontFamily:
                                                        "Montserrat-bold",
                                                  ),
                                                ))))
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // SizedBox(
                            //   height: h * .02,
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     Container(
                            //       height: h * .04,
                            //       width: w * .14,
                            //       // color: Colors.amber,
                            //       margin: EdgeInsets.only(left: 2, right: 2),
                            //       child: Row(
                            //         children: [
                            //           Material(
                            //             color: Colors.transparent,
                            //             child: InkWell(
                            //               splashColor: Colors.white,
                            //               onTap: () {},
                            //               child: Container(
                            //                   height: h * .03,
                            //                   width: w * .066,
                            //                   // color: Colors.blue,
                            //                   child: Center(
                            //                       // child: Text(
                            //                       //   "View All",
                            //                       //   style: TextStyle(
                            //                       //       color:
                            //                       //           AppColors.app_color,
                            //                       //       fontSize: 11),
                            //                       // ),
                            //                       )),
                            //             ),
                            //           ),
                            //           Container(
                            //             height: h * .03,
                            //             width: w * .07,
                            //             // margin: EdgeInsets.all(5),
                            //             // padding: EdgeInsets.all(),
                            //             decoration: BoxDecoration(
                            //                 color: Colors.white,
                            //                 shape: BoxShape.circle),
                            //             child: Icon(
                            //               Icons.arrow_forward_ios,
                            //               color: Color(0xff4995EB),
                            //               size: 13,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      //////----------------------Invite friend section---------///////////
                      SizedBox(
                        height: h * .01,
                      ),*/


                    /*  FutureBuilder<PromoResponse>(
                          future: _future,
                          builder: (context, response) {
                            print('printing Presponse ${response.data?.banners.toString()}' );

                            if (response.connectionState != ConnectionState.done) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if(response.data!.banners.length>0) {
                              return    Container(
                                height: h * .21,
                                width: w,
                                margin: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xff4995EB),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: w * 0.05),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${response.data!.promocode[0].title}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: h * .01,
                                        ),
                                        Container(
                                          height: h * .045,
                                          // width: w * .4,

                                          child: Text(
                                            "${response.data!.promocode[0].desc}",
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 9),
                                          ),
                                        ),
                                        SizedBox(
                                          height: h * .02,
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            height: h * .05,
                                            width: w * .18,
                                            padding:
                                            EdgeInsets.only(left: 15, right: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                BorderRadius.circular(30)),
                                            child: InkWell(
                                              onTap: () {

                                                pushDynamicScreen(context,
                                                    screen: ProviderOffersFromHomePage(
                                                        serviceid: response.data!.promocode[0].id!,
                                                        name: response.data!.promocode[0].title!,
                                                        desc: response.data!.promocode[0].desc),
                                                    withNavBar: false);

                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Text(
                                                    "${response.data!.promocode[0].status}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10),
                                                  ),
                                                  Container(
                                                    height: h * .03,
                                                    width: w * .04,
                                                    // margin: EdgeInsets.all(5),
                                                    // padding: EdgeInsets.all(),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle),
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Color(0xff4995EB),
                                                      size: 13,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }else{
                              return Container();
                            }
                          }),
                      SizedBox(height: h * .03),*/

                      ///------------------------------Top Rated Services---------------////////
                    /*  Container(
                        height: h * .32,
                        width: w,
                        // color: Colors.amber,
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: h * .04,
                              width: w,
                              // color: Colors.black,
                              padding: EdgeInsets.only(left: 6),
                              child: Text("Top Rated Services",
                                  style: TextStyle(
                                      color: AppColors.app_color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(18))),
                            ),
                            SizedBox(
                              height: h * .02,
                            ),
                            Container(
                              height: h * .20,
                              width: w * .85,
                              child: ListView.builder(
                                itemCount: 7,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: h * .20,
                                    width: w * .19,
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(
                                              1.3,
                                              1.3,
                                            ), //Offset
                                            blurRadius: 1.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: h * .13,
                                          width: w,
                                          // color: Colors.blue,
                                          child: Image.asset(
                                            "assets/images/clean.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                                height: h,
                                                width: w,
                                                padding: EdgeInsets.only(
                                                    left: 2, right: 2),
                                                color: Colors.white,
                                                child: Center(
                                                    child: Text(
                                                  "Office Cleaning",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColors.text_desc,
                                                    fontSize:
                                                        ScreenUtil().setSp(12),
                                                    fontFamily:
                                                        "Montserrat-bold",
                                                  ),
                                                ))))
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // SizedBox(
                            //   height: h * .02,
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     Container(
                            //       height: h * .04,
                            //       width: w * .14,
                            //       // color: Colors.amber,
                            //       margin: EdgeInsets.only(left: 2, right: 2),
                            //       child: Row(
                            //         children: [
                            //           Material(
                            //             color: Colors.transparent,
                            //             child: InkWell(
                            //               splashColor: Colors.white,
                            //               onTap: () {},
                            //               child: Container(
                            //                   height: h * .03,
                            //                   width: w * .066,
                            //                   // color: Colors.blue,
                            //                   child: Center(
                            //                       // child: Text(
                            //                       //   "View All",
                            //                       //   style: TextStyle(
                            //                       //       color:
                            //                       //           AppColors.app_color,
                            //                       //       fontSize: 11),
                            //                       // ),
                            //                       )),
                            //             ),
                            //           ),
                            //           Container(
                            //             height: h * .03,
                            //             width: w * .07,
                            //             // margin: EdgeInsets.all(5),
                            //             // padding: EdgeInsets.all(),
                            //             decoration: BoxDecoration(
                            //                 color: Colors.white,
                            //                 shape: BoxShape.circle),
                            //             child: Icon(
                            //               Icons.arrow_forward_ios,
                            //               color: Color(0xff4995EB),
                            //               size: 13,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * .01),
                      //-----------------AC Rapir Section-------------------///////////
                      Container(
                        height: h * .32,
                        width: w,
                        // color: Colors.amber,
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: h * .04,
                              width: w,
                              padding: EdgeInsets.only(left: 6),
                              // color: Colors.black,
                              child: Text("AC & Appliance Repair",
                                  style: TextStyle(
                                      color: AppColors.app_color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(18))),
                            ),
                            SizedBox(
                              height: h * .02,
                            ),
                            Container(
                              height: h * .20,
                              width: w * .85,
                              child: ListView.builder(
                                itemCount: 7,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: h * .20,
                                    width: w * .19,
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(
                                              1.3,
                                              1.3,
                                            ), //Offset
                                            blurRadius: 1.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: h * .13,
                                          width: w,
                                          // color: Colors.blue,
                                          child: Image.asset(
                                            "assets/images/acrepair.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                                height: h,
                                                width: w,
                                                padding: EdgeInsets.only(
                                                    left: 2, right: 2),
                                                alignment: Alignment.center,
                                                color: Colors.white,
                                                child: Text(
                                                  "Ac Services And  Repair",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColors.text_desc,
                                                    fontSize:
                                                        ScreenUtil().setSp(12),
                                                    fontFamily:
                                                        "Montserrat-bold",
                                                  ),
                                                )))
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: h * .02,
                            ),
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       Container(
                            //         height: h * .04,
                            //         width: w * .14,
                            //         // color: Colors.amber,
                            //         margin: EdgeInsets.only(left: 2, right: 2),
                            //         child: Row(
                            //           children: [
                            //             Material(
                            //               color: Colors.transparent,
                            //               child: InkWell(
                            //                 splashColor: Colors.white,
                            //                 onTap: () {},
                            //                 child: Container(
                            //                     height: h * .03,
                            //                     width: w * .066,
                            //                     // color: Colors.blue,
                            //                     child: Center(
                            //                         // child: Text(
                            //                         //   "View All",
                            //                         //   style: TextStyle(
                            //                         //       color:
                            //                         //           AppColors.app_color,
                            //                         //       fontSize: 11),
                            //                         // ),
                            //                         )),
                            //               ),
                            //             ),
                            //             Container(
                            //               height: h * .03,
                            //               width: w * .07,
                            //               // margin: EdgeInsets.all(5),
                            //               // padding: EdgeInsets.all(),
                            //               decoration: BoxDecoration(
                            //                   color: Colors.white,
                            //                   shape: BoxShape.circle),
                            //               child: Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: Color(0xff4995EB),
                            //                 size: 13,
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * .01),
                      //-------------------Cleaning Service Section---------------////////
                      Container(
                        height: h * .32,
                        width: w,
                        // color: Colors.amber,
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: h * .04,
                              width: w,
                              // color: Colors.black,
                              padding: EdgeInsets.only(left: 6),
                              child: Text("Cleaning Service",
                                  style: TextStyle(
                                      color: AppColors.app_color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(18))),
                            ),
                            SizedBox(
                              height: h * .02,
                            ),
                            Container(
                              height: h * .20,
                              width: w * .85,
                              child: ListView.builder(
                                itemCount: 7,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: h * .20,
                                    width: w * .19,
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(
                                              1.3,
                                              1.3,
                                            ), //Offset
                                            blurRadius: 1.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: h * .13,
                                          width: w,
                                          // color: Colors.blue,
                                          child: Image.asset(
                                            "assets/images/swiper.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                                height: h,
                                                width: w,
                                                padding: EdgeInsets.only(
                                                    left: 2, right: 2),
                                                color: Colors.white,
                                                child: Center(
                                                    child: Text(
                                                  "Home Cleaning",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColors.text_desc,
                                                    fontSize:
                                                        ScreenUtil().setSp(12),
                                                    fontFamily:
                                                        "Montserrat-bold",
                                                  ),
                                                ))))
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: h * .02,
                            ),
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       Container(
                            //         height: h * .04,
                            //         width: w * .14,
                            //         // color: Colors.amber,
                            //         margin: EdgeInsets.only(left: 2, right: 2),
                            //         child: Row(
                            //           children: [
                            //             Material(
                            //               color: Colors.transparent,
                            //               child: InkWell(
                            //                 splashColor: Colors.white,
                            //                 onTap: () {},
                            //                 child: Container(
                            //                     height: h * .03,
                            //                     width: w * .066,
                            //                     // color: Colors.blue,
                            //                     child: Center(
                            //                         // child: Text(
                            //                         //   "View All",
                            //                         //   style: TextStyle(
                            //                         //       color:
                            //                         //           AppColors.app_color,
                            //                         //       fontSize: 11),
                            //                         // ),
                            //                         )),
                            //               ),
                            //             ),
                            //             Container(
                            //               height: h * .03,
                            //               width: w * .07,
                            //               // margin: EdgeInsets.all(5),
                            //               // padding: EdgeInsets.all(),
                            //               decoration: BoxDecoration(
                            //                   color: Colors.white,
                            //                   shape: BoxShape.circle),
                            //               child: Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: Color(0xff4995EB),
                            //                 size: 13,
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                          ],
                        ),
                      ),*/
                    ],
                  )),
            )),
          ],
        ),
      ),
    );
  }

  bottomSheetForSignIn(BuildContext context) {
    showModalBottomSheet(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: LoginScreen(isFromOtherScreen: true));
        }).whenComplete(() {
      print('ondismiss');
      if (StorageManager().accessToken.isNotNullAndNotEmpty)
        pushDynamicScreen(context,
            screen: SettingsRoutePage(), withNavBar: false);
    });
  }
}
