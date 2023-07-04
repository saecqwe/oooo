import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kappu/components/MyAppBar.dart';
import 'package:kappu/net/http_client.dart';
import 'package:kappu/screens/slider_offers.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../../models/serializable_model/CategoryResponse.dart';

class CatagoriesScreen extends StatefulWidget {
  const CatagoriesScreen({Key? key}) : super(key: key);

  @override
  _CatagoriesScreenState createState() => _CatagoriesScreenState();
}

class _CatagoriesScreenState extends State<CatagoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildOverlayContent(context, false);
  }
}


Widget _buildOverlayContent(BuildContext context, bool showBackButton) {
  return Scaffold(
    appBar: showBackButton ? MyAppBar(title: "Catagoies") : AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Column(
          children: [
            Text(
                "Catagoies",
                style: TextStyle(fontSize: 20.sp, color: Colors.black, fontFamily: "Montserrat-Bold")),
          ],
        ),
      actions: [IconButton(
        onPressed: (){},
          icon: const Icon(Icons.search))],
    ),
    body: FutureBuilder(
        future: HttpClient().getCatagory(),
        builder: (context, AsyncSnapshot<CategoryResponse> response) {
          if (response.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: response.data!.data
                .map((item) => Column(
              children: [
                GestureDetector(
                  onTap: () {
                    pushDynamicScreen(context,
                        screen: ProviderOffersFromHomePage(serviceid: item.id, name: item.name, desc: item.description),
                        withNavBar: false);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(10),
                            bottom: ScreenUtil().setHeight(8)),
                        child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)),
                            child: Image.network(
                              response.data!.baseUrl+"/"+item.image,
                              width: 80,
                            )),
                      ),

                      SizedBox(width: 10,),
                      Expanded(child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(16),
                                fontFamily: "Montserrat-Bold"),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 8.0),
                            child: Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                  ScreenUtil().setSp(14),
                                  fontFamily: "Montserrat-Regular"),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          )
                        ],
                      ),),
                      SizedBox(
                        width: ScreenUtil().setWidth(40),
                      )
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1,
                )
              ],
            ))
                .toList(),
          );
        }),

  );
}

class CategoryRoutePage extends ModalRoute<void> {


  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => "";

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      child: _buildOverlayContent(context, true),
    );
  }
}

